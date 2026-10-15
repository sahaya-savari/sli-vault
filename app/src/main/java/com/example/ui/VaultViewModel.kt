package com.example.ui

import android.app.Application
import android.net.Uri
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.ItemType
import com.example.data.StorageStats
import com.example.data.VaultDatabase
import com.example.data.VaultItem
import com.example.data.VaultRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

enum class SortOption(val label: String) {
    NEWEST("Newest"),
    OLDEST("Oldest"),
    TITLE_AZ("Title A-Z"),
    FAVORITES("Favorites First")
}

enum class ThemeMode {
    DARK,
    LIGHT,
    SYSTEM
}

class VaultViewModel(application: Application) : AndroidViewModel(application) {
    private val repository: VaultRepository

    init {
        val database = VaultDatabase.getDatabase(application)
        repository = VaultRepository(application, database.vaultItemDao())
    }

    // Search & Filter State
    private val _searchQuery = MutableStateFlow("")
    val searchQuery = _searchQuery.asStateFlow()

    private val _selectedTypeFilter = MutableStateFlow<ItemType?>(null) // null = ALL
    val selectedTypeFilter = _selectedTypeFilter.asStateFlow()

    private val _sortOption = MutableStateFlow(SortOption.NEWEST)
    val sortOption = _sortOption.asStateFlow()

    private val _selectedCollection = MutableStateFlow<String?>(null)
    val selectedCollection = _selectedCollection.asStateFlow()

    // Navigation / Active Item State
    private val _selectedItem = MutableStateFlow<VaultItem?>(null)
    val selectedItem = _selectedItem.asStateFlow()

    private val _isAddSheetOpen = MutableStateFlow(false)
    val isAddSheetOpen = _isAddSheetOpen.asStateFlow()

    private val _addInitialType = MutableStateFlow(ItemType.LINK)
    val addInitialType = _addInitialType.asStateFlow()

    private val _prefilledUrl = MutableStateFlow<String?>(null)
    val prefilledUrl = _prefilledUrl.asStateFlow()

    private val _prefilledImageUri = MutableStateFlow<Uri?>(null)
    val prefilledImageUri = _prefilledImageUri.asStateFlow()

    // Preferences (Loaded synchronously from persistent storage)
    private val _themeMode = MutableStateFlow(
        try {
            ThemeMode.valueOf(repository.getThemeModeName())
        } catch (e: Exception) {
            ThemeMode.DARK
        }
    )
    val themeMode = _themeMode.asStateFlow()

    private val _isOnboardingCompleted = MutableStateFlow(repository.isOnboardingCompleted())
    val isOnboardingCompleted = _isOnboardingCompleted.asStateFlow()

    private val _isVaultLockEnabled = MutableStateFlow(repository.isVaultLockEnabled())
    val isVaultLockEnabled = _isVaultLockEnabled.asStateFlow()

    private val _isVaultLocked = MutableStateFlow(repository.isVaultLockEnabled())
    val isVaultLocked = _isVaultLocked.asStateFlow()

    private val _vaultLockError = MutableStateFlow<String?>(null)
    val vaultLockError = _vaultLockError.asStateFlow()

    private var lastBackgroundTimestamp = 0L

    private val _storageStats = MutableStateFlow(StorageStats(0, 0))
    val storageStats = _storageStats.asStateFlow()

    private val _userMessage = MutableStateFlow<String?>(null)
    val userMessage = _userMessage.asStateFlow()

    // Base Database Streams
    val allItems: StateFlow<List<VaultItem>> = repository.allItems
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val favoriteItems: StateFlow<List<VaultItem>> = repository.favoriteItems
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val _customCollections = MutableStateFlow(repository.getCustomCollections())

