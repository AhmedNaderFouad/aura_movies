package com.example.aura_movies

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.net.CookieHandler
import java.net.CookieManager
import java.net.CookiePolicy

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ESSENTIAL for 403 Fix: Force a global cookie manager.
        // ExoPlayer (Standard Android Video Player) uses the system-wide CookieHandler.
        // Some CDNs set session cookies in the .m3u8 request.
        // Without this, those cookies are lost, and subsequent .ts segment requests fail with 403.
        if (CookieHandler.getDefault() == null) {
            CookieHandler.setDefault(CookieManager(null, CookiePolicy.ACCEPT_ALL))
        }
    }
}
