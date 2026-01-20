package com.example.clip_frame

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.clip_frame/video_engine"
    private lateinit var videoEngine: VideoEngine

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        videoEngine = VideoEngine(context)

        io.flutter.plugin.common.MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    videoEngine.initialize()
                    result.success(null)
                }
                "loadVideo" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val duration = videoEngine.loadVideo(path)
                        result.success(duration)
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is null", null)
                    }
                }
                "getThumbnail" -> {
                    val path = call.argument<String>("path")
                    val timeMs = call.argument<Int>("timeMs")?.toLong()
                    
                    if (path != null && timeMs != null) {
                        // processing heavy task on background thread is better, 
                        // but getFrameAtTime is blocking. 
                        // For a simple PoC we run here, but ideally we use a scope.
                        // However, MethodChannel handlers run on Main Thread. 
                        // This WILL block UI if too slow. 
                        // For "Production Scale" we must thread this.
                        Thread {
                            val bytes = videoEngine.getThumbnail(path, timeMs)
                            runOnUiThread {
                                result.success(bytes)
                            }
                        }.start()
                    } else {
                        result.error("INVALID_ARGS", "Missing path or time", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onDestroy() {
        videoEngine.release()
        super.onDestroy()
    }
}
