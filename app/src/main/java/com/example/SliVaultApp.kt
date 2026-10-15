package com.example

import android.app.Application
import coil.ImageLoader
import coil.ImageLoaderFactory
import coil.disk.DiskCache
import coil.memory.MemoryCache

/**
 * Application entry point for SLI Vault.
 * Configures application-wide singleton services, including an offline-optimized
 * Coil ImageLoader with constrained memory and disk caches to avoid Out-Of-Memory
 * issues when browsing high-resolution screenshots and images.
 */
class SliVaultApp : Application(), ImageLoaderFactory {

    override fun newImageLoader(): ImageLoader {
        return ImageLoader.Builder(this)
            .memoryCache {
                MemoryCache.Builder(this)
                    .maxSizePercent(0.25) // Up to 25% of available heap for image memory cache
                    .build()
            }
            .diskCache {
                DiskCache.Builder()
                    .directory(cacheDir.resolve("vault_coil_cache"))
                    .maxSizeBytes(64L * 1024 * 1024) // 64 MB maximum disk cache
                    .build()
            }
            .crossfade(true)
            .respectCacheHeaders(false) // Optimized for offline persistence
            .build()
    }
}

