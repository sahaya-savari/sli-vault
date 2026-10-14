package com.example

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import com.example.data.ItemType
import com.example.data.VaultDatabase
import com.example.data.VaultItem
import com.example.data.VaultRepository
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [36])
class VaultRepositoryTest {

    private lateinit var context: Context
    private lateinit var database: VaultDatabase
    private lateinit var repository: VaultRepository

    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
        database = Room.inMemoryDatabaseBuilder(context, VaultDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        repository = VaultRepository(context, database.vaultItemDao())
    }

    @After
    fun tearDown() {
        database.close()
    }

    @Test
    fun `test URL validation with valid URLs`() {
        assertTrue(repository.isValidWebUrl("https://github.com"))
        assertTrue(repository.isValidWebUrl("http://example.org/test?id=123#sec"))
        assertTrue(repository.isValidWebUrl("www.google.com"))
        assertTrue(repository.isValidWebUrl("developer.android.com/reference"))
    }

    @Test
    fun `test URL validation with invalid URLs`() {
        assertFalse(repository.isValidWebUrl(""))
        assertFalse(repository.isValidWebUrl("    "))
        assertFalse(repository.isValidWebUrl("not a url"))
        assertFalse(repository.isValidWebUrl("ftp://something.com"))
        assertFalse(repository.isValidWebUrl("javascript:void(0)"))
    }

    @Test
    fun `saveLink validates and prepends https schema`() = runBlocking {
        val result = repository.saveLink(
            url = "example.com/page",
            title = "My Page",
            collection = "Dev",
            tags = "test, docs"
        )

        assertTrue(result.isSuccess)
        val item = result.getOrNull()
        assertNotNull(item)
        assertEquals("https://example.com/page", item?.url)
        assertEquals("My Page", item?.title)
        assertEquals("Dev", item?.collection)

        val allItems = database.vaultItemDao().getAllItemsOnce()
        assertEquals(1, allItems.size)
        assertEquals("https://example.com/page", allItems[0].url)
    }

    @Test
    fun `saveLink rejects invalid URL format`() = runBlocking {
        val result = repository.saveLink(
            url = "invalid url format",
            title = "Fail Page"
        )

        assertTrue(result.isFailure)
        val allItems = database.vaultItemDao().getAllItemsOnce()
        assertEquals(0, allItems.size)
    }

    @Test
    fun `deleteCustomCollection moves items to General without data loss`() = runBlocking {
        // Save an item in custom collection "Research"
        repository.addCustomCollection("Research")
        repository.saveLink(
            url = "https://kotlinlang.org",
            title = "Kotlin",
            collection = "Research"
        )

        var items = database.vaultItemDao().getAllItemsOnce()
        assertEquals(1, items.size)
        assertEquals("Research", items[0].collection)

        // Delete collection
        repository.deleteCustomCollection("Research")

        // Check that item is preserved and moved to General
        items = database.vaultItemDao().getAllItemsOnce()
        assertEquals(1, items.size)
        assertEquals("General", items[0].collection)
        assertEquals("https://kotlinlang.org", items[0].url)
    }

    @Test
    fun `renameCustomCollection updates item collection references`() = runBlocking {
        repository.addCustomCollection("OldName")
        repository.saveLink(
            url = "https://android.com",
            title = "Android",
            collection = "OldName"
        )

        repository.renameCustomCollection("OldName", "NewName")

        val items = database.vaultItemDao().getAllItemsOnce()
        assertEquals(1, items.size)
        assertEquals("NewName", items[0].collection)
    }

    @Test
    fun `export and import library json preserves items and prevents duplicates`() = runBlocking {
        // Create 2 test items
        val item1 = VaultItem(
            id = "test_101",
            title = "First Link",
            type = ItemType.LINK,
            url = "https://first.com",
            collection = "General",
            tags = "one, test"
        )
        val item2 = VaultItem(
            id = "test_102",
            title = "Second Link",
            type = ItemType.LINK,
            url = "https://second.com",
            collection = "General",
            tags = "two, test"
        )
        database.vaultItemDao().insertItem(item1)
        database.vaultItemDao().insertItem(item2)

        // Export to JSON string
        val exportJson = repository.exportLibraryToJson()
        assertTrue(exportJson.contains("First Link"))
        assertTrue(exportJson.contains("Second Link"))

        // Re-importing into the same database should not create duplicate items
        val count = repository.importLibraryFromJson(exportJson)
        val allItems = database.vaultItemDao().getAllItemsOnce()
        assertEquals(2, allItems.size)
    }
}

