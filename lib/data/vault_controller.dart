import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/vault_item.dart';
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
  static const String _prefLockEnabled = 'sli_vault_lock_enabled_v1';
  static const String _prefAccentPreset = 'sli_vault_accent_preset_v1';
  static const String _prefAtmosphereEnabled = 'sli_vault_atmosphere_enabled_v1';
  static const String _prefLockTimeout = 'sli_vault_lock_timeout_v1';
  static const String _prefDefaultStartupTab = 'sli_vault_default_startup_tab_v1';
  static const String _prefDefaultBrowseSort = 'sli_vault_default_browse_sort_v1';
  static const String _prefInAppBrowser = 'sli_vault_in_app_browser_v1';
  static const String _prefHapticsEnabled = 'sli_vault_haptics_enabled_v1';
  static const String _prefReduceMotion = 'sli_vault_reduce_motion_v1';

  final VaultDatabase database;
  final LocalImageStorage imageStorage;
  late final VaultBackupService backupService;
  final Uuid _uuid = const Uuid();

  List<VaultItem> _allItems = const [];
  bool _isInitialized = false;
  bool _onboardingCompleted = false;
  bool _isBusy = false;
  Set<String> _customCollections = {'General'};
  String _themeModeName = 'dark';
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

  // UI Filter / Sort / Layout state
  VaultTypeFilter _homeFilter = VaultTypeFilter.all;
  VaultTypeFilter _browseFilter = VaultTypeFilter.all;
  VaultTypeFilter _favoritesFilter = VaultTypeFilter.all;
  VaultSortOption _browseSort = VaultSortOption.newestFirst;
  bool _browseGridView = false;
  String _searchQuery = '';
  int _approxStorageBytes = 0;

  VaultController({required this.database, required this.imageStorage}) {
    backupService = VaultBackupService(
      database: database,
      imageStorage: imageStorage,
    );
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
    _themeModeName = prefs.getString(_prefThemeMode) ?? 'dark';
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
    await reloadLibrary();
    _isInitialized = true;
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
    return _allItems.where((item) => _homeFilter.matches(item.type)).toList();
  }

  List<VaultItem> getBrowseItems({String? queryOverride}) {
    final q = queryOverride ?? _searchQuery;
    final filtered = _allItems.where((item) {
      return _browseFilter.matches(item.type) && item.matchesSearch(q);
    }).toList();

    switch (_browseSort) {
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
    }
    return filtered;
  }

  List<VaultItem> getFavoritesItems({String query = ''}) {
    return _allItems.where((item) {
      return item.isFavorite &&
          _favoritesFilter.matches(item.type) &&
          item.matchesSearch(query);
    }).toList();
  }

  List<VaultItem> searchAllItems(String query, VaultTypeFilter filter) {
    return _allItems.where((item) {
      return filter.matches(item.type) && item.matchesSearch(query);
    }).toList();
  }

  VaultItem? findById(String id) {
    for (final item in _allItems) {
      if (item.id == id) return item;
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
