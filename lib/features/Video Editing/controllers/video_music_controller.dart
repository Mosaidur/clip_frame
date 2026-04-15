import 'dart:async';
import 'package:clip_frame/features/Video%20Editing/models/audio_settings_model.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class VideoMusicController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Rxn<MusicTrack> currentTrack = Rxn<MusicTrack>();
  final RxBool isPlaying = false.obs;
  final RxBool isMusicLoading = false.obs;
  final RxString loadingTrackUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    _setupAudioSession();
  }

  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
        flags: AndroidAudioFlags.none,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    
    // Listen for interruptions (calls, other apps)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        pauseSync();
      }
    });
  }

  Future<void> setMusic(String url, String title) async {
    try {
      isMusicLoading.value = true;
      await _audioPlayer.stop();
      
      final duration = await _audioPlayer.setFilePath(url);
      
      if (duration != null) {
        currentTrack.value = MusicTrack(
          url: url,
          title: title,
          totalDuration: duration,
        );
        
        await _audioPlayer.setVolume(currentTrack.value!.volume);
        await _audioPlayer.setLoopMode(LoopMode.all);
      }
    } catch (e) {
      debugPrint("⛔ Error setting music: $e");
      Get.snackbar("Error", "Could not load music file.");
    } finally {
      isMusicLoading.value = false;
    }
  }

  Future<void> downloadAndSetMusic(String url, String title) async {
    try {
      isMusicLoading.value = true;
      loadingTrackUrl.value = url;
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      // Use URL hash or title to avoid conflicts, but keeping it simple
      final fileName = "${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.mp3";
      final filePath = path.join(tempDir.path, fileName);
      
      final file = File(filePath);
      
      debugPrint("🚀 Downloading music: $url");
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("✅ Music downloaded to: $filePath");
        
        await setMusic(filePath, title);
      } else {
        throw Exception("Failed to download music. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⛔ Error downloading music: $e");
      String msg = "Failed to download background music.";
      if (e is TimeoutException) msg = "Download timed out. Please check your internet.";
      Get.snackbar("Download Error", msg);
    } finally {
      isMusicLoading.value = false;
      loadingTrackUrl.value = "";
    }
  }

  void removeMusic() {
    _audioPlayer.stop();
    currentTrack.value = null;
    isPlaying.value = false;
  }

  void updateVolume(double volume) {
    if (currentTrack.value != null) {
      currentTrack.value!.volume = volume;
      _audioPlayer.setVolume(volume);
    }
  }

  void updateTrim(Duration start, Duration end) {
    if (currentTrack.value != null) {
      currentTrack.value!.trimStart = start;
      currentTrack.value!.trimEnd = end;
    }
  }

  /// Synchronize music with video position
  /// videoPosition: current position of the VideoPlayer
  Future<void> syncWithVideo(Duration videoPosition, bool isVideoPlaying) async {
    if (currentTrack.value == null || isMusicLoading.value) return;

    // Calculate the position in the audio file
    // audioPos = videoPos + trimStart
    final Duration targetAudioPos = videoPosition + currentTrack.value!.trimStart;

    // Check if we need to seek to maintain sync (if drift > 200ms)
    final currentAudioPos = _audioPlayer.position;
    final diff = (currentAudioPos.inMilliseconds - targetAudioPos.inMilliseconds).abs();

    if (diff > 200) {
      await _audioPlayer.seek(targetAudioPos);
    }

    if (isVideoPlaying && !_audioPlayer.playing) {
      _audioPlayer.play();
      isPlaying.value = true;
    } else if (!isVideoPlaying && _audioPlayer.playing) {
      _audioPlayer.pause();
      isPlaying.value = false;
    }
  }

  void pauseSync() {
    _audioPlayer.pause();
    isPlaying.value = false;
  }

  

  void resumeSync() {
    if (currentTrack.value != null) {
      _audioPlayer.play();
      isPlaying.value = true;
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
