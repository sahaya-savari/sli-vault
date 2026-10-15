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

    @Test
    fun `settings preferences persist properly`() {
        // Theme mode persistence
        repository.setThemeModeName("LIGHT")
        assertEquals("LIGHT", repository.getThemeModeName())
        repository.setThemeModeName("SYSTEM")
        assertEquals("SYSTEM", repository.getThemeModeName())
        repository.setThemeModeName("DARK")
        assertEquals("DARK", repository.getThemeModeName())

        // Onboarding persistence
        repository.setOnboardingCompleted(false)
        assertFalse(repository.isOnboardingCompleted())
        repository.setOnboardingCompleted(true)
        assertTrue(repository.isOnboardingCompleted())

        // Vault lock persistence
        repository.setVaultLockEnabled(false)
        assertFalse(repository.isVaultLockEnabled())
        repository.setVaultLockEnabled(true)
        assertTrue(repository.isVaultLockEnabled())

        // Vault lock timeout persistence
        repository.setVaultLockTimeoutSeconds(120)
        assertEquals(120, repository.getVaultLockTimeoutSeconds())
    }

    @Test
    fun `filterItems performs multi-token search and handles special characters`() {
        val itemA = VaultItem(
            id = "item_a",
            title = "Android Compose Tutorial",
            type = ItemType.LINK,
            url = "https://developer.android.com/jetpack",
            domain = "developer.android.com",
            description = "Modern UI toolkit for Android",
            tags = "ui, kotlin",
            collection = "Dev"
        )
        val itemB = VaultItem(
            id = "item_b",
            title = "Design Systems Token Guide",
            type = ItemType.LINK,
            url = "https://figma.com/@design/tokens",
            domain = "figma.com",
            description = "Specular glass and color palettes",
            tags = "figma, token, glass",
            collection = "Design"
        )
        val itemC = VaultItem(
            id = "item_c",
            title = "Special 100% off coupon code",
            type = ItemType.IMAGE,
            url = "https://deal.org/promo?code=100%_off#free",
            domain = "deal.org",
            description = "Promo voucher screenshot",
            tags = "promo, save, %_special",
            collection = "Shopping"
        )

        val items = listOf(itemA, itemB, itemC)

        // Empty / blank query returns all items
        assertEquals(3, repository.filterItems(items, "").size)
        assertEquals(3, repository.filterItems(items, "   ").size)

        // Single partial token search
        val composeResult = repository.filterItems(items, "compose")
        assertEquals(1, composeResult.size)
        assertEquals("item_a", composeResult[0].id)

        // Multi-token across different fields (title token + collection token)
        val multiResult = repository.filterItems(items, "tutorial dev")
        assertEquals(1, multiResult.size)
        assertEquals("item_a", multiResult[0].id)

        // Multi-token across tag and description
        val tokenGlassResult = repository.filterItems(items, "token specular")
        assertEquals(1, tokenGlassResult.size)
        assertEquals("item_b", tokenGlassResult[0].id)

        // Special characters in query: % and _
        val specialResult = repository.filterItems(items, "100%")
        assertEquals(1, specialResult.size)
        assertEquals("item_c", specialResult[0].id)

        val underscoreResult = repository.filterItems(items, "%_special")
        assertEquals(1, underscoreResult.size)
        assertEquals("item_c", underscoreResult[0].id)

        // No match returns empty list
        val noMatch = repository.filterItems(items, "nonexistent query term")
        assertTrue(noMatch.isEmpty())
    }

    @Test
    fun `filterItems respects collection and type filters`() {
        val item1 = VaultItem(
            id = "1",
            title = "Kotlin Docs",
            type = ItemType.LINK,
            collection = "Dev"
        )
        val item2 = VaultItem(
            id = "2",
            title = "Kotlin Architecture Diagram",
            type = ItemType.IMAGE,
            collection = "Dev"
        )
        val item3 = VaultItem(
            id = "3",
            title = "Design Tokens",
            type = ItemType.LINK,
            collection = "Design"
        )

        val all = listOf(item1, item2, item3)

        // Filter by collection only
        val devItems = repository.filterItems(all, "", collectionFilter = "Dev")
        assertEquals(2, devItems.size)

        // Filter by collection and type
        val devLinks = repository.filterItems(all, "", typeFilter = ItemType.LINK, collectionFilter = "Dev")
        assertEquals(1, devLinks.size)
        assertEquals("1", devLinks[0].id)

        // Filter with query and collection
        val searchInDev = repository.filterItems(all, "diagram", collectionFilter = "Dev")
        assertEquals(1, searchInDev.size)
        assertEquals("2", searchInDev[0].id)
    }

    @Test
    fun `importLibraryFromJson handles malformed and invalid inputs gracefully`() = runBlocking {
        // Blank string should fail cleanly
        val blankResult = repository.importLibraryFromJson("")
        assertTrue(blankResult.isFailure)

        // Whitespace only
        val wsResult = repository.importLibraryFromJson("    ")
        assertTrue(wsResult.isFailure)

        // Syntactically invalid JSON
        val syntaxResult = repository.importLibraryFromJson("{ not valid json at all }")
        assertTrue(syntaxResult.isFailure)

        // Missing "items" array in object
        val missingItemsResult = repository.importLibraryFromJson("""{"version": 1}""")
        assertTrue(missingItemsResult.isFailure)

        // Valid empty array succeeds with 0 imported
        val emptyListResult = repository.importLibraryFromJson("""{"version": 1, "items": []}""")
        assertTrue(emptyListResult.isSuccess)
        assertEquals(0, emptyListResult.getOrNull())
    }
}


