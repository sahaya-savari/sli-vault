package com.example.data

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

enum class ItemType {
    LINK,
    SCREENSHOT,
    IMAGE
}

@Entity(tableName = "vault_items")
data class VaultItem(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val type: ItemType = ItemType.LINK,
    val title: String,
    val url: String? = null,
    val domain: String? = null,
    val description: String? = null,
    val localImagePath: String? = null,
    val previewImageUrl: String? = null,
    val tags: String = "", // Comma-separated tags
    val isFavorite: Boolean = false,
    val collection: String = "General",
    val fileSizeBytes: Long = 0L,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) {
    fun getTagList(): List<String> {
        if (tags.isBlank()) return emptyList()
        return tags.split(",").map { it.trim() }.filter { it.isNotEmpty() }
    }
}
