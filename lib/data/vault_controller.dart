import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/sli_theme.dart';
import '../domain/vault_item.dart';
import 'article_snapshot_service.dart';
import 'backup_service.dart';
import 'local_image_storage.dart';
import 'vault_database.dart';

class VaultIntegrityReport {
  final int totalDatabaseItems;
  final int validImageFiles;
  final int missingImageFiles;
  final int orphanedImageFiles;

  const VaultIntegrityReport({
    required this.totalDatabaseItems,
    required this.validImageFiles,
    required this.missingImageFiles,
    required this.orphanedImageFiles,
  });

  bool get isHealthy => missingImageFiles == 0 && orphanedImageFiles == 0;
}

class VaultController extends ChangeNotifier {
  static const String _prefOnboardingDone = 'sli_vault_onboarding_completed_v1';
  static const String _prefCollections = 'sli_vault_custom_collections_v1';
  static const String _prefThemeMode = 'sli_vault_theme_mode_v1';
  static const String _prefVisualStyle = 'sli_vault_visual_style_v1';
  static const String _prefLockEnabled = 'sli_vault_lock_enabled_v1';
  static const String _prefAccentPreset = 'sli_vault_accent_preset_v1';
  static const String _prefAtmosphereEnabled =
      'sli_vault_atmosphere_enabled_v1';
  static const String _prefLockTimeout = 'sli_vault_lock_timeout_v1';
  static const String _prefDefaultStartupTab =
      'sli_vault_default_startup_tab_v1';
  static const String _prefDefaultBrowseSort =
      'sli_vault_default_browse_sort_v1';
  static const String _prefInAppBrowser = 'sli_vault_in_app_browser_v1';
  static const String _prefHapticsEnabled = 'sli_vault_haptics_enabled_v1';
  static const String _prefReduceMotion = 'sli_vault_reduce_motion_v1';
  static const String _prefAutoFetchMetadata =
      'sli_vault_auto_fetch_metadata_v1';
  static const String _prefBrowseDensity = 'sli_vault_browse_density_v1';
  static const String _prefScreenProtection = 'sli_vault_screen_protection_v1';
  static const String _prefProfileName = 'sli_vault_profile_name_v1';
  static const String _prefProfilePhoto = 'sli_vault_profile_photo_v1';
  static const String _prefPinnedItems = 'sli_vault_pinned_items_v1';

  final VaultDatabase database;
  final LocalImageStorage imageStorage;
  late final VaultBackupService backupService;
  late final ArticleSnapshotService snapshotService;
  final Uuid _uuid = const Uuid();

  List<VaultItem> _allItems = const [];
  bool _isInitialized = false;
  bool _onboardingCompleted = false;
  bool _isBusy = false;
  Set<String> _customCollections = {'General'};
  Set<String> _pinnedItemIds = {};
  String _themeModeName = 'dark';
  SliVisualStyle _visualStyle = SliVisualStyle.classic;
  bool _lockEnabled = false;
  bool _isLocked = false;
  String _accentPreset = 'orange';
  bool _atmosphereEnabled = true;
  int _lockTimeoutSeconds = 0;
  int _defaultStartupTab = 0;
  VaultSortOption _defaultBrowseSort = VaultSortOption.newestFirst;
  bool _inAppBrowser = false;
  bool _hapticsEnabled = true;
  bool _reduceMotion = false;
  bool _autoFetchMetadata = true;
  String _browseDensity = 'comfortable';
  bool _screenProtectionEnabled = true;
  String _profileName = 'Inlitx';
  String _profilePhotoPath = '';
  final Map<String, (VaultItem item, Uint8List? imageBytes, bool wasPinned)>
  _undoCache = {};
  final Map<
    String,
    List<(VaultItem item, Uint8List? imageBytes, bool wasPinned)>
  >
  _batchUndoCache = {};

