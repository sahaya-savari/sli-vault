import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../domain/vault_item.dart';
import 'local_image_storage.dart';
import 'vault_database.dart';

class ImportPreviewSummary {
  final int formatVersion;
  final int totalItemsInArchive;
  final int newItemsToImport;
  final int duplicateItemsSkipped;
  final int imageFilesRestored;
  final List<VaultItem> validatedNewItems;
  final Map<String, Uint8List> stagedImages;
  final String sourceFormat;
  final int failedRecords;
  final List<String> customCollectionsToRestore;

  const ImportPreviewSummary({
    required this.formatVersion,
    required this.totalItemsInArchive,
    required this.newItemsToImport,
    required this.duplicateItemsSkipped,
    required this.imageFilesRestored,
    required this.validatedNewItems,
    required this.stagedImages,
    this.sourceFormat = 'flutter_zip',
    this.failedRecords = 0,
    this.customCollectionsToRestore = const [],
  });
}

class VaultBackupService {
  static const String productIdentifier = 'sli_vault';
  static const int currentBackupFormatVersion = 3;
  static const int maxArchiveBytes = 150 * 1024 * 1024; // 150 MB safety cap
  static const int maxExtractedBytes = 300 * 1024 * 1024;

  final VaultDatabase database;
  final LocalImageStorage imageStorage;
  final int maxInputBytes;
  final int maxExpandedBytes;

  VaultBackupService({
    required this.database,
    required this.imageStorage,
    this.maxInputBytes = maxArchiveBytes,
    this.maxExpandedBytes = maxExtractedBytes,
  });

  /// Creates a versioned ZIP archive containing `manifest.json`, `images/<id>`,
  /// spreadsheet-compatible `links.csv`, and portable `README.txt` (FR-015).
  Future<Uint8List> createBackupArchiveBytes({
    List<String>? customCollections,
  }) async {
    final items = await database.getAllItems();
    final archive = Archive();

    final imageEntries = <Map<String, Object?>>[];
    final exportedImageIds = <String>{};
    for (final item in items) {
      final imageId = item.localImageId;
      if (imageId != null &&
          imageId.isNotEmpty &&
          exportedImageIds.add(imageId)) {
        final file = await imageStorage.resolveImageFile(imageId);
        if (file == null || !await file.exists()) {
          throw StateError(
            'Cannot export: missing image file for "${item.title}" ($imageId).',
          );
        }
        final bytes = await file.readAsBytes();
        final arcPath = 'images/${p.basename(imageId)}';
        archive.addFile(ArchiveFile(arcPath, bytes.length, bytes));
        imageEntries.add({
          'imageId': p.basename(imageId),
          'sizeBytes': bytes.length,
          'sha256': sha256.convert(bytes).toString(),
        });
      }
    }

    final filteredCollections =
        (customCollections ?? const <String>[])
            .where((c) => c.trim().isNotEmpty && c.trim() != 'General')
            .map((c) => c.trim())
            .toSet()
            .toList()
          ..sort();

    final manifest = {
      'product': productIdentifier,
      'backupFormatVersion': currentBackupFormatVersion,
      'schemaVersion': VaultDatabase.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'itemCount': items.length,
      'images': imageEntries,
      'items': items.map((e) => e.toBackupJson()).toList(),
      if (filteredCollections.isNotEmpty)
        'customCollections': filteredCollections,
    };

    final manifestBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(manifest),
    );
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    // 1. Spreadsheet-compatible CSV export with formula injection defense
    final csvString = buildLinksCsv(items);
    final csvBytes = utf8.encode(csvString);
    archive.addFile(ArchiveFile('links.csv', csvBytes.length, csvBytes));

