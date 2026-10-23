import 'dart:convert';

import '../core/assets/sli_assets.dart';

enum VaultItemType {
  link,
  screenshot,
  image,
  note;

  String get label {
    switch (this) {
      case VaultItemType.link:
        return 'Link';
      case VaultItemType.screenshot:
        return 'Screenshot';
      case VaultItemType.image:
        return 'Image';
      case VaultItemType.note:
        return 'Note';
    }
  }

  String get iconAsset {
    switch (this) {
      case VaultItemType.link:
        return SliAssets.contentLink;
      case VaultItemType.screenshot:
        return SliAssets.contentScreenshot;
      case VaultItemType.image:
        return SliAssets.contentImage;
      case VaultItemType.note:
        return SliAssets.contentLayers;
    }
  }

  static VaultItemType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'note':
      case 'snippet':
        return VaultItemType.note;
      case 'screenshot':
        return VaultItemType.screenshot;
      case 'image':
        return VaultItemType.image;
      case 'link':
      default:
        return VaultItemType.link;
    }
  }
}

/// User-facing grouping. Stored [VaultItemType] strings (`link`, `screenshot`,
/// `image`, `note`) are never rewritten.
enum VaultTypeFilter {
  all('All', SliAssets.contentLayers),
  links('Links', SliAssets.contentLink),
  images('Images', SliAssets.contentImage),
  notes('Notes', SliAssets.contentLayers);

  final String label;
  final String iconAsset;
  const VaultTypeFilter(this.label, this.iconAsset);

  bool matches(VaultItemType type) {
    switch (this) {
      case VaultTypeFilter.all:
        return true;
      case VaultTypeFilter.links:
        return type == VaultItemType.link;
      case VaultTypeFilter.images:
        return type == VaultItemType.image || type == VaultItemType.screenshot;
      case VaultTypeFilter.notes:
        return type == VaultItemType.note;
    }
  }
}

enum VaultSortOption {
  newestFirst('Recently saved'),
  oldestFirst('Oldest first'),
  titleAZ('Title A-Z'),
  titleZA('Title Z-A');

  final String label;
  const VaultSortOption(this.label);
}

class UrlValidatorResult {
  final bool isValid;
  final String? normalizedUrl;
  final String? domain;
  final String? errorMessage;

  const UrlValidatorResult({
    required this.isValid,
    this.normalizedUrl,
    this.domain,
    this.errorMessage,
  });
}

class VaultValidators {
  VaultValidators._();

  /// Conservative HTTP/HTTPS URL validator & normalizer (FR-003).
  static UrlValidatorResult validateAndNormalizeUrl(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return const UrlValidatorResult(
        isValid: false,
        errorMessage: 'Enter a valid HTTP or HTTPS URL.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      return const UrlValidatorResult(
        isValid: false,
        errorMessage: 'Include http:// or https:// at the start of the URL.',
      );
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return const UrlValidatorResult(
        isValid: false,
        errorMessage: 'Only HTTP and HTTPS links are supported.',
      );
    }

    final host = uri.host.trim().toLowerCase();
    if (host.isEmpty || !host.contains('.') && host != 'localhost') {
      return const UrlValidatorResult(
        isValid: false,
        errorMessage: 'URL must include a valid domain name.',
      );
    }

    final normalizedDomain = host.startsWith('www.') ? host.substring(4) : host;
    return UrlValidatorResult(
      isValid: true,
      normalizedUrl: trimmed,
      domain: normalizedDomain.isEmpty ? host : normalizedDomain,
    );
  }

  /// Normalizes tags: trims whitespace, removes empties, deduplicates case-insensitively (FR-011).
  static List<String> normalizeTags(Iterable<String> rawTags) {
    final seenLower = <String>{};
    final result = <String>[];
    for (final raw in rawTags) {
      final cleaned = raw.trim();
      if (cleaned.isEmpty) continue;
      final lower = cleaned.toLowerCase();
      if (seenLower.add(lower)) {
        result.add(cleaned);
      }
    }
    return result;
  }

  static List<String> parseTagInput(String input) {
    if (input.trim().isEmpty) return const [];
    return normalizeTags(input.split(','));
  }

  /// Extracts an HTTP/HTTPS URL from arbitrary shared text, returning
  /// the extracted URL and any surrounding text that can serve as title or notes.
  static ({String? url, String? remainingText}) extractUrlFromText(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return (url: null, remainingText: null);
    }
    // Check if the entire string is a valid URL first
    final direct = validateAndNormalizeUrl(trimmed);
    if (direct.isValid) {
      return (url: direct.normalizedUrl, remainingText: null);
    }
    // Search for embedded http:// or https:// URL
    final urlRegex = RegExp(r'https?://[^\s<>"]+');
    final match = urlRegex.firstMatch(trimmed);
    if (match != null) {
      final candidate = match.group(0)!;
      final check = validateAndNormalizeUrl(candidate);
      if (check.isValid) {
        final remaining = trimmed
            .replaceFirst(candidate, '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        return (
          url: check.normalizedUrl,
          remainingText: remaining.isEmpty ? null : remaining,
        );
      }
    }
    return (url: null, remainingText: trimmed);
  }
}

