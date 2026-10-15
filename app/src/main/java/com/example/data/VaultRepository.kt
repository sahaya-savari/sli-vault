package com.example.data

import android.content.Context
import android.net.Uri
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.net.URI
import java.util.UUID

class VaultRepository(
    private val context: Context,
    private val dao: VaultItemDao
) {
    val allItems: Flow<List<VaultItem>> = dao.getAllItems()
    val favoriteItems: Flow<List<VaultItem>> = dao.getFavoriteItems()

    fun getItemsByType(type: ItemType): Flow<List<VaultItem>> = dao.getItemsByType(type)
    fun getItemById(id: String): Flow<VaultItem?> = dao.getItemById(id)
    fun searchItems(query: String): Flow<List<VaultItem>> = dao.searchItems(query)
    fun getItemsByCollection(collection: String): Flow<List<VaultItem>> = dao.getItemsByCollection(collection)
    fun getDistinctCollections(): Flow<List<String>> = dao.getDistinctCollections()

    private val collectionsPrefs = context.getSharedPreferences("sli_vault_collections", Context.MODE_PRIVATE)
    private val settingsPrefs = context.getSharedPreferences("sli_vault_settings", Context.MODE_PRIVATE)

    fun getCustomCollections(): Set<String> {
        return collectionsPrefs.getStringSet("custom_collections", emptySet()) ?: emptySet()
    }

    fun addCustomCollection(name: String) {
        val trimmed = name.trim()
        if (trimmed.isNotBlank()) {
            val current = getCustomCollections().toMutableSet()
            current.add(trimmed)
            collectionsPrefs.edit().putStringSet("custom_collections", current).apply()
        }
    }

    suspend fun deleteCustomCollection(name: String) = withContext(Dispatchers.IO) {
        val trimmed = name.trim()
        dao.resetCollectionToGeneral(trimmed)
        val current = getCustomCollections().toMutableSet()
        current.remove(trimmed)
        collectionsPrefs.edit().putStringSet("custom_collections", current).apply()
    }

    suspend fun renameCustomCollection(oldName: String, newName: String) = withContext(Dispatchers.IO) {
        val oldTrimmed = oldName.trim()
        val newTrimmed = newName.trim()
        if (newTrimmed.isNotBlank() && oldTrimmed != newTrimmed) {
            dao.renameCollection(oldTrimmed, newTrimmed)
            val current = getCustomCollections().toMutableSet()
            current.remove(oldTrimmed)
            current.add(newTrimmed)
            collectionsPrefs.edit().putStringSet("custom_collections", current).apply()
        }
    }

    suspend fun addItemsToCollection(itemIds: List<String>, collectionName: String) = withContext(Dispatchers.IO) {
        val trimmed = collectionName.trim()
        if (trimmed.isNotBlank() && itemIds.isNotEmpty()) {
            if (!trimmed.equals("General", ignoreCase = true)) {
                addCustomCollection(trimmed)
            }
            dao.updateItemsCollection(itemIds, trimmed)
        }
    }

    suspend fun removeItemFromCollection(itemId: String) = withContext(Dispatchers.IO) {
        dao.updateItemCollection(itemId, "General")
    }

    suspend fun removeItemsFromCollection(itemIds: List<String>) = withContext(Dispatchers.IO) {
        if (itemIds.isNotEmpty()) {
            dao.removeItemsFromCollection(itemIds)
        }
    }

    suspend fun moveItemToCollection(itemId: String, targetCollection: String) = withContext(Dispatchers.IO) {
        val trimmed = targetCollection.trim().ifBlank { "General" }
        if (!trimmed.equals("General", ignoreCase = true)) {
            addCustomCollection(trimmed)
        }
        dao.updateItemCollection(itemId, trimmed)
    }

    suspend fun moveItemsToCollection(itemIds: List<String>, targetCollection: String) = withContext(Dispatchers.IO) {
        val trimmed = targetCollection.trim().ifBlank { "General" }
        if (itemIds.isNotEmpty()) {
            if (!trimmed.equals("General", ignoreCase = true)) {
                addCustomCollection(trimmed)
            }
            dao.updateItemsCollection(itemIds, trimmed)
        }
    }

    fun getThemeModeName(): String {
        return settingsPrefs.getString("theme_mode", "DARK") ?: "DARK"
    }

    fun setThemeModeName(name: String) {
        settingsPrefs.edit().putString("theme_mode", name).apply()
    }

    fun isOnboardingCompleted(): Boolean {
        return settingsPrefs.getBoolean("onboarding_completed", true)
    }

    fun setOnboardingCompleted(completed: Boolean) {
        settingsPrefs.edit().putBoolean("onboarding_completed", completed).apply()
    }

    fun isVaultLockEnabled(): Boolean {
        return settingsPrefs.getBoolean("vault_lock_enabled", false)
    }

    fun setVaultLockEnabled(enabled: Boolean) {
        settingsPrefs.edit().putBoolean("vault_lock_enabled", enabled).apply()
    }

    fun getVaultLockTimeoutSeconds(): Int {
        return settingsPrefs.getInt("vault_lock_timeout", 0)
    }

    fun setVaultLockTimeoutSeconds(seconds: Int) {
        settingsPrefs.edit().putInt("vault_lock_timeout", seconds).apply()
    }

    /**
     * Multi-token, case-insensitive memory search and filtering across titles, URLs,
     * domains, descriptions, tags, and collections.
     */
    fun filterItems(
        items: List<VaultItem>,
        query: String,
        typeFilter: ItemType? = null,
        collectionFilter: String? = null
    ): List<VaultItem> {
        var list = items

        if (!collectionFilter.isNullOrBlank()) {
            list = list.filter { it.collection.equals(collectionFilter, ignoreCase = true) }
        }

        if (typeFilter != null) {
            list = list.filter { it.type == typeFilter }
        }

        if (query.isNotBlank()) {
            val tokens = query.trim().lowercase().split("\\s+".toRegex()).filter { it.isNotEmpty() }
            if (tokens.isNotEmpty()) {
                list = list.filter { item ->
                    tokens.all { token ->
                        item.title.lowercase().contains(token) ||
                                (item.url?.lowercase()?.contains(token) == true) ||
                                (item.domain?.lowercase()?.contains(token) == true) ||
                                (item.description?.lowercase()?.contains(token) == true) ||
                                item.tags.lowercase().contains(token) ||
                                item.collection.lowercase().contains(token)
                    }
                }
            }
        }

        return list
    }

    fun isValidWebUrl(url: String): Boolean {
        val trimmed = url.trim()
        if (trimmed.isBlank()) return false
        val normalized = if (!trimmed.startsWith("http://") && !trimmed.startsWith("https://")) {
            "https://$trimmed"
        } else {
            trimmed
        }
        return try {
            val uri = URI(normalized)
            val host = uri.host
            !host.isNullOrBlank() && host.contains(".") && (uri.scheme == "http" || uri.scheme == "https")
        } catch (e: Exception) {
            false
        }
    }

    val itemCount: Flow<Int> = dao.getItemCount()
    val favoriteCount: Flow<Int> = dao.getFavoriteCount()
    fun getItemCountByType(type: ItemType): Flow<Int> = dao.getItemCountByType(type)

    suspend fun saveLink(
        url: String,
        title: String?,
        description: String? = null,
        tags: String = "",
        collection: String = "General"
    ): Result<VaultItem> = withContext(Dispatchers.IO) {
        try {
            val trimmedUrl = url.trim()
            if (!isValidWebUrl(trimmedUrl)) {
                return@withContext Result.failure(IllegalArgumentException("Please enter a valid website URL (e.g. https://example.com)"))
            }

            val normalizedUrl = if (!trimmedUrl.startsWith("http://") && !trimmedUrl.startsWith("https://")) {
                "https://$trimmedUrl"
            } else {
                trimmedUrl
            }

            val domain = extractDomain(normalizedUrl)
            val finalTitle = if (title.isNullOrBlank()) {
                domain.ifBlank { "Saved Link" }
            } else {
                title.trim()
            }

            val item = VaultItem(
                id = UUID.randomUUID().toString(),
                type = ItemType.LINK,
                title = finalTitle,
                url = normalizedUrl,
                domain = domain,
                description = description?.trim(),
                tags = tags.trim(),
                collection = collection.trim(),
                createdAt = System.currentTimeMillis(),
                updatedAt = System.currentTimeMillis()
            )

            dao.insertItem(item)
            Result.success(item)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun saveImageOrScreenshot(
        imageUri: Uri,
        isScreenshot: Boolean,
        title: String?,
        description: String? = null,
        tags: String = "",
        collection: String = "General"
    ): Result<VaultItem> = withContext(Dispatchers.IO) {
        try {
            // Copy the selected file into persistent local storage per PRD requirements
            val storageDir = File(context.filesDir, "vault_images")
            if (!storageDir.exists()) {
                storageDir.mkdirs()
            }

            val fileExt = if (isScreenshot) "png" else "jpg"
            val localFileName = "vault_${System.currentTimeMillis()}_${UUID.randomUUID().toString().take(8)}.$fileExt"
            val destinationFile = File(storageDir, localFileName)

            var bytesCopied: Long = 0L
            val inputStream = context.contentResolver.openInputStream(imageUri)
                ?: return@withContext Result.failure(java.io.IOException("Cannot open input stream for image"))

            inputStream.use { inStream ->
                FileOutputStream(destinationFile).use { outputStream ->
                    bytesCopied = inStream.copyTo(outputStream)
                }
            }

            if (bytesCopied <= 0L) {
                if (destinationFile.exists()) destinationFile.delete()
                return@withContext Result.failure(java.io.IOException("Image file is empty or could not be read"))
            }

            val finalTitle = if (title.isNullOrBlank()) {
                if (isScreenshot) "Screenshot capture" else "Saved Image"
            } else {
                title.trim()
            }

            val item = VaultItem(
                id = UUID.randomUUID().toString(),
                type = if (isScreenshot) ItemType.SCREENSHOT else ItemType.IMAGE,
                title = finalTitle,
                url = null,
                domain = null,
                description = description?.trim(),
                localImagePath = destinationFile.absolutePath,
                fileSizeBytes = bytesCopied,
                tags = tags.trim(),
                collection = collection.trim(),
                createdAt = System.currentTimeMillis(),
                updatedAt = System.currentTimeMillis()
            )

            dao.insertItem(item)
            Result.success(item)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun toggleFavorite(id: String, currentStatus: Boolean) = withContext(Dispatchers.IO) {
        dao.updateFavorite(id, !currentStatus)
    }

    suspend fun updateItem(item: VaultItem) = withContext(Dispatchers.IO) {
        dao.updateItem(item.copy(updatedAt = System.currentTimeMillis()))
    }

    suspend fun deleteItem(item: VaultItem) = withContext(Dispatchers.IO) {
        // Also clean up local image binary data if exists
        item.localImagePath?.let { path ->
            val file = File(path)
            if (file.exists()) {
                file.delete()
            }
        }
        dao.deleteItem(item)
    }

    suspend fun clearAllData() = withContext(Dispatchers.IO) {
        val storageDir = File(context.filesDir, "vault_images")
        if (storageDir.exists()) {
            storageDir.deleteRecursively()
        }
        dao.clearAll()
    }

    suspend fun exportLibraryToJson(): String = withContext(Dispatchers.IO) {
        val root = JSONObject()
        root.put("app", "SLI Vault")
        root.put("version", "1.0")
        root.put("exportedAt", System.currentTimeMillis())

        val itemsArray = JSONArray()
        val currentItems = dao.getAllItemsOnce()

        for (item in currentItems) {
            val obj = JSONObject()
            obj.put("id", item.id)
            obj.put("type", item.type.name)
            obj.put("title", item.title)
            obj.put("url", item.url)
            obj.put("domain", item.domain)
            obj.put("description", item.description)
            obj.put("tags", item.tags)
            obj.put("isFavorite", item.isFavorite)
            obj.put("collection", item.collection)
            obj.put("fileSizeBytes", item.fileSizeBytes)
            obj.put("createdAt", item.createdAt)
            obj.put("updatedAt", item.updatedAt)

            // Durably export image bytes as Base64 for local image items
            if (!item.localImagePath.isNullOrBlank()) {
                try {
                    val file = File(item.localImagePath)
                    if (file.exists() && file.length() > 0) {
                        val bytes = file.readBytes()
                        obj.put("imageBase64", android.util.Base64.encodeToString(bytes, android.util.Base64.NO_WRAP))
                    }
                } catch (e: Exception) {
                    // Skip image binary if unreadable, keep metadata
                }
            }
            itemsArray.put(obj)
        }

        root.put("items", itemsArray)
        root.toString(2)
    }

    suspend fun importLibraryFromJson(jsonString: String): Result<Int> = withContext(Dispatchers.IO) {
        try {
            val trimmed = jsonString.trim()
            if (trimmed.isBlank()) {
                return@withContext Result.failure(IllegalArgumentException("Backup JSON is empty"))
            }
            val root = JSONObject(trimmed)
            if (!root.has("items")) {
                return@withContext Result.failure(IllegalArgumentException("Invalid backup format: missing 'items' array"))
            }
            val itemsArray = root.getJSONArray("items")
            val itemsToInsert = mutableListOf<VaultItem>()
            val storageDir = File(context.filesDir, "vault_images")
            if (!storageDir.exists()) {
                storageDir.mkdirs()
            }

            for (i in 0 until itemsArray.length()) {
                val obj = itemsArray.getJSONObject(i)
                val id = if (obj.has("id") && !obj.isNull("id")) obj.getString("id") else UUID.randomUUID().toString()

                // Deterministic duplicate prevention: preserve existing items with identical stable IDs
                if (dao.getItemByIdOnce(id) != null) {
                    continue
                }

                val typeStr = obj.optString("type", "LINK")
                val itemType = try {
                    ItemType.valueOf(typeStr)
                } catch (e: Exception) {
                    ItemType.LINK
                }

                var restoredLocalPath: String? = null
                var fileSize = obj.optLong("fileSizeBytes", 0L)

                // Restore image bytes if present in backup archive
                if (obj.has("imageBase64") && !obj.isNull("imageBase64")) {
                    try {
                        val base64Str = obj.getString("imageBase64")
                        val bytes = android.util.Base64.decode(base64Str, android.util.Base64.DEFAULT)
                        if (bytes.isNotEmpty()) {
                            val ext = if (itemType == ItemType.SCREENSHOT) "png" else "jpg"
                            val restoredFile = File(storageDir, "vault_restored_${id.take(8)}_${System.currentTimeMillis()}.$ext")
                            restoredFile.writeBytes(bytes)
                            restoredLocalPath = restoredFile.absolutePath
                            fileSize = bytes.size.toLong()
                        }
                    } catch (e: Exception) {
                        // Keep item even if image decoding fails
                    }
                }

                val coll = obj.optString("collection", "General").trim().ifBlank { "General" }
                if (!coll.equals("General", ignoreCase = true)) {
                    addCustomCollection(coll)
                }

                val item = VaultItem(
                    id = id,
                    type = itemType,
                    title = obj.optString("title", "Imported Item"),
                    url = if (obj.has("url") && !obj.isNull("url")) obj.getString("url") else null,
                    domain = if (obj.has("domain") && !obj.isNull("domain")) obj.getString("domain") else null,
                    description = if (obj.has("description") && !obj.isNull("description")) obj.getString("description") else null,
                    localImagePath = restoredLocalPath,
                    tags = obj.optString("tags", ""),
                    isFavorite = obj.optBoolean("isFavorite", false),
                    collection = coll,
                    fileSizeBytes = fileSize,
                    createdAt = obj.optLong("createdAt", System.currentTimeMillis()),
                    updatedAt = obj.optLong("updatedAt", System.currentTimeMillis())
                )
                itemsToInsert.add(item)
            }

            if (itemsToInsert.isNotEmpty()) {
                dao.insertAll(itemsToInsert)
            }
            Result.success(itemsToInsert.size)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getStorageStats(): StorageStats = withContext(Dispatchers.IO) {
        val storageDir = File(context.filesDir, "vault_images")
        var totalBytes = 0L
        var imageFilesCount = 0
        if (storageDir.exists()) {
            storageDir.listFiles()?.forEach { file ->
                totalBytes += file.length()
                imageFilesCount++
            }
        }
        val dbFile = context.getDatabasePath("sli_vault_database")
        if (dbFile.exists()) {
            totalBytes += dbFile.length()
        }
        StorageStats(
            totalBytes = totalBytes,
            imageCount = imageFilesCount
        )
    }

    private fun extractDomain(url: String): String {
        return try {
            val uri = URI(url)
            val host = uri.host ?: ""
            if (host.startsWith("www.")) host.substring(4) else host
        } catch (e: Exception) {
            url.substringAfter("://").substringBefore("/").substringAfter("www.")
        }
    }
}

data class StorageStats(
    val totalBytes: Long,
    val imageCount: Int
) {
    fun formattedSize(): String {
        return when {
            totalBytes >= 1024 * 1024 -> String.format("%.1f MB", totalBytes.toDouble() / (1024 * 1024))
            totalBytes >= 1024 -> String.format("%.1f KB", totalBytes.toDouble() / 1024)
            else -> "$totalBytes B"
        }
    }
}
