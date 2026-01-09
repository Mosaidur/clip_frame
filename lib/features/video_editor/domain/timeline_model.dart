class TimelineClip {
  final String id;
  final String videoPath;
  Duration sourceStartTime;
  Duration sourceEndTime;
  double playbackSpeed;
  
  // UI helpers
  bool isSelected;

  TimelineClip({
    required this.id,
    required this.videoPath,
    required this.sourceStartTime,
    required this.sourceEndTime,
    this.playbackSpeed = 1.0,
    this.isSelected = false,
  });

  Duration get duration => (sourceEndTime - sourceStartTime) * (1 / playbackSpeed);

  TimelineClip copyWith({
    Duration? sourceStartTime,
    Duration? sourceEndTime,
    double? playbackSpeed,
    bool? isSelected,
  }) {
    return TimelineClip(
      id: this.id,
      videoPath: this.videoPath,
      sourceStartTime: sourceStartTime ?? this.sourceStartTime,
      sourceEndTime: sourceEndTime ?? this.sourceEndTime,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
