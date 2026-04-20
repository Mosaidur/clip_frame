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

  final RxDouble downloadProgress = 0.0.obs;
  final RxString musicDownloadError = "".obs;

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

  Future<void> setMusic(String url, String title, {bool isRemote = false}) async {
    try {
      isMusicLoading.value = true;
      musicDownloadError.value = "";
      await _audioPlayer.stop();
      
      Duration? duration;
      if (isRemote) {
        // STREAMING: Start playing directly from URL while we download in background
        duration = await _audioPlayer.setUrl(url);
      } else {
        duration = await _audioPlayer.setFilePath(url);
      }
      
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
      musicDownloadError.value = "Could not load music.";
      Get.snackbar("Error", "Could not load music file.");
    } finally {
      isMusicLoading.value = false;
    }
  }

  Future<void> downloadAndSetMusic(String url, String title) async {
    try {
      isMusicLoading.value = true;
      loadingTrackUrl.value = url;
      downloadProgress.value = 0.0;
      musicDownloadError.value = "";
      
      // 1. START STREAMING IMMEDIATELY for better UX
      await setMusic(url, title, isRemote: true);

      // 2. CHECK CACHE
      final tempDir = await getTemporaryDirectory();
      // Use a stable filename based on URL to avoid redundant downloads
      final uri = Uri.parse(url);
      final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '_').replaceAll(' ', '_');
      final fileName = "cache_${uri.pathSegments.last.contains('.') ? uri.pathSegments.last : '$cleanTitle.mp3'}";
      final filePath = path.join(tempDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        debugPrint("⚡ Music found in cache: $filePath");
        // Update track source to local file once found
        currentTrack.value = currentTrack.value?.copyWith(url: filePath);
        downloadProgress.value = 1.0;
        return;
      }

      // 3. DOWNLOAD IN BACKGROUND (Increase timeout to 60s)
      debugPrint("🚀 Downloading music in background: $url");
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request).timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        final List<int> bytes = [];
        final totalLength = response.contentLength ?? 0;
        int downloaded = 0;

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          downloaded += chunk.length;
          if (totalLength > 0) {
            downloadProgress.value = downloaded / totalLength;
          }
        }

        await file.writeAsBytes(bytes);
        debugPrint("✅ Music downloaded to: $filePath");
        
        // Update the current track to use the local file (critical for FFmpeg render later)
        if (currentTrack.value?.url == url) {
          currentTrack.value = currentTrack.value?.copyWith(url: filePath);
        }
      } else {
        throw Exception("Failed to download music. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⛔ Error downloading music: $e");
      String msg = "Failed to download background music.";
      if (e is TimeoutException) msg = "Download timed out. High quality audio might be unavailable.";
      musicDownloadError.value = msg;
      // Don't show snackbar if streaming is already working
      if (!isPlaying.value) Get.snackbar("Download Error", msg);
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

  void stopSync() {
    _audioPlayer.stop();
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
