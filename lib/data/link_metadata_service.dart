import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class LinkMetadata {
  final String url;
  final String? title;
  final String? description;
  final String? domain;
  final String? faviconUrl;
  final String? previewImageUrl;

  const LinkMetadata({
    required this.url,
    this.title,
    this.description,
    this.domain,
    this.faviconUrl,
    this.previewImageUrl,
  });

  bool get hasContent =>
      (title != null && title!.isNotEmpty) ||
      (description != null && description!.isNotEmpty) ||
      (previewImageUrl != null && previewImageUrl!.isNotEmpty);
}

class LinkMetadataService {
  static final Map<String, LinkMetadata> _cache = {};
  static const int _maxBodyBytes = 128 * 1024; // 128 KB limit
  static const Duration _timeout = Duration(seconds: 5);

  /// Checks whether an [InternetAddress] belongs to a private, loopback,
  /// or reserved local network to guard against SSRF.
  static bool isPrivateOrReservedAddress(InternetAddress address) {
    if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
      return true;
    }

    if (address.type == InternetAddressType.IPv4) {
      final raw = address.rawAddress;
      final b0 = raw[0];
      final b1 = raw[1];

      // 0.0.0.0/8 (Current network)
      if (b0 == 0) return true;
      // 10.0.0.0/8 (Private)
      if (b0 == 10) return true;
      // 100.64.0.0/10 (Shared / Carrier-grade NAT)
      if (b0 == 100 && (b1 >= 64 && b1 <= 127)) return true;
      // 127.0.0.0/8 (Loopback)
      if (b0 == 127) return true;
      // 169.254.0.0/16 (Link local)
      if (b0 == 169 && b1 == 254) return true;
      // 172.16.0.0/12 (Private)
      if (b0 == 172 && (b1 >= 16 && b1 <= 31)) return true;
      // 192.168.0.0/16 (Private)
      if (b0 == 192 && b1 == 168) return true;
      // 255.255.255.255 (Broadcast)
      if (b0 == 255) return true;
    } else if (address.type == InternetAddressType.IPv6) {
      final raw = address.rawAddress;
      // Unique Local Addresses (fc00::/7)
      if ((raw[0] & 0xfe) == 0xfc) return true;
      // Link-Local (fe80::/10)
      if (raw[0] == 0xfe && (raw[1] & 0xc0) == 0x80) return true;
    }