    // 2. Portable human-readable README for desktop/PC inspection
    final readmeString = buildReadmeText();
    final readmeBytes = utf8.encode(readmeString);
    archive.addFile(ArchiveFile('README.txt', readmeBytes.length, readmeBytes));

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  /// Validates an archive without modifying existing library data (FR-016).
  Future<ImportPreviewSummary> validateBackupArchive(Uint8List zipBytes) async {
    if (zipBytes.isEmpty) {
      throw const FormatException('Backup file is empty.');
    }
    if (zipBytes.length > maxInputBytes) {
      throw const FormatException(
        'Backup archive exceeds maximum allowed size.',
      );
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    } catch (_) {
      throw const FormatException('Invalid or corrupted ZIP archive.');
    }

    ArchiveFile? manifestFile;
    final imageFiles = <String, Uint8List>{};
    final entryNames = <String>{};
    var extractedBytes = 0;

    for (final entry in archive.files) {
      final rawName = entry.name.replaceAll('\\', '/');
      // Reject path traversal or absolute paths
      if (rawName.contains('..') ||
          rawName.startsWith('/') ||
          rawName.contains(':')) {
        throw FormatException('Unsafe archive path rejected: $rawName');
      }
      if (!entry.isFile) continue;
      if (!entryNames.add(rawName)) {
        throw FormatException('Duplicate archive entry rejected: $rawName');
      }
      extractedBytes += entry.size;
      if (extractedBytes > maxExpandedBytes) {
        throw const FormatException(
          'Backup expands beyond the maximum allowed size.',
        );
      }

      if (rawName == 'manifest.json') {
        manifestFile = entry;
      } else if (rawName == 'links.csv') {
        // Portable CSV catalog — accepted in archive
      } else if (rawName == 'README.txt') {
        // Portable instructions — accepted in archive
      } else if (rawName.startsWith('images/')) {
        final base = p.basename(rawName);
        if (rawName != 'images/$base' || base.isEmpty) {
          throw FormatException('Invalid image path in archive: $rawName');
        }
        final content = Uint8List.fromList(entry.content);
        final detectedExtension = LocalImageStorage.detectImageExtension(
          content,
        );
        if (detectedExtension == null) {
          throw FormatException('Unsupported image binary in archive: $base');
        }
        final declaredExtension = p.extension(base).toLowerCase();
        final normalizedDeclaredExtension = declaredExtension == '.jpeg'
            ? '.jpg'
            : (declaredExtension == '.heif' ? '.heic' : declaredExtension);
        if (normalizedDeclaredExtension != detectedExtension) {
          throw FormatException(
            'Image extension does not match its binary content: $base',
          );
        }
        imageFiles[base] = content;
      } else {
        throw FormatException('Unexpected file in backup archive: $rawName');
      }
    }

    if (manifestFile == null) {
      throw const FormatException('Backup archive is missing manifest.json.');
    }

    final Map<String, Object?> manifest;
    try {
      final decoded = jsonDecode(utf8.decode(manifestFile.content));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Manifest root must be a JSON object.');
      }
      manifest = decoded;
    } catch (_) {
      throw const FormatException('manifest.json is malformed JSON.');
    }

    if (manifest['product'] != productIdentifier) {
      throw const FormatException('Archive was not created by SLI Vault.');
    }

    final formatVersion = manifest['backupFormatVersion'];
    if (formatVersion is! int ||
        formatVersion < 1 ||
        formatVersion > currentBackupFormatVersion) {
      throw FormatException(
        'Unsupported backup format version: $formatVersion',
      );
    }

    final schemaVersion = manifest['schemaVersion'];
    if (schemaVersion is! int ||
        schemaVersion < 1 ||
        schemaVersion > VaultDatabase.schemaVersion) {
      throw FormatException(
        'Unsupported database schema version: $schemaVersion',
      );
    }

    final itemsRaw = manifest['items'];
    if (itemsRaw is! List) {
      throw const FormatException('Manifest is missing a valid items list.');
    }
    if (manifest['itemCount'] != itemsRaw.length) {
      throw const FormatException('Manifest item count does not match items.');
    }

    final declaredImages = _validateImageManifest(
      manifest['images'],
      imageFiles,
      requireChecksums: formatVersion >= 2,
    );

    final existingItems = await database.getAllItems();
    final existingIds = existingItems.map((e) => e.id).toSet();
    final seenInArchive = <String>{};
    final validatedNew = <VaultItem>[];
    final stagedImages = <String, Uint8List>{};
    final referencedImages = <String>{};
    int skippedDuplicates = 0;