  // UI Filter / Sort / Layout state
  VaultTypeFilter _homeFilter = VaultTypeFilter.all;
  VaultTypeFilter _browseFilter = VaultTypeFilter.all;
  VaultTypeFilter _favoritesFilter = VaultTypeFilter.all;
  VaultSortOption _browseSort = VaultSortOption.newestFirst;
  bool _browseGridView = false;
  String _searchQuery = '';
  int _approxStorageBytes = 0;

  VaultController({
    required this.database,
    required this.imageStorage,
    ArticleSnapshotService? snapshotService,
  }) {
    backupService = VaultBackupService(
      database: database,
      imageStorage: imageStorage,
    );
    this.snapshotService = snapshotService ?? const ArticleSnapshotService();
  }

  bool get isInitialized => _isInitialized;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isBusy => _isBusy;
  List<VaultItem> get allItems => _allItems;
  VaultTypeFilter get homeFilter => _homeFilter;
  VaultTypeFilter get browseFilter => _browseFilter;
  VaultTypeFilter get favoritesFilter => _favoritesFilter;
  VaultSortOption get browseSort => _browseSort;
  bool get browseGridView => _browseGridView;
  String get searchQuery => _searchQuery;
  int get approxStorageBytes => _approxStorageBytes;
  String get themeModeName => _themeModeName;
  SliVisualStyle get visualStyle => _visualStyle;
  bool get lockEnabled => _lockEnabled;
  bool get isLocked => _isLocked;
  String get accentPreset => _accentPreset;
  bool get atmosphereEnabled => _atmosphereEnabled;
  int get lockTimeoutSeconds => _lockTimeoutSeconds;
  int get defaultStartupTab => _defaultStartupTab;
  VaultSortOption get defaultBrowseSort => _defaultBrowseSort;
  bool get inAppBrowser => _inAppBrowser;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get reduceMotion => _reduceMotion;
  bool get autoFetchMetadata => _autoFetchMetadata;
  String get browseDensity => _browseDensity;
  bool get screenProtectionEnabled => _screenProtectionEnabled;
  String get profileName => _profileName;
  String get profilePhotoPath => _profilePhotoPath;
  Set<String> get pinnedItemIds => Set.unmodifiable(_pinnedItemIds);
  bool isItemPinned(String id) => _pinnedItemIds.contains(id);

  List<String> get collections {
    final names = <String>{'General', ..._customCollections};
    names.addAll(_allItems.map((item) => item.collection));
    final sorted = names.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  /// Loads prefs + library. Loading-art hold time is owned by `_VaultBootGate`
  /// in `main.dart` so the first painted frame is the rotating owner arts.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool(_prefOnboardingDone) ?? false;
    _customCollections = {
      'General',
      ...(prefs.getStringList(_prefCollections) ?? const <String>[]),
    };
    _pinnedItemIds = (prefs.getStringList(_prefPinnedItems) ?? const <String>[])
        .toSet();
    _themeModeName = prefs.getString(_prefThemeMode) ?? 'dark';
    final styleName = prefs.getString(_prefVisualStyle);
    _visualStyle = SliVisualStyle.values.firstWhere(
      (s) => s.name == styleName,
      orElse: () => SliVisualStyle.classic,
    );
    _lockEnabled = prefs.getBool(_prefLockEnabled) ?? false;
    _accentPreset = prefs.getString(_prefAccentPreset) ?? 'orange';
    _atmosphereEnabled = prefs.getBool(_prefAtmosphereEnabled) ?? true;
    _lockTimeoutSeconds = prefs.getInt(_prefLockTimeout) ?? 0;
    _defaultStartupTab = prefs.getInt(_prefDefaultStartupTab) ?? 0;
    final sortName = prefs.getString(_prefDefaultBrowseSort);
    _defaultBrowseSort = VaultSortOption.values.firstWhere(
      (s) => s.name == sortName,
      orElse: () => VaultSortOption.newestFirst,
    );
    _browseSort = _defaultBrowseSort;
    _inAppBrowser = prefs.getBool(_prefInAppBrowser) ?? false;
    _hapticsEnabled = prefs.getBool(_prefHapticsEnabled) ?? true;
    _reduceMotion = prefs.getBool(_prefReduceMotion) ?? false;
    _autoFetchMetadata = prefs.getBool(_prefAutoFetchMetadata) ?? true;
    _browseDensity = prefs.getString(_prefBrowseDensity) ?? 'comfortable';
    _screenProtectionEnabled = prefs.getBool(_prefScreenProtection) ?? true;
    _profileName = prefs.getString(_prefProfileName) ?? 'Inlitx';
    _profilePhotoPath = prefs.getString(_prefProfilePhoto) ?? '';
    if (Platform.isAndroid) {
      try {
        const MethodChannel('sli_vault/security').invokeMethod(
          'setScreenProtection',
          {'enabled': _screenProtectionEnabled},
        );
      } catch (_) {}
    }
    await reloadLibrary();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setProfileName(String name) async {
    final trimmed = name.trim();
    _profileName = trimmed.isEmpty ? 'Inlitx' : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefProfileName, _profileName);
    notifyListeners();
  }

