package com.chichii.online

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.chichii.integrity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getIntegrityToken") {
                val integrityHelper = PlayIntegrityHelper(this) // Create helper instance
                integrityHelper.requestPlayIntegrityToken(result) // Call integrity check function
            } else {
                result.notImplemented()
            }
        }
    }
}
