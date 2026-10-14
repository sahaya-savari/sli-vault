package com.example.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface VaultItemDao {
    @Query("SELECT * FROM vault_items ORDER BY createdAt DESC")
    fun getAllItems(): Flow<List<VaultItem>>

    @Query("SELECT * FROM vault_items WHERE type = :type ORDER BY createdAt DESC")
    fun getItemsByType(type: ItemType): Flow<List<VaultItem>>

    @Query("SELECT * FROM vault_items WHERE isFavorite = 1 ORDER BY createdAt DESC")
    fun getFavoriteItems(): Flow<List<VaultItem>>

    @Query("SELECT * FROM vault_items WHERE id = :id LIMIT 1")
    fun getItemById(id: String): Flow<VaultItem?>

    @Query("SELECT * FROM vault_items WHERE id = :id LIMIT 1")
    suspend fun getItemByIdOnce(id: String): VaultItem?

    @Query("SELECT * FROM vault_items ORDER BY createdAt DESC")
    suspend fun getAllItemsOnce(): List<VaultItem>

    @Query("UPDATE vault_items SET collection = 'General' WHERE collection = :collection")
    suspend fun resetCollectionToGeneral(collection: String)

    @Query("UPDATE vault_items SET collection = :newName WHERE collection = :oldName")
    suspend fun renameCollection(oldName: String, newName: String)

    @Query("""
        SELECT * FROM vault_items 
        WHERE title LIKE '%' || :query || '%' 
           OR url LIKE '%' || :query || '%' 
           OR domain LIKE '%' || :query || '%' 
           OR tags LIKE '%' || :query || '%' 
           OR description LIKE '%' || :query || '%' 
        ORDER BY createdAt DESC
    """)
    fun searchItems(query: String): Flow<List<VaultItem>>

    @Query("SELECT * FROM vault_items WHERE collection = :collection ORDER BY createdAt DESC")
    fun getItemsByCollection(collection: String): Flow<List<VaultItem>>

    @Query("SELECT DISTINCT collection FROM vault_items WHERE collection IS NOT NULL AND collection != '' ORDER BY collection ASC")
    fun getDistinctCollections(): Flow<List<String>>

    @Query("SELECT COUNT(*) FROM vault_items")
    fun getItemCount(): Flow<Int>

    @Query("SELECT COUNT(*) FROM vault_items WHERE type = :type")
    fun getItemCountByType(type: ItemType): Flow<Int>

    @Query("SELECT COUNT(*) FROM vault_items WHERE isFavorite = 1")
    fun getFavoriteCount(): Flow<Int>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertItem(item: VaultItem)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<VaultItem>)

    @Update
    suspend fun updateItem(item: VaultItem)

    @Delete
    suspend fun deleteItem(item: VaultItem)

    @Query("DELETE FROM vault_items WHERE id = :id")
    suspend fun deleteItemById(id: String)

    @Query("UPDATE vault_items SET isFavorite = :isFavorite, updatedAt = :updatedAt WHERE id = :id")
    suspend fun updateFavorite(id: String, isFavorite: Boolean, updatedAt: Long = System.currentTimeMillis())

    @Query("DELETE FROM vault_items")
    suspend fun clearAll()
}
