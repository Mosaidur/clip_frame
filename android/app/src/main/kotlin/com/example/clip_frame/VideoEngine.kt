package com.example.clip_frame

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.util.LruCache
import java.io.ByteArrayOutputStream

class VideoEngine(private val context: Context) {

    private val retriever = MediaMetadataRetriever()
    private var currentPath: String? = null
    
    // Memory Cache for Thumbnails (Key: "path_timeMs", Value: Bitmap)
    private val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
    private val cacheSize = maxMemory / 4 // Use 1/4th of available memory
    private val memoryCache = object : LruCache<String, Bitmap>(cacheSize) {
        override fun sizeOf(key: String, bitmap: Bitmap): Int {
            return bitmap.byteCount / 1024
        }
    }

    fun initialize() {
        // Setup any global resources if needed
    }

    fun loadVideo(path: String): Long {
        if (currentPath != path) {
            currentPath = path
            retriever.setDataSource(path)
        }
        val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
        return durationStr?.toLongOrNull() ?: 0L
    }

    fun getThumbnail(path: String, timeMs: Long): ByteArray? {
        val key = "${path}_$timeMs"
        val cached = memoryCache.get(key)
        if (cached != null) {
            return bitmapToBytes(cached)
        }

        // In a real high-perf app, we might use closestSyncFrame for speed, 
        // but for accuracy we use OPTION_CLOSEST
        // OPTION_CLOSEST_SYNC is much faster but less accurate.
        // For timeline scrolling providing a "good enough" image fast is better.
        // We can try OPTION_CLOSEST_SYNC first.
        if (currentPath != path) {
            loadVideo(path)
        }

        try {
            // timesMs is in millis, setDataSource takes micros.
            val bitmap = retriever.getFrameAtTime(timeMs * 1000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
            
            if (bitmap != null) {
                // Resize for thumbnail (e.g., height 100px) to save memory/bandwidth
                val aspectRatio = bitmap.width.toFloat() / bitmap.height.toFloat()
                val targetHeight = 150
                val targetWidth = (targetHeight * aspectRatio).toInt()
                val scaled = Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, false)
                
                memoryCache.put(key, scaled)
                return bitmapToBytes(scaled)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun bitmapToBytes(bitmap: Bitmap): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, stream)
        return stream.toByteArray()
    }
    
    fun release() {
        try {
            retriever.release()
        } catch (e: Exception) {
            // Ignore
        }
    }
}