    return false;
  }

  /// Verifies if a hostname resolves exclusively to public external IP addresses.
  static Future<bool> isPublicHostSafe(String host) async {
    try {
      final addresses = await InternetAddress.lookup(host).timeout(_timeout);
      if (addresses.isEmpty) return false;
      for (final addr in addresses) {
        if (isPrivateOrReservedAddress(addr)) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Extracts link metadata safely, observing privacy, SSRF guards, and timeouts.
  static Future<LinkMetadata> fetchMetadata(
    String rawUrl, {
    HttpClient? customClient,
  }) async {
    final cached = _cache[rawUrl];
    if (cached != null) return cached;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return LinkMetadata(url: rawUrl);
    }

    final domain = uri.host.startsWith('www.')
        ? uri.host.substring(4)
        : uri.host;
    if (domain.isEmpty) {
      return LinkMetadata(url: rawUrl);
    }

    // SSRF pre-flight validation
    final isSafe = await isPublicHostSafe(uri.host);
    if (!isSafe) {
      // Abort without network egress to internal/private targets
      if (kDebugMode) {
        debugPrint(
          'LinkMetadataService: blocked host $domain (not public safe)',
        );
      }
      return LinkMetadata(url: rawUrl, domain: domain);
    }

    final client = customClient ?? HttpClient()
      ..connectionTimeout = _timeout
      ..idleTimeout = _timeout;

    try {
      var currentUri = uri;
      HttpClientResponse? response;

      // Handle up to 3 redirects safely with SSRF checking on every hop
      for (int i = 0; i < 3; i++) {
        final request = await client.getUrl(currentUri).timeout(_timeout);
        request.headers.set(
          HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (Linux; Android 15; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 (compatible; SLIVault/1.0)',
        );
        request.headers.set(
          HttpHeaders.acceptHeader,
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        );
        request.headers.set(HttpHeaders.acceptLanguageHeader, 'en-US,en;q=0.9');

        response = await request.close().timeout(_timeout);
        if (response.isRedirect &&
            response.headers.value(HttpHeaders.locationHeader) != null) {
          final loc = response.headers.value(HttpHeaders.locationHeader)!;
          final nextUri = currentUri.resolve(loc);
          if (nextUri.scheme != 'http' && nextUri.scheme != 'https') {
            break;
          }
          final nextSafe = await isPublicHostSafe(nextUri.host);
          if (!nextSafe) {
            break;
          }
          currentUri = nextUri;
          await response.drain<void>().timeout(
            const Duration(milliseconds: 500),
          );
        } else {
          break;
        }
      }

      if (response == null ||
          response.statusCode < 200 ||
          response.statusCode >= 400) {
        if (kDebugMode) {
          debugPrint(
            'LinkMetadataService: HTTP status ${response?.statusCode} for $domain',
          );
        }
        return LinkMetadata(url: rawUrl, domain: domain);
      }

      final contentType = response.headers.contentType;
      if (contentType != null) {
        final mime = contentType.mimeType.toLowerCase();
        if (!mime.contains('html') &&
            !mime.contains('text') &&
            !mime.contains('xml')) {
          // Not an HTML/text document
          await response.drain<void>();
          return LinkMetadata(url: rawUrl, domain: domain);
        }
      }

      // Read capped bytes to avoid downloading huge streams
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
        if (bytes.length >= _maxBodyBytes) {
          break;
        }
      }

      final html = utf8.decode(bytes, allowMalformed: true);
      final metadata = parseHtml(
        rawUrl: rawUrl,
        html: html,
        baseUri: currentUri,
      );
      _cache[rawUrl] = metadata;

      if (kDebugMode) {
        debugPrint(
          'LinkMetadataService: parsed domain=$domain hasTitle=${metadata.title != null} hasDesc=${metadata.description != null}',
        );
      }
      return metadata;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LinkMetadataService: fetch failed for $domain ($e)');
      }
      return LinkMetadata(url: rawUrl, domain: domain);
    } finally {
      if (customClient == null) {
        client.close(force: true);
      }
    }
  }

  /// Parses title, description, favicon, and preview image from raw HTML.
  static LinkMetadata parseHtml({
    required String rawUrl,
    required String html,
    required Uri baseUri,
  }) {
    final domain = baseUri.host.startsWith('www.')
        ? baseUri.host.substring(4)
        : baseUri.host;

    String? ogTitle;
    String? twitterTitle;
    String? metaTitle;
    String? htmlTitle;

    String? ogDesc;
    String? twitterDesc;
    String? metaDesc;

    String? ogImage;
    String? twitterImage;

    String? favicon;

    // 1. Extract <title>...</title>
    final titleMatch = RegExp(
      r'<title\b[^>]*>([\s\S]*?)<\/title>',
      caseSensitive: false,
    ).firstMatch(html);
    if (titleMatch != null) {
      final t = titleMatch.group(1)?.trim();
      if (t != null && t.isNotEmpty) htmlTitle = t;
    }

    // 2. Scan all <meta ...> tags
    final metaTagRegex = RegExp(r'<meta\b([^>]*)>', caseSensitive: false);
    for (final match in metaTagRegex.allMatches(html)) {
      final attrs = match.group(1) ?? '';

      final propMatch = RegExp(
        r'(?:name|property|itemprop)\s*=\s*(?:"([^"]*)"|'
        "'"
        r"([^']*)'|([^\s>]+))",
        caseSensitive: false,
      ).firstMatch(attrs);

      final contentMatch = RegExp(
        r'content\s*=\s*(?:"([^"]*)"|'
        "'"
        r"([^']*)'|([^\s>]+))",
        caseSensitive: false,
      ).firstMatch(attrs);

      if (propMatch != null && contentMatch != null) {
        final key =
            (propMatch.group(1) ??
                    propMatch.group(2) ??
                    propMatch.group(3) ??
                    '')
                .toLowerCase()
                .trim();
        final content =
            contentMatch.group(1) ??
            contentMatch.group(2) ??
            contentMatch.group(3) ??
            '';

        if (content.isNotEmpty) {
          if (key == 'og:title') {
            ogTitle ??= content;
          } else if (key == 'twitter:title') {
            twitterTitle ??= content;
          } else if (key == 'title') {
            metaTitle ??= content;
          } else if (key == 'og:description') {
            ogDesc ??= content;
          } else if (key == 'twitter:description') {
            twitterDesc ??= content;
          } else if (key == 'description') {
            metaDesc ??= content;
          } else if (key == 'og:image') {
            ogImage ??= content;
          } else if (key == 'twitter:image' || key == 'twitter:image:src') {
            twitterImage ??= content;
          }
        }
      }
    }

    // 3. Scan <link ...> tags for favicon
    final linkTagRegex = RegExp(r'<link\b([^>]*)>', caseSensitive: false);
    for (final match in linkTagRegex.allMatches(html)) {
      final attrs = match.group(1) ?? '';
      final relMatch = RegExp(
        r'rel\s*=\s*(?:"([^"]*)"|'
        "'"
        r"([^']*)'|([^\s>]+))",
        caseSensitive: false,
      ).firstMatch(attrs);
      final hrefMatch = RegExp(
        r'href\s*=\s*(?:"([^"]*)"|'
        "'"
        r"([^']*)'|([^\s>]+))",
        caseSensitive: false,
      ).firstMatch(attrs);

      if (relMatch != null && hrefMatch != null) {
        final rel =
            (relMatch.group(1) ?? relMatch.group(2) ?? relMatch.group(3) ?? '')
                .toLowerCase()
                .trim();
        final href =
            hrefMatch.group(1) ??
            hrefMatch.group(2) ??
            hrefMatch.group(3) ??
            '';

        if (href.isNotEmpty &&
            (rel == 'icon' ||
                rel == 'shortcut icon' ||
                rel == 'apple-touch-icon')) {
          favicon ??= href;
        }
      }
    }

    final rawTitle = ogTitle ?? twitterTitle ?? metaTitle ?? htmlTitle;
    final rawDesc = ogDesc ?? twitterDesc ?? metaDesc;
    var previewImg = ogImage ?? twitterImage;

    // Resolve relative URLs
    if (previewImg != null &&
        !previewImg.startsWith('http://') &&
        !previewImg.startsWith('https://')) {
      try {
        previewImg = baseUri.resolve(previewImg).toString();
      } catch (_) {}
    }
    if (favicon != null &&
        !favicon.startsWith('http://') &&
        !favicon.startsWith('https://')) {
      try {
        favicon = baseUri.resolve(favicon).toString();
      } catch (_) {}
    }

    return LinkMetadata(
      url: rawUrl,
      title: rawTitle != null ? _cleanHtml(rawTitle) : null,
      description: rawDesc != null ? _cleanHtml(rawDesc) : null,
      domain: domain,
      faviconUrl: favicon,
      previewImageUrl: previewImg,
    );
  }

  static String _cleanHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static void clearCache() {
    _cache.clear();
  }
}