    for (final raw in itemsRaw) {
      if (raw is! Map<String, Object?>) {
        throw const FormatException('Invalid item entry in manifest.');
      }
      final parsed = VaultItem.tryFromBackupJson(raw);
      if (parsed == null) {
        throw const FormatException(
          'One or more item records in manifest failed validation.',
        );
      }

      if (parsed.type != VaultItemType.link) {
        final imgId = parsed.localImageId!;
        referencedImages.add(imgId);
        final bytes = imageFiles[imgId];
        if (bytes == null) {
          throw FormatException(
            'Archive is missing image file "$imgId" for "${parsed.title}".',
          );
        }
      }

      if (!seenInArchive.add(parsed.id)) {
        throw FormatException('Duplicate item ID in archive: ${parsed.id}');
      }
      if (existingIds.contains(parsed.id)) {
        skippedDuplicates++;
        continue;
      }
      validatedNew.add(parsed);
      if (parsed.type != VaultItemType.link) {
        stagedImages[parsed.localImageId!] = imageFiles[parsed.localImageId!]!;
      }
    }

    final orphanImages = declaredImages.difference(referencedImages);
    if (orphanImages.isNotEmpty) {
      throw FormatException(
        'Archive contains unreferenced image files: ${orphanImages.join(', ')}',
      );
    }
    final undeclaredReferences = referencedImages.difference(declaredImages);
    if (undeclaredReferences.isNotEmpty) {
      throw FormatException(
        'Manifest image metadata is missing: ${undeclaredReferences.join(', ')}',
      );
    }

    // Extract custom collections if present
    final customCollectionsToRestore = <String>[];
    final rawCustomCollections = manifest['customCollections'];
    if (rawCustomCollections is List) {
      for (final col in rawCustomCollections) {
        if (col is String && col.trim().isNotEmpty && col.trim() != 'General') {
          customCollectionsToRestore.add(col.trim());
        }
      }
    }

