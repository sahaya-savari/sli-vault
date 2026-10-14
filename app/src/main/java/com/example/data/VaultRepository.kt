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
            val normalizedUrl = if (!url.startsWith("http://") && !url.startsWith("https://")) {
                "https://$url"
            } else {
                url.trim()
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
            context.contentResolver.openInputStream(imageUri)?.use { inputStream ->
                FileOutputStream(destinationFile).use { outputStream ->
                    bytesCopied = inputStream.copyTo(outputStream)
                }
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
        // Read directly
        val db = VaultDatabase.getDatabase(context)
        val currentItems = db.vaultItemDao().getItemByIdOnce("") // or query
        // We can query all items directly
        val cursor = db.openHelper.readableDatabase.query("SELECT * FROM vault_items")
        while (cursor.moveToNext()) {
            val obj = JSONObject()
            obj.put("id", cursor.getString(cursor.getColumnIndexOrThrow("id")))
            obj.put("type", cursor.getString(cursor.getColumnIndexOrThrow("type")))
            obj.put("title", cursor.getString(cursor.getColumnIndexOrThrow("title")))
            obj.put("url", cursor.getString(cursor.getColumnIndexOrThrow("url")))
            obj.put("domain", cursor.getString(cursor.getColumnIndexOrThrow("domain")))
            obj.put("description", cursor.getString(cursor.getColumnIndexOrThrow("description")))
            obj.put("tags", cursor.getString(cursor.getColumnIndexOrThrow("tags")))
            obj.put("isFavorite", cursor.getInt(cursor.getColumnIndexOrThrow("isFavorite")) == 1)
            obj.put("collection", cursor.getString(cursor.getColumnIndexOrThrow("collection")))
            obj.put("createdAt", cursor.getLong(cursor.getColumnIndexOrThrow("createdAt")))
            itemsArray.put(obj)
        }
        cursor.close()

        root.put("items", itemsArray)
        root.toString(2)
    }

    suspend fun importLibraryFromJson(jsonString: String): Result<Int> = withContext(Dispatchers.IO) {
        try {
            val root = JSONObject(jsonString)
            val itemsArray = root.getJSONArray("items")
            val itemsToInsert = mutableListOf<VaultItem>()
            
            // Note: Currently imports metadata only. Local image files are not restored.

            for (i in 0 until itemsArray.length()) {
                val obj = itemsArray.getJSONObject(i)
                val typeStr = obj.optString("type", "LINK")
                val itemType = try {
                    ItemType.valueOf(typeStr)
                } catch (e: Exception) {
                    ItemType.LINK
                }

                val item = VaultItem(
                    id = UUID.randomUUID().toString(), // assign new stable ID to avoid collisions
                    type = itemType,
                    title = obj.optString("title", "Imported Item"),
                    url = if (obj.has("url") && !obj.isNull("url")) obj.getString("url") else null,
                    domain = if (obj.has("domain") && !obj.isNull("domain")) obj.getString("domain") else null,
                    description = if (obj.has("description") && !obj.isNull("description")) obj.getString("description") else null,
                    tags = obj.optString("tags", ""),
                    isFavorite = obj.optBoolean("isFavorite", false),
                    collection = obj.optString("collection", "General"),
                    createdAt = obj.optLong("createdAt", System.currentTimeMillis()),
                    updatedAt = System.currentTimeMillis()
                )
                itemsToInsert.add(item)
            }

            dao.insertAll(itemsToInsert)
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
