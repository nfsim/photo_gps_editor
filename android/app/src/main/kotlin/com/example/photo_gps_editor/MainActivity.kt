package com.example.photo_gps_editor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // GPS EXIF write implementation temporarily disabled due to API limitations
        // TODO: Implement using ExifInterface.setAttribute for rational GPS values

        // val exifChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
        // "com.example.photo_gps_editor/exif")
        // exifChannel.setMethodCallHandler { call, result -> ... }
    }
}
