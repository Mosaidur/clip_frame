import 'dart:io';

class MusicTrack {
  final String url; // Can be a local path or a remote URL
  final String title;
  final Duration totalDuration;
  
  // Settings
  double volume;
  Duration trimStart;
  Duration trimEnd;
  Duration offsetInVideo; // When the music should start playing relative to video start
  bool loop;
  
  MusicTrack({
    required this.url,
    required this.title,
    required this.totalDuration,
    this.volume = 0.5,
    this.trimStart = Duration.zero,
    Duration? trimEnd,
    this.offsetInVideo = Duration.zero,
    this.loop = true,
  }) : trimEnd = trimEnd ?? totalDuration;

  // Helper to get active duration after trimming
  Duration get activeDuration => trimEnd - trimStart;

  MusicTrack copyWith({
    String? url,
    String? title,
    Duration? totalDuration,
    double? volume,
    Duration? trimStart,
    Duration? trimEnd,
    Duration? offsetInVideo,
    bool? loop,
  }) {
    return MusicTrack(
      url: url ?? this.url,
      title: title ?? this.title,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      offsetInVideo: offsetInVideo ?? this.offsetInVideo,
      loop: loop ?? this.loop,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'volume': volume,
      'trimStartMs': trimStart.inMilliseconds,
      'trimEndMs': trimEnd.inMilliseconds,
      'offsetMs': offsetInVideo.inMilliseconds,
      'loop': loop,
    };
  }
}