    return ImportPreviewSummary(
      formatVersion: formatVersion,
      totalItemsInArchive: itemsRaw.length,
      newItemsToImport: validatedNew.length,
      duplicateItemsSkipped: skippedDuplicates,
      imageFilesRestored: stagedImages.length,
      validatedNewItems: validatedNew,
      stagedImages: stagedImages,
      sourceFormat: 'flutter_zip',
      customCollectionsToRestore: customCollectionsToRestore,
    );
  }

  Set<String> _validateImageManifest(
    Object? rawImages,
    Map<String, Uint8List> imageFiles, {
    required bool requireChecksums,
  }) {
    if (rawImages is! List) {
      throw const FormatException('Manifest is missing image metadata.');
    }
    final declared = <String>{};
    for (final raw in rawImages) {
      if (raw is! Map) {
        throw const FormatException(
          'Manifest contains invalid image metadata.',
        );
      }
      final metadata = Map<String, Object?>.from(raw);
      final imageId = (metadata['imageId'] as String?)?.trim();
      if (imageId == null ||
          imageId.isEmpty ||
          p.basename(imageId) != imageId ||
          !declared.add(imageId)) {
        throw const FormatException(
          'Manifest contains an invalid or duplicate image ID.',
        );
      }
      final bytes = imageFiles[imageId];
      if (bytes == null) {
        throw FormatException('Archive is missing declared image "$imageId".');
      }
      if (metadata['sizeBytes'] != bytes.length) {
        throw FormatException('Image size check failed for "$imageId".');
      }
      final checksum = metadata['sha256'];
      if (requireChecksums &&
          (checksum is! String ||
              checksum.toLowerCase() != sha256.convert(bytes).toString())) {
        throw FormatException('Image checksum check failed for "$imageId".');
      }
    }
    final undeclaredFiles = imageFiles.keys.toSet().difference(declared);
    if (undeclaredFiles.isNotEmpty) {
      throw FormatException(
        'Archive contains images absent from metadata: ${undeclaredFiles.join(', ')}',
      );
    }
    return declared;
  }

  /// Validates the JSON format emitted by the Kotlin repository exporter.
  /// Image paths are deliberately ignored; imageBase64 is the portable source.
  Future<ImportPreviewSummary> validateKotlinJson(Uint8List jsonBytes) async {
    if (jsonBytes.isEmpty) {
      throw const FormatException('Kotlin backup file is empty.');
    }
    if (jsonBytes.length > maxInputBytes) {
      throw const FormatException(
        'Kotlin backup exceeds maximum allowed size.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(jsonBytes));
    } catch (_) {
      throw const FormatException('Kotlin backup is malformed JSON.');
    }
    if (decoded is! Map) {
      throw const FormatException('Kotlin backup root must be a JSON object.');
    }
    final root = Map<String, Object?>.from(decoded);
    final app = root['app']?.toString();
    if (app != null && app != 'SLI Vault' && app != productIdentifier) {
      throw const FormatException('JSON backup was not created by SLI Vault.');
    }
    final version = root['version']?.toString();
    if (version != null && !version.startsWith('1.')) {
      throw FormatException('Unsupported Kotlin backup version: $version');
    }
    final rawItems = root['items'];
    if (rawItems is! List) {
      throw const FormatException('Kotlin backup is missing an items array.');
    }

    final existingIds = (await database.getAllItems())
        .map((item) => item.id)
        .toSet();
    final seenIds = <String>{};
    final newItems = <VaultItem>[];
    final stagedImages = <String, Uint8List>{};
    var skippedDuplicates = 0;

    for (final raw in rawItems) {
      if (raw is! Map) {
        throw const FormatException(
          'Kotlin backup contains an invalid item entry.',
        );
      }
      final itemMap = Map<String, Object?>.from(raw);
      final parsed = VaultItem.tryFromKotlinJson(itemMap);
      if (parsed == null) {
        throw const FormatException(
          'Kotlin backup contains an invalid item record.',
        );
      }

      Uint8List? imageBytes;
      String? imageId;
      if (parsed.type != VaultItemType.link) {
        final encodedImage = itemMap['imageBase64']?.toString();
        if (encodedImage == null || encodedImage.isEmpty) {
          throw FormatException('Missing imageBase64 for item "${parsed.id}".');
        }
        try {
          imageBytes = Uint8List.fromList(base64.decode(encodedImage));
        } catch (_) {
          throw FormatException(
            'Invalid Base64 image for item "${parsed.id}".',
          );
        }
        final extension = LocalImageStorage.detectImageExtension(imageBytes);
        if (extension == null) {
          throw FormatException(
            'Invalid or unsupported image for item "${parsed.id}".',
          );
        }
        imageId = '${parsed.id}$extension';
      }

      if (!seenIds.add(parsed.id)) {
        throw FormatException(
          'Kotlin backup contains duplicate item ID "${parsed.id}".',
        );
      }
      if (existingIds.contains(parsed.id)) {
        skippedDuplicates++;
        continue;
      }

      final imported = parsed.copyWith(
        localImageId: imageId,
        fileSizeBytes: imageBytes?.length ?? parsed.fileSizeBytes,
      );
      newItems.add(imported);
      if (imageId != null && imageBytes != null) {
        stagedImages[imageId] = imageBytes;
      }
    }

    return ImportPreviewSummary(
      formatVersion: 1,
      totalItemsInArchive: rawItems.length,
      newItemsToImport: newItems.length,
      duplicateItemsSkipped: skippedDuplicates,
      imageFilesRestored: stagedImages.length,
      validatedNewItems: newItems,
      stagedImages: stagedImages,
      sourceFormat: 'kotlin_json',
    );
  }

  /// Commits a validated import preview safely: stages image files before inserting records.
  Future<void> commitImportPreview(ImportPreviewSummary preview) async {
    final createdImageIds = <String>[];
    try {
      for (final entry in preview.stagedImages.entries) {
        final existing = await imageStorage.resolveImageFile(entry.key);
        if (existing != null) {
          final existingBytes = await existing.readAsBytes();
          if (!_bytesEqual(existingBytes, entry.value)) {
            throw StateError(
              'Image ID collision with different content: ${entry.key}',
            );
          }
          continue;
        }
        await imageStorage.saveImageBytes(
          entry.value,
          explicitImageId: entry.key,
        );
        createdImageIds.add(entry.key);
      }
      await database.upsertItemsAtomically(preview.validatedNewItems);
    } catch (_) {
      for (final imageId in createdImageIds) {
        final file = await imageStorage.resolveImageFile(imageId);
        if (file != null && await file.exists()) {
          await file.delete();
        }
      }
      rethrow;
    }
  }

  bool _bytesEqual(Uint8List left, Uint8List right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  /// Builds a spreadsheet-compatible UTF-8 CSV containing all saved links and items.
  /// Protects against spreadsheet formula injection by escaping formula prefixes.
  static String buildLinksCsv(List<VaultItem> items) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Title,Type,URL,Domain,Description,Tags,Collection,Favorite,CreatedAt',
    );
    for (final item in items) {
      final title = _sanitizeCsvCell(item.title);
      final type = _sanitizeCsvCell(item.type.label);
      final url = _sanitizeCsvCell(item.url ?? '');
      final domain = _sanitizeCsvCell(item.domain ?? '');
      final description = _sanitizeCsvCell(item.description ?? '');
      final tags = _sanitizeCsvCell(item.tags.join(', '));
      final collection = _sanitizeCsvCell(item.collection);
      final favorite = _sanitizeCsvCell(item.isFavorite ? 'Yes' : 'No');
      final createdAt = _sanitizeCsvCell(item.createdAt.toIso8601String());
      buffer.writeln(
        '$title,$type,$url,$domain,$description,$tags,$collection,$favorite,$createdAt',
      );
    }
    return buffer.toString();
  }

  /// Sanitizes a CSV cell value. Implements RFC 4180 quoting and defends against
  /// formula injection in spreadsheet applications (Excel, Google Sheets, Calc).
  static String _sanitizeCsvCell(String value) {
    var text = value;
    // Formula injection defense: if text begins with =, +, -, @, tab, or carriage return,
    // prepend a single quote so spreadsheets treat the cell as plain text.
    if (text.isNotEmpty) {
      final first = text[0];
      if (first == '=' ||
          first == '+' ||
          first == '-' ||
          first == '@' ||
          first == '\t' ||
          first == '\r') {
        text = "'$text";
      }
    }
    if (text.contains(',') ||
        text.contains('"') ||
        text.contains('\n') ||
        text.contains('\r')) {
      final escaped = text.replaceAll('"', '""');
      return '"$escaped"';
    }
    return text;
  }

  /// Builds a human-readable README for desktop inspection of the backup ZIP archive.
  static String buildReadmeText() {
    return '''
SLI VAULT BACKUP ARCHIVE
========================

This archive is a complete, portable backup of your personal SLI Vault library.

CONTENTS
--------
1. manifest.json
   Structured JSON catalog of all library items, collections, tags, favorites,
   and media checksums (SHA-256). Used by SLI Vault to restore your library.

2. images/
   The original binary image files (PNG, JPEG, WebP, GIF, BMP, HEIC) saved in
   your vault. Images preserve their exact original bytes, format, and animations.

3. links.csv
   A standard UTF-8 spreadsheet-compatible export of your saved links and
   item metadata. You can open this file in Microsoft Excel, Google Sheets,
   Apple Numbers, or any text editor without installing SLI Vault.

4. README.txt
   This documentation file.

HOW TO EXTRACT & VIEW ON A PC
-----------------------------
You can open this ZIP archive with standard archive utilities (Windows Explorer,
macOS Archive Utility, 7-Zip, unzip, etc.):
- Extract the archive to a folder.
- Open 'links.csv' in spreadsheet software to browse your saved URLs and notes.
- Browse the 'images/' folder to view your saved photos and screenshots. Note that
  some formats (such as HEIC or WebP) may require viewing software that supports them.

HOW TO RESTORE IN SLI VAULT
---------------------------
1. Copy or share this ZIP file to your device.
2. Open SLI Vault.
3. Go to Settings -> Storage & Backup -> Import Backup.
4. Select this ZIP file.
5. Review the validation summary and confirm import.
Existing items already in your vault are kept; new items, custom collections,
and images are restored safely into app-private storage.

PRIVACY & SECURITY NOTICE
-------------------------
This backup file is NOT encrypted by SLI Vault. It contains your saved links,
metadata, and image files in their original form. Please keep this archive safe
and private, and do not upload it to untrusted services.

Product: SLI Vault (com.sahayasavari.slivault)
''';
  }
}
