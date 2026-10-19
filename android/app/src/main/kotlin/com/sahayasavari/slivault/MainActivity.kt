package com.sahayasavari.slivault

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import java.io.File
import java.io.FileOutputStream
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth_android hosts AndroidX BiometricPrompt in a Fragment.  Its
// activity must therefore be a FragmentActivity (FlutterFragmentActivity).
class MainActivity : FlutterFragmentActivity() {
	private val channelName = "sli_vault/share"
	private var shareChannel: MethodChannel? = null
	private var pendingShare: Map<String, String?>? = null

	private var isScreenProtectionEnabled = true

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		applySecureFlag()
		captureShareIntent(intent)
	}

	override fun onResume() {
		super.onResume()
		// Re-assert after recreation / return from background so the protected UI stays covered.
		applySecureFlag()
	}

	private fun applySecureFlag() {
		if (isScreenProtectionEnabled) {
			window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
		} else {
			window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
		}
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		val securityChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sli_vault/security")
		securityChannel.setMethodCallHandler { call, result ->
			when (call.method) {
				"setScreenProtection" -> {
					val enabled = call.argument<Boolean>("enabled") ?: true
					isScreenProtectionEnabled = enabled
					applySecureFlag()
					result.success(null)
				}
				"isScreenProtectionEnabled" -> {
					result.success(isScreenProtectionEnabled)
				}
				else -> result.notImplemented()
			}
		}
		shareChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
		shareChannel?.setMethodCallHandler { call, result ->
			when (call.method) {
				"getInitialShare" -> {
					result.success(pendingShare)
					pendingShare = null
				}
				else -> result.notImplemented()
			}
		}
		pendingShare?.let {
			shareChannel?.invokeMethod("incomingShare", it)
			pendingShare = null
		}
	}

	override fun onNewIntent(intent: Intent) {
		super.onNewIntent(intent)
		captureShareIntent(intent)
		pendingShare?.let { shareChannel?.invokeMethod("incomingShare", it) }
		pendingShare = null
	}

	private fun captureShareIntent(intent: Intent?) {
		if (intent == null || (intent.action != Intent.ACTION_SEND && intent.action != Intent.ACTION_SEND_MULTIPLE)) return
		val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()?.takeIf { it.isNotEmpty() }
		val uri = if (intent.action == Intent.ACTION_SEND) {
			intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
		} else {
			intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.firstOrNull()
		}
		val imagePath = uri?.let(::copySharedFile)
		if (text != null || imagePath != null) {
			pendingShare = mapOf("text" to text, "imagePath" to imagePath)
		}
	}

	private fun copySharedFile(uri: Uri): String? {
		return try {
			val extension = when (contentResolver.getType(uri)) {
				"image/png" -> ".png"
				"image/webp" -> ".webp"
				"image/gif" -> ".gif"
				else -> ".jpg"
			}
			val target = File(cacheDir, "incoming-share-${System.currentTimeMillis()}$extension")
			contentResolver.openInputStream(uri)?.use { input ->
				FileOutputStream(target).use { output -> input.copyTo(output) }
			}
			target.absolutePath.takeIf { target.exists() && target.length() > 0 }
		} catch (_: Exception) {
			null
		}
	}
}
