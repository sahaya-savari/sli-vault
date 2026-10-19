import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'link_metadata_service.dart';

class ArticleSnapshot {
  final String itemId;
  final String sourceUrl;
  final String title;
  final String readableContent;
  final DateTime createdAt;
  final int fileSizeBytes;

  const ArticleSnapshot({
    required this.itemId,
    required this.sourceUrl,
    required this.title,
    required this.readableContent,
    required this.createdAt,
    required this.fileSizeBytes,
  });

  Map<String, Object?> toJson() => {
    'itemId': itemId,
    'sourceUrl': sourceUrl,
    'title': title,
    'readableContent': readableContent,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'fileSizeBytes': fileSizeBytes,
  };

  factory ArticleSnapshot.fromJson(Map<String, Object?> json) =>
      ArticleSnapshot(
        itemId: json['itemId'] as String,
        sourceUrl: json['sourceUrl'] as String,
        title: json['title'] as String,
        readableContent: json['readableContent'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      );
}

class ArticleSnapshotService {
  static const int maxSnapshotBytes = 256 * 1024; // 256 KB cap
  static const Duration _timeout = Duration(seconds: 6);

  final Directory? overrideDir;

  const ArticleSnapshotService({this.overrideDir});

  Future<Directory> _getSnapshotsDir() async {
    final base = overrideDir ?? await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'snapshots'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  File _getSnapshotFile(Directory dir, String itemId) {
    return File(p.join(dir.path, '$itemId.json'));
  }

  Future<bool> hasSnapshot(String itemId) async {
    try {
      final dir = await _getSnapshotsDir();
      return await _getSnapshotFile(dir, itemId).exists();
    } catch (_) {
      return false;
    }
  }

  Future<ArticleSnapshot?> loadSnapshot(String itemId) async {
    try {
      final dir = await _getSnapshotsDir();
      final file = _getSnapshotFile(dir, itemId);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        return ArticleSnapshot.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSnapshot(String itemId) async {
    try {
      final dir = await _getSnapshotsDir();
      final file = _getSnapshotFile(dir, itemId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Sanitizes raw HTML into clean, script-free readable markdown text.
  static String sanitizeHtmlToReadableText(String rawHtml) {
    var text = rawHtml;

    // 1. Remove dangerous executable scripts, styles, iframes, objects, embeds
    text = text.replaceAll(
      RegExp(
        r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(
        r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(
        r'<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(
        r'<noscript\b[^<]*(?:(?!<\/noscript>)<[^<]*)*<\/noscript>',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(r'<svg\b[^<]*(?:(?!<\/svg>)<[^<]*)*<\/svg>', caseSensitive: false),
      '',
    );
    text = text.replaceAll(
      RegExp(
        r'<form\b[^<]*(?:(?!<\/form>)<[^<]*)*<\/form>',
        caseSensitive: false,
      ),
      '',
    );

    // 2. Format structure to readable Markdown
    text = text.replaceAll(
      RegExp(r'<(h1|h2)[^>]*>', caseSensitive: false),
      '\n\n## ',
    );
    text = text.replaceAll(
      RegExp(r'<(h3|h4)[^>]*>', caseSensitive: false),
      '\n\n### ',
    );
    text = text.replaceAll(
      RegExp(r'<(h5|h6)[^>]*>', caseSensitive: false),
      '\n\n#### ',
    );
    text = text.replaceAll(
      RegExp(r'</(h1|h2|h3|h4|h5|h6)>', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ');
    text = text.replaceAll(
      RegExp(r'</blockquote>', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(
      RegExp(r'<blockquote[^>]*>', caseSensitive: false),
      '\n> ',
    );

    // 3. Strip all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');

    // 4. Decode HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');

    // 5. Clean up excessive whitespace and newlines
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.trim();

    if (text.length > maxSnapshotBytes) {
      text = text.substring(0, maxSnapshotBytes);
    }

    return text;
  }

  /// Downloads and saves a sanitized offline readable article snapshot.
  Future<ArticleSnapshot> createSnapshot({
    required String itemId,
    required String sourceUrl,
    String? titleHint,
    HttpClient? customClient,
  }) async {
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('Invalid URL for article snapshot.');
    }

    final isSafe = await LinkMetadataService.isPublicHostSafe(uri.host);
    if (!isSafe) {
      throw const SocketException(
        'Access to private/local address is blocked.',
      );
    }

    final client = customClient ?? HttpClient()
      ..connectionTimeout = _timeout;

    try {
      final request = await client.getUrl(uri).timeout(_timeout);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'SLIVault/1.0 (Privacy-conscious offline reader)',
      );
      request.headers.set(
        HttpHeaders.acceptHeader,
        'text/html,application/xhtml+xml',
      );

      final response = await request.close().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Server returned ${response.statusCode}');
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
        if (bytes.length >= maxSnapshotBytes * 2) break;
      }

      final rawHtml = utf8.decode(bytes, allowMalformed: true);
      final metadata = LinkMetadataService.parseHtml(
        rawUrl: sourceUrl,
        html: rawHtml,
        baseUri: uri,
      );

      final title = titleHint?.trim().isNotEmpty == true
          ? titleHint!.trim()
          : (metadata.title ?? uri.host);

      final readable = sanitizeHtmlToReadableText(rawHtml);
      if (readable.isEmpty) {
        throw const FormatException(
          'No readable article text could be extracted.',
        );
      }

      final snapshot = ArticleSnapshot(
        itemId: itemId,
        sourceUrl: sourceUrl,
        title: title,
        readableContent: readable,
        createdAt: DateTime.now(),
        fileSizeBytes: utf8.encode(readable).length,
      );

      final dir = await _getSnapshotsDir();
      final file = _getSnapshotFile(dir, itemId);
      await file.writeAsString(jsonEncode(snapshot.toJson()), flush: true);

      return snapshot;
    } finally {
      if (customClient == null) {
        client.close(force: true);
      }
    }
  }
}