  Future<void> setProfilePhotoPath(String path) async {
    _profilePhotoPath = path.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefProfilePhoto, _profilePhotoPath);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    if (_pinnedItemIds.contains(id)) {
      _pinnedItemIds.remove(id);
    } else {
      _pinnedItemIds.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefPinnedItems, _pinnedItemIds.toList());
    notifyListeners();
  }

  Future<void> setPinned(String id, bool pinned) async {
    if (pinned) {
      _pinnedItemIds.add(id);
    } else {
      _pinnedItemIds.remove(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefPinnedItems, _pinnedItemIds.toList());
    notifyListeners();
  }

  Future<void> setScreenProtectionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefScreenProtection, enabled);
    _screenProtectionEnabled = enabled;
    if (Platform.isAndroid) {
      try {
        const MethodChannel('sli_vault/security')
            .invokeMethod('setScreenProtection', {'enabled': enabled});
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOnboardingDone, true);
    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> setThemeModeName(String name) async {
    final normalized = {'dark', 'light', 'system', 'amoled'}.contains(name)
        ? name
        : 'dark';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, normalized);
    _themeModeName = normalized;
    notifyListeners();
  }

  Future<void> setVisualStyle(SliVisualStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefVisualStyle, style.name);
    _visualStyle = style;
    notifyListeners();
  }

  Future<void> setAccentPreset(String preset) async {
    final normalized =
        {'orange', 'amber', 'teal', 'violet', 'coral'}.contains(preset)
        ? preset
        : 'orange';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefAccentPreset, normalized);
    _accentPreset = normalized;
    notifyListeners();
  }

  Future<void> setAtmosphereEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAtmosphereEnabled, enabled);
    _atmosphereEnabled = enabled;
    notifyListeners();
  }

  Future<void> setLockTimeoutSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefLockTimeout, seconds);
    _lockTimeoutSeconds = seconds;
    notifyListeners();
  }

  Future<void> setDefaultStartupTab(int tabIndex) async {
    final normalized = tabIndex.clamp(0, 3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefDefaultStartupTab, normalized);
    _defaultStartupTab = normalized;
    notifyListeners();
  }

  Future<void> setDefaultBrowseSort(VaultSortOption sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefDefaultBrowseSort, sort.name);
    _defaultBrowseSort = sort;
    _browseSort = sort;
    notifyListeners();
  }

  Future<void> setInAppBrowser(bool inApp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefInAppBrowser, inApp);
    _inAppBrowser = inApp;
    notifyListeners();
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefHapticsEnabled, enabled);
    _hapticsEnabled = enabled;
    notifyListeners();
  }

  Future<void> setReduceMotion(bool reduce) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefReduceMotion, reduce);
    _reduceMotion = reduce;
    notifyListeners();
  }

  Future<void> setAutoFetchMetadata(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoFetchMetadata, enabled);
    _autoFetchMetadata = enabled;
    notifyListeners();
  }

  Future<void> setBrowseDensity(String density) async {
    final normalized = density == 'compact' ? 'compact' : 'comfortable';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefBrowseDensity, normalized);
    _browseDensity = normalized;
    notifyListeners();
  }

  Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLockEnabled, enabled);
    _lockEnabled = enabled;
    _isLocked = false;
    notifyListeners();
  }

  Future<void> lockVault() async {
    if (!_lockEnabled) return;
    _isLocked = true;
    notifyListeners();
  }

  void unlockVault() {
    _isLocked = false;
    notifyListeners();
  }

  Future<void> reopenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOnboardingDone, false);
    _onboardingCompleted = false;
    notifyListeners();
  }

  Future<void> reloadLibrary() async {
    _allItems = await database.getAllItems();
    final imgBytes = await imageStorage.calculateTotalImageBytes();
    final dbBytes = await database.getDatabaseFileSizeBytes();
    _approxStorageBytes = imgBytes + dbBytes;
    notifyListeners();
  }

  Future<void> vacuumDatabase() async {
    await database.vacuum();
    await reloadLibrary();
  }

  Future<int> clearTemporaryCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) return 0;
      int bytesFreed = 0;
      await for (final entity in tempDir.list(followLinks: false)) {
        if (entity is File) {
          try {
            final len = await entity.length();
            await entity.delete();
            bytesFreed += len;
          } catch (_) {}
        }
      }
      await reloadLibrary();
      return bytesFreed;
    } catch (_) {
      return 0;
    }
  }

  Future<VaultIntegrityReport> checkIntegrity() async {
    final activeIds = await database.getActiveReferencedImageIds();
    int missing = 0;
    int valid = 0;
    for (final id in activeIds) {
      final f = await imageStorage.resolveImageFile(id);
      if (f != null && await f.exists()) {
        valid++;
      } else {
        missing++;
      }
    }
    final allStored = await imageStorage.listAllStoredImageIds();
    int orphaned = 0;
    for (final id in allStored) {
      if (!activeIds.contains(id)) {
        orphaned++;
      }
    }
    return VaultIntegrityReport(
      totalDatabaseItems: _allItems.length,
      validImageFiles: valid,
      missingImageFiles: missing,
      orphanedImageFiles: orphaned,
    );
  }

  Future<int> cleanOrphanedImages() async {
    final activeIds = await database.getActiveReferencedImageIds();
    final count = await imageStorage.cleanOrphanedImages(activeIds);
    await reloadLibrary();
    return count;
  }

  void setHomeFilter(VaultTypeFilter filter) {
    if (_homeFilter == filter) return;
    _homeFilter = filter;
    notifyListeners();
  }

  void setBrowseFilter(VaultTypeFilter filter) {
    if (_browseFilter == filter) return;
    _browseFilter = filter;
    notifyListeners();
  }

  void setFavoritesFilter(VaultTypeFilter filter) {
    if (_favoritesFilter == filter) return;
    _favoritesFilter = filter;
    notifyListeners();
  }

  void setBrowseSort(VaultSortOption sort) {
    if (_browseSort == sort) return;
    _browseSort = sort;
    notifyListeners();
  }

  void toggleBrowseLayout() {
    _browseGridView = !_browseGridView;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Number of items under [filter]. When [query] is non-empty the count only
  /// includes items that also match the search, so chip counts always agree
  /// with the list that is shown.
  int countByFilter(
    VaultTypeFilter filter, {
    bool favoritesOnly = false,
    String query = '',
  }) {
    return _allItems.where((item) {
      if (favoritesOnly && !item.isFavorite) return false;
      return filter.matches(item.type) && item.matchesSearch(query);
    }).length;
  }

  List<VaultItem> get homeFilteredItems {
    final list = _allItems
        .where((item) => _homeFilter.matches(item.type))
        .toList();
    list.sort((a, b) {
      final aPin = isItemPinned(a.id);
      final bPin = isItemPinned(b.id);
      if (aPin != bPin) return aPin ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<VaultItem> getBrowseItems({String? queryOverride}) {
    final q = queryOverride ?? _searchQuery;
    final filtered = _allItems.where((item) {
      return _browseFilter.matches(item.type) && item.matchesSearch(q);
    }).toList();

    filtered.sort((a, b) {
      final aPin = isItemPinned(a.id);
      final bPin = isItemPinned(b.id);
      if (aPin != bPin) return aPin ? -1 : 1;
      return switch (_browseSort) {
        VaultSortOption.newestFirst => b.createdAt.compareTo(a.createdAt),
        VaultSortOption.oldestFirst => a.createdAt.compareTo(b.createdAt),
        VaultSortOption.titleAZ => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        VaultSortOption.titleZA => b.title.toLowerCase().compareTo(
          a.title.toLowerCase(),
        ),
      };
    });
    return filtered;
  }

  List<VaultItem> getFavoritesItems({String query = ''}) {
    return _allItems.where((item) {
      return item.isFavorite &&
          _favoritesFilter.matches(item.type) &&
          item.matchesSearch(query);
    }).toList();
  }

  List<VaultItem> searchAdvanced({
    required String query,
    VaultTypeFilter typeFilter = VaultTypeFilter.all,
    String? collection,
    bool onlyFavorites = false,
    VaultSortOption sort = VaultSortOption.newestFirst,
  }) {
    final filtered = _allItems.where((item) {
      if (!typeFilter.matches(item.type)) return false;
      if (onlyFavorites && !item.isFavorite) return false;
      if (collection != null &&
          collection.trim().isNotEmpty &&
          collection != 'All' &&
          item.collection != collection) {
        return false;
      }
      return item.matchesSearch(query);
    }).toList();

    switch (sort) {
      case VaultSortOption.newestFirst:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case VaultSortOption.oldestFirst:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case VaultSortOption.titleAZ:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case VaultSortOption.titleZA:
        filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
    }
    return filtered;
  }

  List<VaultItem> searchAllItems(String query, VaultTypeFilter filter) {
    return searchAdvanced(query: query, typeFilter: filter);
  }

  VaultItem? findById(String id) {
    for (final item in _allItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Checks whether a link with a matching normalized URL already exists in the vault.
  VaultItem? findExistingLink(String rawUrl) {
    final clean = rawUrl.trim().toLowerCase();
    if (clean.isEmpty) return null;
    final normalized = clean.endsWith('/')
        ? clean.substring(0, clean.length - 1)
        : clean;
    for (final item in _allItems) {
      if (item.type == VaultItemType.link && item.url != null) {
        final itemUrl = item.url!.trim().toLowerCase();
        final normItem = itemUrl.endsWith('/')
            ? itemUrl.substring(0, itemUrl.length - 1)
            : itemUrl;
        if (normItem == normalized) {
          return item;
        }
      }
    }
    return null;
  }

  Future<File?> resolveImageFile(String? localImageId) {
    return imageStorage.resolveImageFile(localImageId);
  }

  /// Saves a validated HTTP/HTTPS link item (FR-003).
  Future<VaultItem> addLinkItem({
    required String rawUrl,
    String? customTitle,
    String? description,
    List<String> tags = const [],
    String collection = 'General',
  }) async {
    if (_isBusy) {
      throw StateError('A save operation is already in progress.');
    }
    final validation = VaultValidators.validateAndNormalizeUrl(rawUrl);
    if (!validation.isValid) {
      throw FormatException(validation.errorMessage ?? 'Invalid URL.');
    }

    _isBusy = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final effectiveTitle =
          (customTitle != null && customTitle.trim().isNotEmpty)
          ? customTitle.trim()
          : (validation.domain ?? validation.normalizedUrl!);

      final item = VaultItem(
        id: _uuid.v4(),
        type: VaultItemType.link,
        title: effectiveTitle,
        url: validation.normalizedUrl,
        domain: validation.domain,
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        tags: VaultValidators.normalizeTags(tags),
        isFavorite: false,
        collection: collection.trim().isEmpty ? 'General' : collection.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await database.upsertItem(item);
      await reloadLibrary();
      return item;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Imports an image or screenshot into durable local storage and persists its record (FR-004, FR-014).
  Future<VaultItem> addMediaItem({
    required VaultItemType type,
    required Uint8List imageBytes,
    String? fileNameHint,
    String? customTitle,
    String? description,
    List<String> tags = const [],
    String collection = 'General',
  }) async {
    if (type == VaultItemType.link) {
      throw ArgumentError('Use addLinkItem for link items.');
    }
    if (_isBusy) {
      throw StateError('A save operation is already in progress.');
    }

    _isBusy = true;
    notifyListeners();
    String? savedImageId;
    try {
      savedImageId = await imageStorage.saveImageBytes(
        imageBytes,
        fileNameHint: fileNameHint,
      );
      final now = DateTime.now();
      final fallbackTitle = type == VaultItemType.screenshot
          ? 'Screenshot ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
          : 'Saved Image ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final effectiveTitle =
          (customTitle != null && customTitle.trim().isNotEmpty)
          ? customTitle.trim()
          : fallbackTitle;

      final item = VaultItem(
        id: _uuid.v4(),
        type: type,
        title: effectiveTitle,
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        localImageId: savedImageId,
        fileSizeBytes: imageBytes.length,
        tags: VaultValidators.normalizeTags(tags),
        isFavorite: false,
        collection: collection.trim().isEmpty ? 'General' : collection.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await database.upsertItem(item);
      await reloadLibrary();
      return item;
    } catch (e) {
      if (savedImageId != null) {
        final activeRefs = await database.getActiveReferencedImageIds();
        await imageStorage.deleteImageIfUnused(savedImageId, activeRefs);
      }
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String itemId) async {
    final existing = findById(itemId);
    if (existing == null) return;
    final updated = existing.copyWith(
      isFavorite: !existing.isFavorite,
      updatedAt: DateTime.now(),
    );
    await database.upsertItem(updated);
    await reloadLibrary();
  }

  Future<void> updateItemDetails({
    required String itemId,
    required String newTitle,
    String? newDescription,
    required List<String> newTags,
    String? newCollection,
  }) async {
    final existing = findById(itemId);
    if (existing == null) {
      throw StateError('Item not found.');
    }
    final trimmedTitle = newTitle.trim();
    if (trimmedTitle.isEmpty) {
      throw const FormatException('Title cannot be empty.');
    }
    final cleanedDescription = newDescription?.trim() ?? '';
    final updated = existing.copyWith(
      title: trimmedTitle,
      description: cleanedDescription.isEmpty ? null : cleanedDescription,
      clearDescription: cleanedDescription.isEmpty,
      tags: VaultValidators.normalizeTags(newTags),
      collection: (newCollection != null && newCollection.trim().isNotEmpty)
          ? newCollection.trim()
          : existing.collection,
      updatedAt: DateTime.now(),
    );
    await database.upsertItem(updated);
    await reloadLibrary();
  }

  /// Exports the entire library into a portable ZIP including empty custom collections.
  Future<Uint8List> createBackupArchiveBytes() {
    final customList = _customCollections
        .where((c) => c.trim().isNotEmpty && c.trim() != 'General')
        .toList();
    return backupService.createBackupArchiveBytes(
      customCollections: customList,
    );
  }

  /// Commits an import preview safely, restoring items, images, and custom collections.
  Future<void> commitImportPreview(ImportPreviewSummary preview) async {
    await backupService.commitImportPreview(preview);
    for (final col in preview.customCollectionsToRestore) {
      if (col != 'General' && !_customCollections.contains(col)) {
        _customCollections = {..._customCollections, col};
      }
    }
    await _persistCollections();
    await reloadLibrary();
  }

  Future<void> deleteItem(String itemId) async {
    final existing = findById(itemId);
    if (existing == null) return;
    final imageId = existing.localImageId;
    await database.deleteItemById(itemId);
    if (imageId != null) {
      final activeRefs = await database.getActiveReferencedImageIds(
        excludeItemId: itemId,
      );
      await imageStorage.deleteImageIfUnused(imageId, activeRefs);
    }
    await reloadLibrary();
  }

  Future<VaultItem?> deleteItemWithUndo(String itemId) async {
    final existing = findById(itemId);
    if (existing == null) return null;

    Uint8List? imageBytes;
    final imageId = existing.localImageId;
    if (imageId != null) {
      final file = await imageStorage.resolveImageFile(imageId);
      if (file != null && await file.exists()) {
        try {
          imageBytes = await file.readAsBytes();
        } catch (_) {}
      }
    }
    final wasPinned = isItemPinned(itemId);
    _undoCache[itemId] = (existing, imageBytes, wasPinned);
    if (wasPinned) {
      _pinnedItemIds.remove(itemId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefPinnedItems, _pinnedItemIds.toList());
    }

    await deleteItem(itemId);
    return existing;
  }

  Future<bool> undoDelete(String itemId) async {
    final entry = _undoCache.remove(itemId);
    if (entry == null) return false;

    final item = entry.$1;
    final bytes = entry.$2;
    final wasPinned = entry.$3;

    if (bytes != null && item.localImageId != null) {
      await imageStorage.saveImageBytes(
        bytes,
        explicitImageId: item.localImageId,
      );
    }

    if (findById(item.id) == null) {
      await database.upsertItem(item);
    }
    if (wasPinned) {
      _pinnedItemIds.add(item.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefPinnedItems, _pinnedItemIds.toList());
    }
    await reloadLibrary();
    return true;
  }

  Future<void> bulkSetFavorite(List<String> ids, bool isFavorite) async {
    if (ids.isEmpty) return;
    await database.updateFavorites(ids, isFavorite);
    await reloadLibrary();
  }

  Future<void> bulkMoveToCollection(
    List<String> ids,
    String targetCollection,
  ) async {
    if (ids.isEmpty) return;
    final normalized = targetCollection.trim().isEmpty
        ? 'General'
        : targetCollection.trim();
    await database.updateCollections(ids, normalized);
    await reloadLibrary();
  }

  Future<int> bulkDeleteItems(List<String> ids) async {
    if (ids.isEmpty) return 0;
    int count = 0;
    for (final id in ids) {
      final existing = findById(id);
      if (existing != null) {
        await deleteItem(id);
        count++;
      }
    }
    return count;
  }

  Future<String> bulkDeleteWithUndo(List<String> ids) async {
    if (ids.isEmpty) return '';
    final batchId = _uuid.v4();
    final batchEntries = <(VaultItem, Uint8List?, bool)>[];

    for (final id in ids) {
      final existing = findById(id);
      if (existing == null) continue;

      Uint8List? imageBytes;
      final imageId = existing.localImageId;
      if (imageId != null) {
        final file = await imageStorage.resolveImageFile(imageId);
        if (file != null && await file.exists()) {
          try {
            imageBytes = await file.readAsBytes();
          } catch (_) {}
        }
      }
      final wasPinned = isItemPinned(id);
      batchEntries.add((existing, imageBytes, wasPinned));
    }

    _batchUndoCache[batchId] = batchEntries;

    for (final id in ids) {
      _pinnedItemIds.remove(id);
      await deleteItem(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefPinnedItems, _pinnedItemIds.toList());

    return batchId;
  }

  Future<int> undoBulkDelete(String batchId) async {
    final entries = _batchUndoCache.remove(batchId);
    if (entries == null || entries.isEmpty) return 0;

    int restoredCount = 0;
    for (final entry in entries) {
      final item = entry.$1;
      final bytes = entry.$2;
      final wasPinned = entry.$3;

      if (bytes != null && item.localImageId != null) {
        await imageStorage.saveImageBytes(
          bytes,
          explicitImageId: item.localImageId,
        );
      }

      if (findById(item.id) == null) {
        await database.upsertItem(item);
        if (wasPinned) {
          _pinnedItemIds.add(item.id);
        }
        restoredCount++;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefPinnedItems, _pinnedItemIds.toList());
    await reloadLibrary();
    return restoredCount;
  }

  Future<Uint8List> exportSelectedItems(List<String> ids) async {
    final selected = _allItems.where((item) => ids.contains(item.id)).toList();
    if (selected.isEmpty) {
      throw StateError('No items selected for export.');
    }
    return backupService.createBackupArchiveBytes(itemsOverride: selected);
  }

  /// Removes every item and stored image and also forgets user-created
  /// collection names, so the vault returns to a clean "General only" state.
  /// Theme, lock and onboarding preferences are intentionally left untouched.
  Future<void> clearAllVaultData() async {
    await database.clearAllItems();
    await imageStorage.clearAllImages();
    _customCollections = {'General'};
    await _persistCollections();
    await reloadLibrary();
  }

  List<VaultItem> getItemsForCollection(String collection) {
    return _allItems.where((item) => item.collection == collection).toList();
  }

  Future<void> createCollection(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty || name.toLowerCase() == 'general') {
      throw const FormatException('Choose a unique collection name.');
    }
    if (collections.any(
      (existing) => existing.toLowerCase() == name.toLowerCase(),
    )) {
      throw const FormatException('That collection already exists.');
    }
    _customCollections = {..._customCollections, name};
    await _persistCollections();
    notifyListeners();
  }

  Future<void> renameCollection(String oldName, String rawNewName) async {
    final newName = rawNewName.trim();
    if (oldName == 'General' ||
        newName.isEmpty ||
        newName.toLowerCase() == 'general') {
      throw const FormatException('General cannot be renamed.');
    }
    if (collections.any(
      (name) => name != oldName && name.toLowerCase() == newName.toLowerCase(),
    )) {
      throw const FormatException('That collection already exists.');
    }
    final ids = getItemsForCollection(oldName).map((item) => item.id).toList();
    if (ids.isNotEmpty) await database.updateCollections(ids, newName);
    _customCollections = {..._customCollections}
      ..remove(oldName)
      ..add(newName);
    await _persistCollections();
    await reloadLibrary();
  }

  Future<void> deleteCollection(String name) async {
    if (name == 'General') {
      throw const FormatException('General cannot be deleted.');
    }
    final ids = getItemsForCollection(name).map((item) => item.id).toList();
    if (ids.isNotEmpty) await database.updateCollections(ids, 'General');
    _customCollections = {..._customCollections}..remove(name);
    await _persistCollections();
    await reloadLibrary();
  }

  Future<void> moveItemsToCollection(
    List<String> itemIds,
    String rawName,
  ) async {
    final name = rawName.trim().isEmpty ? 'General' : rawName.trim();
    if (name != 'General' && !collections.contains(name)) {
      await createCollection(name);
    }
    if (itemIds.isNotEmpty) await database.updateCollections(itemIds, name);
    await reloadLibrary();
  }

  Future<void> removeItemsFromCollection(List<String> itemIds) {
    return moveItemsToCollection(itemIds, 'General');
  }

  Future<void> _persistCollections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefCollections,
      (_customCollections.where((name) => name != 'General').toList()..sort()),
    );
  }
}
