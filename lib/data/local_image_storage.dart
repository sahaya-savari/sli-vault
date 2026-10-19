import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LocalImageStorage {
  final Directory? overrideBaseDir;
  final Uuid _uuid = const Uuid();

  LocalImageStorage({this.overrideBaseDir});

  Future<Directory> getImagesDir() async {
    final base = overrideBaseDir ?? await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'vault_images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Validates basic image magic headers (PNG, JPEG, WEBP, GIF, BMP).
  static String? detectImageExtension(Uint8List bytes, {String? fileNameHint}) {
    if (bytes.length < 12) return null;
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return '.jpg';
    }
    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return '.gif';
    }
    // WEBP: RIFF....WEBP
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return '.webp';
    }
    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return '.bmp';
    }
    // HEIF / HEIC: starts with ftyp box at offset 4
    if (bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      final brand = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
      if (brand == 'heic' ||
          brand == 'heix' ||
          brand == 'heim' ||
          brand == 'heis' ||
          brand == 'hevc' ||
          brand == 'hevx' ||
          brand == 'mif1' ||
          brand == 'msf1' ||
          (fileNameHint != null &&
              (fileNameHint.toLowerCase().endsWith('.heic') ||
                  fileNameHint.toLowerCase().endsWith('.heif')))) {
        return '.heic';
      }
    }
    return null;
  }

  /// Saves image bytes into durable app-private storage and returns a stable localImageId.
  Future<String> saveImageBytes(
    Uint8List bytes, {
    String? fileNameHint,
    String? explicitImageId,
  }) async {
    final ext = detectImageExtension(bytes, fileNameHint: fileNameHint);
    if (ext == null) {
      throw const FormatException(
        'Unsupported or unreadable image format. Choose a PNG, JPG, WEBP, GIF, BMP, or HEIC file.',
      );
    }

    final dir = await getImagesDir();
    final explicitBaseName = explicitImageId == null
        ? null
        : p.basename(explicitImageId);
    if (explicitImageId != null &&
        (explicitImageId != explicitBaseName ||
            p
                    .extension(explicitImageId)
                    .toLowerCase()
                    .replaceFirst('.jpeg', '.jpg')
                    .replaceFirst('.heif', '.heic') !=
                ext)) {
      throw const FormatException(
        'Explicit image ID must be a safe filename matching the image format.',
      );
    }
    final safeId = explicitBaseName ?? '${_uuid.v4()}$ext';
    final file = File(p.join(dir.path, safeId));
    await file.writeAsBytes(bytes, flush: true);
    return safeId;
  }

  Future<File?> resolveImageFile(String? localImageId) async {
    if (localImageId == null || localImageId.trim().isEmpty) return null;
    final safeName = p.basename(localImageId.trim());
    if (safeName != localImageId.trim()) return null;
    final dir = await getImagesDir();
    final file = File(p.join(dir.path, safeName));
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> deleteImageIfUnused(
    String? localImageId,
    Set<String> activeReferencedIds,
  ) async {
    if (localImageId == null || localImageId.trim().isEmpty) return;
    if (activeReferencedIds.contains(localImageId)) return;
    final file = await resolveImageFile(localImageId);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  Future<int> calculateTotalImageBytes() async {
    final dir = await getImagesDir();
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<List<String>> listAllStoredImageIds() async {
    final dir = await getImagesDir();
    if (!await dir.exists()) return [];
    final ids = <String>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        ids.add(p.basename(entity.path));
      }
    }
    return ids;
  }

  Future<int> cleanOrphanedImages(Set<String> activeReferencedIds) async {
    final dir = await getImagesDir();
    if (!await dir.exists()) return 0;
    int cleaned = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        final id = p.basename(entity.path);
        if (!activeReferencedIds.contains(id)) {
          try {
            await entity.delete();
            cleaned++;
          } catch (_) {}
        }
      }
    }
    return cleaned;
  }

  Future<void> clearAllImages() async {
    final dir = await getImagesDir();
    if (await dir.exists()) {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    }
  }
}
