package com.example.ncs_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngine
            .getPlatformViewsController()
            .invokeViewMethod(
                "TextureRendererBinding",
                "setBackgroundMode",
                mapOf("mode" to "Opaque")
            )
    }
}