    val distinctCollections: StateFlow<List<String>> = combine(
        repository.getDistinctCollections(),
        _customCollections
    ) { fromDb, custom ->
        (listOf("General") + fromDb + custom).distinct().sorted()
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), listOf("General"))

    // Counts
    val allCount: StateFlow<Int> = repository.itemCount
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val linksCount: StateFlow<Int> = repository.getItemCountByType(ItemType.LINK)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val screenshotsCount: StateFlow<Int> = repository.getItemCountByType(ItemType.SCREENSHOT)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val imagesCount: StateFlow<Int> = repository.getItemCountByType(ItemType.IMAGE)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    // Filtered and Sorted Library with multi-token search and collection matching
    val filteredBrowseItems: StateFlow<List<VaultItem>> = combine(
        allItems,
        _searchQuery,
        _selectedTypeFilter,
        _sortOption,
        _selectedCollection
    ) { items, query, typeFilter, sort, collectionFilter ->
        val filtered = repository.filterItems(
            items = items,
            query = query,
            typeFilter = typeFilter,
            collectionFilter = collectionFilter
        )

        when (sort) {
            SortOption.NEWEST -> filtered.sortedByDescending { it.createdAt }
            SortOption.OLDEST -> filtered.sortedBy { it.createdAt }
            SortOption.TITLE_AZ -> filtered.sortedBy { it.title.lowercase() }
            SortOption.FAVORITES -> filtered.sortedByDescending { it.isFavorite }
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    init {
        refreshStorageStats()
    }

    fun refreshStorageStats() {
        viewModelScope.launch {
            _storageStats.value = repository.getStorageStats()
        }
    }

    fun setSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun setTypeFilter(type: ItemType?) {
        _selectedTypeFilter.value = type
    }

    fun setSortOption(sort: SortOption) {
        _sortOption.value = sort
    }

    fun setSelectedCollection(collection: String?) {
        _selectedCollection.value = collection
    }

    fun createCollection(name: String) {
        val trimmed = name.trim()
        if (trimmed.isNotBlank()) {
            repository.addCustomCollection(trimmed)
            _customCollections.value = repository.getCustomCollections()
            _userMessage.value = "Collection '$trimmed' created"
        }
    }

    fun deleteCollection(name: String) {
        viewModelScope.launch {
            repository.deleteCustomCollection(name)
            _customCollections.value = repository.getCustomCollections()
            if (_selectedCollection.value == name) {
                _selectedCollection.value = null
            }
            _userMessage.value = "Collection '$name' deleted"
        }
    }

    fun renameCollection(oldName: String, newName: String) {
        viewModelScope.launch {
            repository.renameCustomCollection(oldName, newName)
            _customCollections.value = repository.getCustomCollections()
            if (_selectedCollection.value == oldName) {
                _selectedCollection.value = newName.trim()
            }
            _userMessage.value = "Collection renamed to '$newName'"
        }
    }

    fun selectItem(item: VaultItem?) {
        _selectedItem.value = item
    }

    fun openAddSheet(initialType: ItemType = ItemType.LINK, prefilledUrl: String? = null, prefilledImage: Uri? = null) {
        _addInitialType.value = initialType
        _prefilledUrl.value = prefilledUrl
        _prefilledImageUri.value = prefilledImage
        _isAddSheetOpen.value = true
    }

    fun closeAddSheet() {
        _isAddSheetOpen.value = false
        _prefilledUrl.value = null
        _prefilledImageUri.value = null
    }

    fun toggleFavorite(item: VaultItem) {
        viewModelScope.launch {
            repository.toggleFavorite(item.id, item.isFavorite)
            if (_selectedItem.value?.id == item.id) {
                _selectedItem.value = _selectedItem.value?.copy(isFavorite = !item.isFavorite)
            }
        }
    }

    fun saveLink(
        url: String,
        title: String?,
        description: String? = null,
        tags: String = "",
        collection: String = "General"
    ) {
        viewModelScope.launch {
            val result = repository.saveLink(url, title, description, tags, collection)
            if (result.isSuccess) {
                _userMessage.value = "Link saved to vault"
                closeAddSheet()
                refreshStorageStats()
            } else {
                _userMessage.value = "Failed to save link: ${result.exceptionOrNull()?.message}"
            }
        }
    }

    fun saveImageOrScreenshot(
        imageUri: Uri,
        isScreenshot: Boolean,
        title: String?,
        description: String? = null,
        tags: String = "",
        collection: String = "General"
    ) {
        viewModelScope.launch {
            val result = repository.saveImageOrScreenshot(imageUri, isScreenshot, title, description, tags, collection)
            if (result.isSuccess) {
                _userMessage.value = if (isScreenshot) "Screenshot saved" else "Image saved to vault"
                closeAddSheet()
                refreshStorageStats()
            } else {
                _userMessage.value = "Failed to save image: ${result.exceptionOrNull()?.message}"
            }
        }
    }

    fun updateItem(item: VaultItem) {
        viewModelScope.launch {
            repository.updateItem(item)
            if (_selectedItem.value?.id == item.id) {
                _selectedItem.value = item
            }
            _userMessage.value = "Changes saved"
        }
    }

    fun deleteItem(item: VaultItem) {
        viewModelScope.launch {
            repository.deleteItem(item)
            if (_selectedItem.value?.id == item.id) {
                _selectedItem.value = null
            }
            _userMessage.value = "Item removed from vault"
            refreshStorageStats()
        }
    }

    fun setThemeMode(mode: ThemeMode) {
        _themeMode.value = mode
        repository.setThemeModeName(mode.name)
    }

    fun setOnboardingCompleted(completed: Boolean) {
        _isOnboardingCompleted.value = completed
        repository.setOnboardingCompleted(completed)
    }

    fun setVaultLockEnabled(enabled: Boolean) {
        _isVaultLockEnabled.value = enabled
        repository.setVaultLockEnabled(enabled)
        if (!enabled) {
            _isVaultLocked.value = false
            _vaultLockError.value = null
        }
    }

    fun unlockVault() {
        _isVaultLocked.value = false
        _vaultLockError.value = null
    }

    fun lockVault() {
        if (_isVaultLockEnabled.value) {
            _isVaultLocked.value = true
        }
    }

    fun setVaultLockError(error: String?) {
        _vaultLockError.value = error
    }

    fun onAppBackgrounded() {
        if (_isVaultLockEnabled.value) {
            lastBackgroundTimestamp = System.currentTimeMillis()
        }
    }

    fun onAppForegrounded() {
        if (_isVaultLockEnabled.value) {
            val timeoutMs = repository.getVaultLockTimeoutSeconds() * 1000L
            if (timeoutMs == 0L || (System.currentTimeMillis() - lastBackgroundTimestamp) >= timeoutMs) {
                _isVaultLocked.value = true
            }
        }
    }

    fun clearUserMessage() {
        _userMessage.value = null
    }

    fun clearAllData() {
        viewModelScope.launch {
            repository.clearAllData()
            _userMessage.value = "All vault data cleared"
            refreshStorageStats()
        }
    }

    fun exportData(onResult: (String) -> Unit) {
        viewModelScope.launch {
            val json = repository.exportLibraryToJson()
            onResult(json)
        }
    }

    fun importData(jsonString: String) {
        viewModelScope.launch {
            val result = repository.importLibraryFromJson(jsonString)
            if (result.isSuccess) {
                _userMessage.value = "Imported ${result.getOrNull()} items successfully"
                refreshStorageStats()
            } else {
                _userMessage.value = "Import failed: ${result.exceptionOrNull()?.message}"
            }
        }
    }
}