class VaultItem {
  final String id;
  final VaultItemType type;
  final String title;
  final String? url;
  final String? domain;
  final String? description;
  final String? localImageId;
  final String? thumbnailId;
  final List<String> tags;
  final bool isFavorite;
  final String collection;
  final int fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultItem({
    required this.id,
    required this.type,
    required this.title,
    this.url,
    this.domain,
    this.description,
    this.localImageId,
    this.thumbnailId,
    this.tags = const [],
    this.isFavorite = false,
    this.collection = 'General',
    this.fileSizeBytes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns a copy with the given fields replaced. A `null` argument keeps
  /// the existing value; pass [clearDescription] to explicitly remove it.
  VaultItem copyWith({
    String? title,
    String? url,
    String? domain,
    String? description,
    bool clearDescription = false,
    String? localImageId,
    String? thumbnailId,
    List<String>? tags,
    bool? isFavorite,
    String? collection,
    int? fileSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultItem(
      id: id,
      type: type,
      title: title ?? this.title,
      url: url ?? this.url,
      domain: domain ?? this.domain,
      description: clearDescription ? null : (description ?? this.description),
      localImageId: localImageId ?? this.localImageId,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      tags: tags != null ? VaultValidators.normalizeTags(tags) : this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      collection: collection ?? this.collection,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isNote => type == VaultItemType.note;
  bool get isLink => type == VaultItemType.link;
  bool get isImage =>
      type == VaultItemType.image || type == VaultItemType.screenshot;
  String? get thumbnailUrl => thumbnailId;

  String get domainHost {
    if (domain != null && domain!.isNotEmpty) return domain!;
    if (url != null) {
      final uri = Uri.tryParse(url!);
      if (uri != null && uri.host.isNotEmpty) {
        return uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
      }
    }
    return '';
  }

  int get readingTimeMinutes {
    final text = '$title ${description ?? ''}';
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (words / 180).ceil().clamp(1, 60);
  }

  bool matchesSearch(String rawQuery) {
    final tokens = rawQuery
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return true;

    final searchable = [
      title,
      type.label,
      url ?? '',
      domain ?? '',
      description ?? '',
      tags.join(' '),
      collection,
    ].join(' ').toLowerCase();
    return tokens.every(searchable.contains);
  }

  Map<String, Object?> toDbMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'url': url,
      'domain': domain,
      'description': description,
      'local_image_id': localImageId,
      'thumbnail_id': thumbnailId,
      'tags_json': jsonEncode(tags),
      'is_favorite': isFavorite ? 1 : 0,
      'collection': collection,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory VaultItem.fromDbMap(Map<String, Object?> map) {
    final rawTags = map['tags_json'] as String?;
    List<String> parsedTags = const [];
    if (rawTags != null && rawTags.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTags);
        if (decoded is List) {
          parsedTags = VaultValidators.normalizeTags(
            decoded.map((e) => e.toString()),
          );
        }
      } catch (_) {
        parsedTags = const [];
      }
    }

    return VaultItem(
      id: map['id'] as String,
      type: VaultItemType.fromString(map['type'] as String? ?? 'link'),
      title: (map['title'] as String? ?? '').trim(),
      url: map['url'] as String?,
      domain: map['domain'] as String?,
      description: (map['description'] as String?)?.trim(),
      localImageId: map['local_image_id'] as String?,
      thumbnailId: map['thumbnail_id'] as String?,
      tags: parsedTags,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      collection: ((map['collection'] as String?) ?? 'General').trim().isEmpty
          ? 'General'
          : (map['collection'] as String?)!.trim(),
      fileSizeBytes: (map['file_size_bytes'] as int?) ?? 0,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  Map<String, Object?> toBackupJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'url': url,
      'domain': domain,
      'description': description,
      'localImageId': localImageId,
      'thumbnailId': thumbnailId,
      'tags': tags,
      'isFavorite': isFavorite,
      'collection': collection,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  static VaultItem? tryFromBackupJson(Map<String, Object?> json) {
    final id = (json['id'] as String?)?.trim();
    final typeRaw = (json['type'] as String?)?.trim();
    final title = (json['title'] as String?)?.trim();
    if (id == null ||
        id.isEmpty ||
        typeRaw == null ||
        title == null ||
        title.isEmpty) {
      return null;
    }
    if (!const {
      'link',
      'screenshot',
      'image',
    }.contains(typeRaw.toLowerCase())) {
      return null;
    }
    final type = VaultItemType.fromString(typeRaw);
    String? url = (json['url'] as String?)?.trim();
    String? domain = (json['domain'] as String?)?.trim();
    if (type == VaultItemType.link) {
      if (url == null || url.isEmpty) return null;
      final v = VaultValidators.validateAndNormalizeUrl(url);
      if (!v.isValid) return null;
      url = v.normalizedUrl;
      domain = v.domain;
    } else {
      url = null;
      domain = null;
    }

    final localImageId = (json['localImageId'] as String?)?.trim();
    if (type != VaultItemType.link &&
        (localImageId == null || localImageId.isEmpty)) {
      return null;
    }

    final rawTags = json['tags'];
    final tags = rawTags is List
        ? VaultValidators.normalizeTags(rawTags.map((e) => e.toString()))
        : const <String>[];

    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '');
    if (createdAt == null || updatedAt == null) return null;
    final collection = (json['collection'] as String?)?.trim();

    return VaultItem(
      id: id,
      type: type,
      title: title,
      url: url,
      domain: domain,
      description: (json['description'] as String?)?.trim(),
      localImageId: localImageId,
      thumbnailId: (json['thumbnailId'] as String?)?.trim(),
      tags: tags,
      isFavorite: json['isFavorite'] == true,
      collection: collection == null || collection.isEmpty
          ? 'General'
          : collection,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: createdAt.toLocal(),
      updatedAt: updatedAt.toLocal(),
    );
  }

  static VaultItem? tryFromKotlinJson(Map<String, Object?> json) {
    final id = (json['id'] as String?)?.trim();
    final title = (json['title'] as String?)?.trim();
    final typeRaw = (json['type'] as String?)?.trim();
    if (id == null ||
        id.isEmpty ||
        title == null ||
        title.isEmpty ||
        typeRaw == null) {
      return null;
    }

    final type = VaultItemType.fromString(typeRaw);
    final urlValue = (json['url'] as String?)?.trim();
    final domainValue = (json['domain'] as String?)?.trim();
    final tagsValue = json['tags'];
    final tags = tagsValue is String
        ? VaultValidators.normalizeTags(tagsValue.split(','))
        : tagsValue is List
        ? VaultValidators.normalizeTags(
            tagsValue.map((value) => value.toString()),
          )
        : const <String>[];
    final createdAt = _kotlinTimestamp(json['createdAt']);
    final updatedAt = _kotlinTimestamp(json['updatedAt']);
    if (createdAt == null || updatedAt == null) return null;
    final collection = (json['collection'] as String?)?.trim();

    if (type == VaultItemType.link) {
      if (urlValue == null ||
          !VaultValidators.validateAndNormalizeUrl(urlValue).isValid) {
        return null;
      }
    }

    return VaultItem(
      id: id,
      type: type,
      title: title,
      url: type == VaultItemType.link ? urlValue : null,
      domain: type == VaultItemType.link ? domainValue : null,
      description: (json['description'] as String?)?.trim(),
      localImageId: null,
      thumbnailId: null,
      tags: tags,
      isFavorite: json['isFavorite'] == true,
      collection: collection == null || collection.isEmpty
          ? 'General'
          : collection,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _kotlinTimestamp(Object? value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
    }
    return DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  }
}
