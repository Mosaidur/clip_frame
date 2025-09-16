// schedule_post_model.dart
class SchedulePost {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final String scheduleTime;

  SchedulePost({
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.scheduleTime,
  });

  factory SchedulePost.fromJson(Map<String, dynamic> json) {
    return SchedulePost(
      imageUrl: json['imageUrl'],
      title: json['title'],
      tags: List<String>.from(json['tags']),
      scheduleTime: json['scheduleTime'],
    );
  }
}

// history_post_model.dart
class HistoryPost {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final String scheduleTime;
  final int totalAudience;
  final double percentageGrowth;
  final int facebookReach;
  final int instagramReach;
  final int tiktokReach;

  HistoryPost({
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.scheduleTime,
    required this.totalAudience,
    required this.percentageGrowth,
    required this.facebookReach,
    required this.instagramReach,
    required this.tiktokReach,
  });

  factory HistoryPost.fromJson(Map<String, dynamic> json) {
    return HistoryPost(
      imageUrl: json['imageUrl'],
      title: json['title'],
      tags: List<String>.from(json['tags']),
      scheduleTime: json['scheduleTime'],
      totalAudience: json['totalAudience'],
      percentageGrowth: json['percentageGrowth'],
      facebookReach: json['facebookReach'],
      instagramReach: json['instagramReach'],
      tiktokReach: json['tiktokReach'],
    );
  }
}
