import 'package:intl/intl.dart';

class SchedulePost {
  final String id;
  final String imageUrl;
  final String title;
  final List<String> tags;
  final String scheduleTime;
  final String rawScheduleTime;
  final String status;

  SchedulePost({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.scheduleTime,
    required this.rawScheduleTime,
    this.status = 'scheduled',
  });

  factory SchedulePost.fromJson(Map<String, dynamic> json) {
    String rawTime =
        json['scheduleTime']?.toString() ??
        json['scheduledAt']?.toString() ??
        '';

    String formattedTime = _formatScheduleTime(rawTime);

    // Robust parsing to handle nulls and different key names
    return SchedulePost(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      imageUrl:
          json['imageUrl']?.toString() ??
          json['media']?.toString() ??
          json['content']?.toString() ??
          json['url']?.toString() ??
          json['videoUrl']?.toString() ??
          json['thumbnail']?.toString() ??
          '',
      title:
          json['title']?.toString() ??
          json['caption']?.toString() ??
          json['contentDescription']?.toString() ??
          '',
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'].map((e) => e.toString()))
          : (json['hashtags'] is List)
          ? List<String>.from(json['hashtags'].map((e) => e.toString()))
          : [],
      scheduleTime: formattedTime,
      rawScheduleTime: rawTime,
      status: json['status']?.toString() ?? 'scheduled',
    );
  }

  static String _formatScheduleTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      // Handle format: {type: single, date: 2026-02-03T00:00:00.000Z, time: 17:00}
      if (raw.contains('date:') && raw.contains('time:')) {
        final datePart = raw.split('date:')[1].split(',')[0].trim();
        final timePart = raw.split('time:')[1].split('}')[0].trim();

        DateTime date = DateTime.parse(datePart);
        final timeSplit = timePart.split(':');
        int hour = int.parse(timeSplit[0]);
        int minute = int.parse(timeSplit[1]);

        DateTime combined = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        return DateFormat('EEE, d MMM yyyy - hh:mma').format(combined);
      }

      // Handle standard ISO format: 2026-02-03T17:00:00.000Z
      DateTime parsedDate = DateTime.parse(raw);
      return DateFormat('EEE, d MMM yyyy - hh:mma').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $raw -> $e");
      return raw; // Return original if parsing fails
    }
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
    String rawTime =
        json['scheduleTime']?.toString() ??
        json['scheduledAt']?.toString() ??
        '';

    return HistoryPost(
      imageUrl: json['imageUrl']?.toString() ?? json['media']?.toString() ?? '',
      title:
          json['title']?.toString() ??
          json['caption']?.toString() ??
          json['contentDescription']?.toString() ??
          '',
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'].map((e) => e.toString()))
          : (json['hashtags'] is List)
          ? List<String>.from(json['hashtags'].map((e) => e.toString()))
          : [],
      scheduleTime: SchedulePost._formatScheduleTime(rawTime),
      totalAudience: _toInt(json['totalAudience']),
      percentageGrowth: _toDouble(json['percentageGrowth']),
      facebookReach: _toInt(json['facebookReach']),
      instagramReach: _toInt(json['instagramReach']),
      tiktokReach: _toInt(json['tiktokReach']),
    );
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}
