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

    @Test
    fun `test mixed-media collection creation and persistence with links, images, screenshots`() = runBlocking {
        // Create 3 items of different media types
        val linkItem = VaultItem(
            id = "link_1",
            title = "Android Architecture Docs",
            type = ItemType.LINK,
            url = "https://developer.android.com",
            collection = "General"
        )
        val imageItem = VaultItem(
            id = "image_1",
            title = "Design Board Infographic",
            type = ItemType.IMAGE,
            localImagePath = "/storage/emulated/0/vault_images/img_1.jpg",
            collection = "General"
        )
        val screenshotItem = VaultItem(
            id = "screen_1",
            title = "Checkout Flow Bug",
            type = ItemType.SCREENSHOT,
            localImagePath = "/storage/emulated/0/vault_images/screen_1.png",
            collection = "General"
        )
        database.vaultItemDao().insertAll(listOf(linkItem, imageItem, screenshotItem))

        // Group all 3 items into a single named collection
        repository.addItemsToCollection(
            listOf("link_1", "image_1", "screen_1"),
            "Sprint 42 Deliverables"
        )

        // Verify collection was registered in persistent custom collections
        val customCollections = repository.getCustomCollections()
        assertTrue(customCollections.contains("Sprint 42 Deliverables"))

        // Verify all 3 items now belong to the collection
        val allItems = database.vaultItemDao().getAllItemsOnce()
        val inCollection = allItems.filter { it.collection == "Sprint 42 Deliverables" }
        assertEquals(3, inCollection.size)

        // Verify content types in the collection are mixed
        val types = inCollection.map { it.type }.toSet()
        assertEquals(setOf(ItemType.LINK, ItemType.IMAGE, ItemType.SCREENSHOT), types)
    }

    @Test
    fun `test moving items between collections preserves original media and content`() = runBlocking {
        val imageItem = VaultItem(
            id = "img_move_1",
            title = "Moodboard Image",
            type = ItemType.IMAGE,
            localImagePath = "/data/user/0/com.example/files/vault_images/moodboard.jpg",
            collection = "Inspiration"
        )
        database.vaultItemDao().insertItem(imageItem)

        // Move image to "Final Assets"
        repository.moveItemToCollection("img_move_1", "Final Assets")

        val retrieved = database.vaultItemDao().getItemByIdOnce("img_move_1")
        assertNotNull(retrieved)
        assertEquals("Final Assets", retrieved?.collection)
        assertEquals("Moodboard Image", retrieved?.title)
        assertEquals("/data/user/0/com.example/files/vault_images/moodboard.jpg", retrieved?.localImagePath)
    }

    @Test
    fun `test removing item from collection resets to General without deleting item`() = runBlocking {
        val linkItem = VaultItem(
            id = "link_remove_1",
            title = "Reference Link",
            type = ItemType.LINK,
            url = "https://kotlinlang.org",
            collection = "DevTools"
        )
        database.vaultItemDao().insertItem(linkItem)

        // Remove item from collection
        repository.removeItemFromCollection("link_remove_1")

        // Item must still exist in vault, moved safely to General
        val retrieved = database.vaultItemDao().getItemByIdOnce("link_remove_1")
        assertNotNull(retrieved)
        assertEquals("General", retrieved?.collection)
        assertEquals("https://kotlinlang.org", retrieved?.url)
    }

    @Test
    fun `test batch removing items from collection resets all to General`() = runBlocking {
        val item1 = VaultItem(id = "batch_1", title = "Item 1", type = ItemType.LINK, collection = "ProjectX")
        val item2 = VaultItem(id = "batch_2", title = "Item 2", type = ItemType.IMAGE, collection = "ProjectX")
        database.vaultItemDao().insertAll(listOf(item1, item2))

        repository.removeItemsFromCollection(listOf("batch_1", "batch_2"))

        val retrieved1 = database.vaultItemDao().getItemByIdOnce("batch_1")
        val retrieved2 = database.vaultItemDao().getItemByIdOnce("batch_2")
        assertEquals("General", retrieved1?.collection)
        assertEquals("General", retrieved2?.collection)
    }

    @Test
    fun `test duplicate collection assignment does not duplicate vault items`() = runBlocking {
        val item = VaultItem(id = "item_dup_1", title = "Single Item", type = ItemType.LINK, collection = "General")
        database.vaultItemDao().insertItem(item)

        // Assign to "UniqueColl" twice
        repository.addItemsToCollection(listOf("item_dup_1"), "UniqueColl")
        repository.addItemsToCollection(listOf("item_dup_1"), "UniqueColl")

        val allItems = database.vaultItemDao().getAllItemsOnce()
        val matching = allItems.filter { it.id == "item_dup_1" }
        assertEquals(1, matching.size)
        assertEquals("UniqueColl", matching[0].collection)
    }
}


