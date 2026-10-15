package com.example.ui.auth

import android.content.Context
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity

enum class BiometricStatus {
    READY,
    NOT_ENROLLED,
    NO_HARDWARE,
    HW_UNAVAILABLE,
    SECURITY_UPDATE_REQUIRED;

    fun userFriendlyMessage(): String = when (this) {
        READY -> "Biometric or device credential authentication is available."
        NOT_ENROLLED -> "No screen lock or biometrics are enrolled on this device. Please set up a PIN, pattern, or fingerprint in Android Settings."
        NO_HARDWARE -> "This device does not support biometric or credential authentication."
        HW_UNAVAILABLE -> "Biometric hardware is currently busy or unavailable."
        SECURITY_UPDATE_REQUIRED -> "A security update is required before biometrics can be used."
    }
}

sealed class BiometricAuthResult {
    object Success : BiometricAuthResult()
    data class Error(val errorCode: Int, val message: String) : BiometricAuthResult()
    object Cancelled : BiometricAuthResult()
    object FailedAttempt : BiometricAuthResult()
}

object BiometricHelper {

    private const val AUTHENTICATORS = BiometricManager.Authenticators.BIOMETRIC_STRONG or
            BiometricManager.Authenticators.DEVICE_CREDENTIAL

    fun checkAvailability(context: Context): BiometricStatus {
        val manager = BiometricManager.from(context)
        return when (manager.canAuthenticate(AUTHENTICATORS)) {
            BiometricManager.BIOMETRIC_SUCCESS -> BiometricStatus.READY
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> BiometricStatus.NOT_ENROLLED
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> BiometricStatus.NO_HARDWARE
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> BiometricStatus.HW_UNAVAILABLE
            BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> BiometricStatus.SECURITY_UPDATE_REQUIRED
            else -> BiometricStatus.HW_UNAVAILABLE
        }
    }

    fun showBiometricPrompt(
        activity: FragmentActivity,
        title: String = "Unlock SLI Vault",
        subtitle: String = "Authenticate to access your private vault",
        onResult: (BiometricAuthResult) -> Unit
    ) {
        val executor = ContextCompat.getMainExecutor(activity)
        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                onResult(BiometricAuthResult.Success)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                if (errorCode == BiometricPrompt.ERROR_USER_CANCELED ||
                    errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON ||
                    errorCode == BiometricPrompt.ERROR_CANCELED
                ) {
                    onResult(BiometricAuthResult.Cancelled)
                } else {
                    onResult(BiometricAuthResult.Error(errorCode, errString.toString()))
                }
            }

            override fun onAuthenticationFailed() {
                super.onAuthenticationFailed()
                onResult(BiometricAuthResult.FailedAttempt)
            }
        }

        try {
            val prompt = BiometricPrompt(activity, executor, callback)
            val promptInfo = BiometricPrompt.PromptInfo.Builder()
                .setTitle(title)
                .setSubtitle(subtitle)
                .setAllowedAuthenticators(AUTHENTICATORS)
                .build()

            prompt.authenticate(promptInfo)
        } catch (e: Exception) {
            onResult(BiometricAuthResult.Error(-1, e.message ?: "Failed to initialize biometric prompt"))
        }
    }
}

