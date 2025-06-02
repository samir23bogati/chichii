package com.chichii.online

import android.content.Context
import android.util.Log
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.*

class PlayIntegrityHelper(private val context: Context) {

    private fun generateSecureNonce(): String {
        val uuid = UUID.randomUUID().toString()
        val digest = MessageDigest.getInstance("SHA-256")
        val hash = digest.digest(uuid.toByteArray())
        return hash.joinToString("") { "%02x".format(it) }
    }

    fun requestPlayIntegrityToken(result: MethodChannel.Result) {
        val integrityManager = IntegrityManagerFactory.create(context)
        val nonce = generateSecureNonce()

        val integrityTokenRequest = IntegrityTokenRequest.builder()
            .setNonce(nonce)
            .setCloudProjectNumber(581466934152L) // Replace with your actual number
            .build()

        integrityManager.requestIntegrityToken(integrityTokenRequest)
            .addOnSuccessListener { response ->
                val integrityToken = response.token()
                Log.d("PlayIntegrity", "✅ Token: $integrityToken")
                result.success(integrityToken)
            }
            .addOnFailureListener { exception ->
                Log.e("PlayIntegrity", "❌ Token fetch failed", exception)
                result.error("TOKEN_FETCH_ERROR", "Failed to get Play Integrity token", exception.message)
            }
    }
}
