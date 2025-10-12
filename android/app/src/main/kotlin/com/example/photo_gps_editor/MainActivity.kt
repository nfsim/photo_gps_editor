package com.example.photo_gps_editor

import android.media.ExifInterface
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val EXIF_CHANNEL = "com.example.photo_gps_editor/exif"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EXIF_CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "setGPS" -> {
                            try {
                                val filePath = call.argument<String>("filePath")
                                val latitude = call.argument<Double>("latitude")
                                val longitude = call.argument<Double>("longitude")

                                if (filePath == null || latitude == null || longitude == null) {
                                    result.error(
                                            "INVALID_PARAMETERS",
                                            "Required parameters missing",
                                            null
                                    )
                                    return@setMethodCallHandler
                                }

                                Log.d(
                                        TAG,
                                        "Setting GPS: lat=$latitude, lng=$longitude for $filePath"
                                )

                                val success = writeGpsToExif(filePath, latitude, longitude)

                                if (success) {
                                    result.success(true)
                                    Log.d(TAG, "GPS EXIF write successful")
                                } else {
                                    result.error(
                                            "WRITE_FAILED",
                                            "Failed to write GPS data to EXIF",
                                            null
                                    )
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error setting GPS: ${e.message}")
                                result.error("EXCEPTION", e.message, null)
                            }
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                }
    }

    private fun writeGpsToExif(filePath: String, latitude: Double, longitude: Double): Boolean {
        return try {
            val exif = ExifInterface(filePath)

            // Convert decimal degrees to rational GPS format
            exif.setAttribute(ExifInterface.TAG_GPS_LATITUDE, decimalToRational(latitude))
            exif.setAttribute(ExifInterface.TAG_GPS_LONGITUDE, decimalToRational(longitude))

            // Set GPS latitude and longitude references
            exif.setAttribute(ExifInterface.TAG_GPS_LATITUDE_REF, if (latitude >= 0) "N" else "S")
            exif.setAttribute(ExifInterface.TAG_GPS_LONGITUDE_REF, if (longitude >= 0) "E" else "W")

            exif.saveAttributes()

            // Verify by reading back
            val verifyLat = exif.getAttribute(ExifInterface.TAG_GPS_LATITUDE)
            val verifyLng = exif.getAttribute(ExifInterface.TAG_GPS_LONGITUDE)

            Log.d(TAG, "EXIF verify - Lat: $verifyLat, Lng: $verifyLng")

            true
        } catch (e: Exception) {
            Log.e(TAG, "Error writing GPS to EXIF: ${e.message}", e)
            false
        }
    }

    private fun decimalToRational(decimal: Double): String {
        val absDegrees = Math.abs(decimal)
        val degrees = absDegrees.toInt()
        val fractionalPart = absDegrees - degrees

        val minutesTotal = fractionalPart * 60.0
        val minutes = minutesTotal.toInt()
        val secondsTotal = (minutesTotal - minutes) * 60.0
        val seconds = secondsTotal.toInt()

        // Use rational format: degrees/1,minutes/1,seconds/1
        return "$degrees/1,$minutes/1,$seconds/1"
    }
}
