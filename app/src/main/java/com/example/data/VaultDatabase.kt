package com.example.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Database(entities = [VaultItem::class], version = 1, exportSchema = false)
abstract class VaultDatabase : RoomDatabase() {
    abstract fun vaultItemDao(): VaultItemDao

    companion object {
        @Volatile
        private var INSTANCE: VaultDatabase? = null

        fun getDatabase(context: Context): VaultDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    VaultDatabase::class.java,
                    "sli_vault_database"
                )
                    .addCallback(VaultDatabaseCallback(context.applicationContext))
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }

    private class VaultDatabaseCallback(
        private val context: Context
    ) : RoomDatabase.Callback() {
        override fun onCreate(db: SupportSQLiteDatabase) {
            super.onCreate(db)
            INSTANCE?.let { database ->
                CoroutineScope(Dispatchers.IO).launch {
                    populateInitialData(database.vaultItemDao())
                }
            }
        }

        private suspend fun populateInitialData(dao: VaultItemDao) {
            val now = System.currentTimeMillis()
            val hour = 3600 * 1000L
            val day = 24 * hour

            val sampleItems = listOf(
                VaultItem(
                    id = "sli-item-1",
                    type = ItemType.LINK,
                    title = "Beautiful Minimal Workspaces",
                    url = "https://notion.so/workspace/minimal-setup",
                    domain = "notion.so",
                    description = "A collection of minimal and productive workspace setups to inspire your next desk setup and deep work habits.",
                    tags = "Design, Workspace, Inspiration",
                    isFavorite = true,
                    collection = "Design",
                    previewImageUrl = "https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80",
                    createdAt = now - (2 * 60 * 1000L) // 2m ago
                ),
                VaultItem(
                    id = "sli-item-2",
                    type = ItemType.LINK,
                    title = "UI Design Inspiration & Glassmorphism",
                    url = "https://dribbble.com/shots/dark-glass-dashboard",
                    domain = "dribbble.com",
                    description = "Curated UI shots exploring dark translucent glass cards with warm fiery orange-red accents and typography hierarchy.",
                    tags = "Design, UI, Inspiration",
                    isFavorite = true,
                    collection = "Inspiration",
                    previewImageUrl = "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=600&q=80",
                    createdAt = now - (15 * 60 * 1000L) // 15m ago
                ),
                VaultItem(
                    id = "sli-item-3",
                    type = ItemType.SCREENSHOT,
                    title = "Study Notes & Jetpack Architecture",
                    url = null,
                    domain = null,
                    description = "Clean diagram showing Jetpack Compose unidirectional data flow with ViewModel, Room SQLite database, and StateFlow.",
                    tags = "Architecture, Kotlin, Study",
                    isFavorite = true,
                    collection = "Personal",
                    fileSizeBytes = 1258291L, // 1.2 MB
                    previewImageUrl = "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&q=80",
                    createdAt = now - hour // 1h ago
                ),
                VaultItem(
                    id = "sli-item-4",
                    type = ItemType.LINK,
                    title = "Flutter & Jetpack UI Components",
                    url = "https://docs.flutter.dev/ui/widgets",
                    domain = "flutter.dev",
                    description = "Comprehensive reference of interactive widgets, animation curves, and layout patterns across platforms.",
                    tags = "Development, Widgets, Reference",
                    isFavorite = false,
                    collection = "Work",
                    previewImageUrl = "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&q=80",
                    createdAt = now - (3 * hour) // 3h ago
                ),
                VaultItem(
                    id = "sli-item-5",
                    type = ItemType.LINK,
                    title = "MacBook Setup Guide 2025",
                    url = "https://medium.com/@tech/macbook-dev-setup",
                    domain = "medium.com",
                    description = "Terminal configurations, dotfiles, brew packages, and developer tools for seamless productivity on Apple Silicon.",
                    tags = "Setup, Productivity, Terminal",
                    isFavorite = false,
                    collection = "Work",
                    previewImageUrl = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80",
                    createdAt = now - day // 1d ago
                ),
                VaultItem(
                    id = "sli-item-6",
                    type = ItemType.LINK,
                    title = "Color Palettes & Dynamic Accents",
                    url = "https://coolors.co/palette/ff6a24-ff4545-0a0b0d",
                    domain = "coolors.co",
                    description = "High-contrast dark palettes featuring Obsidian #0A0B0D, Fiery Orange #FF6A24, and Hot Coral #FF4545 for luxury tech apps.",
                    tags = "Design, Colors, Branding",
                    isFavorite = true,
                    collection = "Design",
                    previewImageUrl = "https://images.unsplash.com/photo-1505904267569-f02eaeb45a4c?w=600&q=80",
                    createdAt = now - (2 * day)
                ),
                VaultItem(
                    id = "sli-item-7",
                    type = ItemType.IMAGE,
                    title = "Travel Spot & Mountain Sunset",
                    url = null,
                    domain = null,
                    description = "Golden hour mountain wallpaper captured during summer alpine hike with warm fiery light across the peaks.",
                    tags = "Travel, Photography, Sunset",
                    isFavorite = true,
                    collection = "Personal",
                    fileSizeBytes = 2516582L, // 2.4 MB
                    previewImageUrl = "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&q=80",
                    createdAt = now - (3 * day)
                ),
                VaultItem(
                    id = "sli-item-8",
                    type = ItemType.LINK,
                    title = "Modern Icons & Lucide Symbols",
                    url = "https://lucide.dev",
                    domain = "lucide.dev",
                    description = "Crisp, consistent open-source outline and glyph icon set designed for digital product interfaces.",
                    tags = "Icons, Design, UI",
                    isFavorite = false,
                    collection = "Design",
                    previewImageUrl = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&q=80",
                    createdAt = now - (4 * day)
                )
            )

            dao.insertAll(sampleItems)
        }
    }
}
