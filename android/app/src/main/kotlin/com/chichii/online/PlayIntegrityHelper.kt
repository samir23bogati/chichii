package com.chichii.online

import android.content.Context
import android.util.Log
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.plugin.common.MethodChannel

class PlayIntegrityHelper(private val context: Context) {

    fun requestPlayIntegrityToken(result: MethodChannel.Result) {
        val integrityManager = IntegrityManagerFactory.create(context)
        val nonce = "nonce_${System.currentTimeMillis()}"
         val integrityTokenRequest = IntegrityTokenRequest.builder()
        .setNonce(nonce) // ✅ Add nonce here
        .setCloudProjectNumber(581466934152L)
        .build()

        integrityManager.requestIntegrityToken(integrityTokenRequest)
            .addOnSuccessListener { response ->
                val integrityToken = response.token()
                Log.d("PlayIntegrity", "✅ Token: $integrityToken")

                // 🔁 Return token back to Flutter
                result.success(integrityToken)

                // (Optional) send token to your backend from Flutter side
            }
            .addOnFailureListener { exception ->
                Log.e("PlayIntegrity", "❌ Token fetch failed", exception)
                result.error("TOKEN_FETCH_ERROR", "Failed to get Play Integrity token", exception.message)
            }
    }
}
