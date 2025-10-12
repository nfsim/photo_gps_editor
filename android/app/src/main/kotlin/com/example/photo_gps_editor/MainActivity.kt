package com.example.photo_gps_editor

import android.content.ContentValues
import android.media.ExifInterface
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

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
                                    // GPS 저장 후 갤러리에도 추가 시도
                                    val gallerySuccess = saveToGallery(filePath)
                                    result.success(
                                            mapOf(
                                                    "exifSaved" to true,
                                                    "galleryAdded" to gallerySuccess
                                            )
                                    )
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

    private fun saveToGallery(filePath: String): Boolean {
        return try {
            val sourceFile = File(filePath)
            val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val fileName = "GPS_edited_${timestamp}.jpg"

            // MediaStore를 사용하여 갤러리에 새 파일 추가
            val contentValues =
                    ContentValues().apply {
                        put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                        put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
                        put(
                                MediaStore.MediaColumns.RELATIVE_PATH,
                                Environment.DIRECTORY_PICTURES + "/PhotoGpsEditor"
                        )
                        put(MediaStore.MediaColumns.IS_PENDING, 1)
                    }

            val contentResolver = contentResolver
            val uri =
                    contentResolver.insert(
                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                            contentValues
                    )

            uri?.let {
                contentResolver.openOutputStream(it)?.use { outputStream ->
                    FileInputStream(sourceFile).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }

                // 파일 완료 표시
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                contentResolver.update(uri, contentValues, null, null)

                Log.d(TAG, "File saved to gallery: $fileName")
                true
            }
                    ?: false
        } catch (e: Exception) {
            Log.e(TAG, "Error saving to gallery: ${e.message}", e)
            false
        }
    }
}
