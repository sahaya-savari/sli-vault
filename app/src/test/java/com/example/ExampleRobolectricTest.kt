package com.example

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.example.data.ItemType
import com.example.data.VaultItem
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [36])
class ExampleRobolectricTest {

  @Test
  fun `read string from context`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val appName = context.getString(R.string.app_name)
    assertEquals("SLI Vault", appName)
  }

  @Test
  fun `vault item tags parsing`() {
    val item = VaultItem(
      title = "Test Link",
      type = ItemType.LINK,
      url = "https://example.com",
      tags = "Design, Architecture, Kotlin"
    )
    val tags = item.getTagList()
    assertEquals(3, tags.size)
    assertEquals("Design", tags[0])
    assertEquals("Architecture", tags[1])
    assertEquals("Kotlin", tags[2])
  }
}
