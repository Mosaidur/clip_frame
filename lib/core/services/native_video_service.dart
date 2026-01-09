import 'package:flutter/services.dart';
import 'dart:typed_data';

class NativeVideoService {
  static const MethodChannel _channel = MethodChannel('com.example.clip_frame/video_engine');

  /// Initialize the native engine.
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print("Failed to initialize engine: ${e.message}");
    }
  }

  /// Load a video file into the native engine.
  /// Returns the duration of the video in milliseconds.
  Future<int> loadVideo(String path) async {
    try {
      final int duration = await _channel.invokeMethod('loadVideo', {'path': path});
      return duration;
    } on PlatformException catch (e) {
      print("Failed to load video: ${e.message}");
      return 0;
    }
  }

  /// Get a thumbnail for a specific timestamp (in ms).
  /// logicalIndex is used to identify the request order if needed.
  Future<Uint8List?> getThumbnail(String path, int timeMs) async {
    try {
      final Uint8List? bytes = await _channel.invokeMethod('getThumbnail', {
        'path': path,
        'timeMs': timeMs,
      });
      return bytes;
    } on PlatformException catch (e) {
      print("Failed to get thumbnail: ${e.message}");
      return null;
    }
  }

  /// Seek native player to timestamp.
  Future<void> seekTo(int timeMs) async {
    await _channel.invokeMethod('seekTo', {'timeMs': timeMs});
  }

  /// Play video from current position.
  Future<void> play() async {
    await _channel.invokeMethod('play');
  }

  /// Pause video.
  Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }
}
