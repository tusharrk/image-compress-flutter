package com.tusharrk.image.compress.photo

import android.media.ExifInterface
import android.graphics.Bitmap

import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "image_exif_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "addExifToImage") {
                    val originalBytes = call.argument<ByteArray>("originalImage")
                    val compressedBytes = call.argument<ByteArray>("compressedImage")
                    val keepLocation = call.argument<Boolean>("keepLocation") ?: true

                    if (originalBytes != null && compressedBytes != null) {
                        try {
                            val updatedBytes = addExif(originalBytes, compressedBytes, keepLocation)
                            result.success(updatedBytes)
                        } catch (e: Exception) {
                            result.error("EXIF_FAIL", e.message, null)
                        }
                    } else {
                        result.error("NULL_DATA", "Missing input data", null)
                    }
                }
            }
    }

private fun addExif(originalBytes: ByteArray, compressedBytes: ByteArray, keepLocation: Boolean): ByteArray {
    val originalExif = ExifInterface(ByteArrayInputStream(originalBytes))

    // Save compressed image to temp file
    val tempFile = File.createTempFile("compressed_", ".jpg", cacheDir)
    FileOutputStream(tempFile).use { it.write(compressedBytes) }

    val newExif = ExifInterface(tempFile.absolutePath)

    // Copy general EXIF tags
    val tags = listOf(
        ExifInterface.TAG_APERTURE,
        ExifInterface.TAG_DATETIME,
        ExifInterface.TAG_EXPOSURE_TIME,
        ExifInterface.TAG_FLASH,
        ExifInterface.TAG_FOCAL_LENGTH,
        ExifInterface.TAG_IMAGE_LENGTH,
        ExifInterface.TAG_IMAGE_WIDTH,
        ExifInterface.TAG_ISO_SPEED_RATINGS,
        ExifInterface.TAG_MAKE,
        ExifInterface.TAG_MODEL,
        ExifInterface.TAG_WHITE_BALANCE,
        ExifInterface.TAG_SOFTWARE,
        ExifInterface.TAG_USER_COMMENT,
        ExifInterface.TAG_SUBSEC_TIME,
        ExifInterface.TAG_SUBSEC_TIME_ORIGINAL,
        ExifInterface.TAG_SUBSEC_TIME_DIGITIZED
    )

    for (tag in tags) {
        val value = originalExif.getAttribute(tag)
        if (value != null) {
            newExif.setAttribute(tag, value)
        }
    }

    if (keepLocation) {
        val latLong = FloatArray(2)
        if (originalExif.getLatLong(latLong)) {
            // Set latitude
            val latRef = if (latLong[0] >= 0) "N" else "S"
            newExif.setAttribute(ExifInterface.TAG_GPS_LATITUDE, convertDecimalToDMS(latLong[0]))
            newExif.setAttribute(ExifInterface.TAG_GPS_LATITUDE_REF, latRef)

            // Set longitude
            val longRef = if (latLong[1] >= 0) "E" else "W"
            newExif.setAttribute(ExifInterface.TAG_GPS_LONGITUDE, convertDecimalToDMS(latLong[1]))
            newExif.setAttribute(ExifInterface.TAG_GPS_LONGITUDE_REF, longRef)

            // Copy altitude if available
            val altitude = originalExif.getAltitude(0.0)
            newExif.setAttribute(ExifInterface.TAG_GPS_ALTITUDE, "${(altitude * 1000).toInt()}/1000")
            newExif.setAttribute(ExifInterface.TAG_GPS_ALTITUDE_REF, "0")  // 0 = above sea level

            // Copy GPS Timestamp and Datestamp if available
            val gpsTimestamp = originalExif.getAttribute(ExifInterface.TAG_GPS_TIMESTAMP)
            if (gpsTimestamp != null) {
                newExif.setAttribute(ExifInterface.TAG_GPS_TIMESTAMP, gpsTimestamp)
            }

            val gpsDatestamp = originalExif.getAttribute(ExifInterface.TAG_GPS_DATESTAMP)
            if (gpsDatestamp != null) {
                newExif.setAttribute(ExifInterface.TAG_GPS_DATESTAMP, gpsDatestamp)
            }
        }
    }

    // Set orientation to ORIENTATION_NORMAL
    newExif.setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL.toString())
    newExif.saveAttributes()

    val finalBytes = tempFile.readBytes()
    tempFile.delete()

    return finalBytes
}
private fun convertDecimalToDMS(coordinate: Float): String {
    val absolute = Math.abs(coordinate)
    val degrees = absolute.toInt()
    val minutesFull = (absolute - degrees) * 60
    val minutes = minutesFull.toInt()
    val seconds = ((minutesFull - minutes) * 60 * 1000).toInt()

    return "$degrees/1,$minutes/1,$seconds/1000"
}



}
