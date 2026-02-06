import 'package:intl/intl.dart';

class SchedulePost {
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final String title;
  final List<String> tags;
  final String scheduleTime;
  final String rawScheduleTime;
  final String status;
  final String contentType;
  final DateTime? createdAt;

  SchedulePost({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.title,
    required this.tags,
    required this.scheduleTime,
    required this.rawScheduleTime,
    this.status = 'scheduled',
    this.contentType = 'post',
    this.createdAt,
  });

  factory SchedulePost.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SchedulePost(
        id: '',
        imageUrl: '',
        title: 'Unknown',
        tags: [],
        scheduleTime: '',
        rawScheduleTime: '',
      );
    }
    // Safe extraction of date/time from 'scheduledAt' if it's an object (like in ContentItem)
    String rawTime = '';
    if (json['scheduledAt'] is Map) {
      final scheduledAt = json['scheduledAt'];
      if (scheduledAt['date'] != null && scheduledAt['time'] != null) {
        rawTime = "date: ${scheduledAt['date']}, time: ${scheduledAt['time']}";
      } else {
        rawTime = scheduledAt.toString();
      }
    } else {
      rawTime =
          json['scheduleTime']?.toString() ??
          json['scheduledAt']?.toString() ??
          '';
    }

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }

    String formattedTime = _formatScheduleTime(rawTime, createdAt: createdAt);

    return SchedulePost(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      imageUrl:
          (json['mediaUrls'] is List && (json['mediaUrls'] as List).isNotEmpty)
          ? json['mediaUrls'][0].toString()
          : json['imageUrl']?.toString() ??
                json['media']?.toString() ??
                json['content']?.toString() ??
                json['url']?.toString() ??
                json['videoUrl']?.toString() ??
                '',
      thumbnailUrl:
          json['thumbnail']?.toString() ??
          json['cover']?.toString() ??
          json['coverImage']?.toString() ??
          json['image']?.toString(), // Try to find a specific thumbnail field
      title:
          json['caption']?.toString() ??
          json['title']?.toString() ??
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
      contentType: json['contentType']?.toString() ?? 'post',
      createdAt: createdAt,
    );
  }

  static String _formatScheduleTime(String raw, {DateTime? createdAt}) {
    if (raw.isEmpty || raw == "{type: any}") {
      if (createdAt != null) {
        return DateFormat('EEE, d MMM yyyy - hh:mma').format(createdAt);
      }
      return '';
    }
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
      if (createdAt != null) {
        return DateFormat('EEE, d MMM yyyy - hh:mma').format(createdAt);
      }
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
  final String contentType;

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
    this.contentType = 'post',
  });

  factory HistoryPost.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HistoryPost(
        imageUrl: '',
        title: 'Unknown',
        tags: [],
        scheduleTime: '',
        totalAudience: 0,
        percentageGrowth: 0.0,
        facebookReach: 0,
        instagramReach: 0,
        tiktokReach: 0,
      );
    }
    // Safe extraction of date/time from 'scheduledAt' if it's an object
    String rawTime = '';
    if (json['scheduledAt'] is Map) {
      final scheduledAt = json['scheduledAt'];
      if (scheduledAt['date'] != null && scheduledAt['time'] != null) {
        rawTime = "date: ${scheduledAt['date']}, time: ${scheduledAt['time']}";
      } else {
        rawTime = scheduledAt.toString();
      }
    } else {
      rawTime =
          json['scheduleTime']?.toString() ??
          json['scheduledAt']?.toString() ??
          '';
    }

    // Default reach/growth values
    int totalAudience = 0;
    double percentageGrowth = 0.0;
    int fbReach = 0;
    int igReach = 0;
    int ttReach = 0;

    // Aggregate stats from list/map (defensive parsing)
    if (json['stats'] is List) {
      for (var stat in json['stats']) {
        if (stat is Map) {
          final platform = stat['platform']?.toString().toLowerCase() ?? '';
          final reach = _toInt(
            stat['reach'] ?? stat['views'] ?? stat['audience'] ?? 0,
          );
          final growth = _toDouble(
            stat['growth'] ?? stat['percentageGrowth'] ?? 0.0,
          );

          totalAudience += reach;
          percentageGrowth +=
              growth; // Usually we'd average this, but following dashboard pattern

          if (platform.contains('facebook') || platform == 'fb')
            fbReach += reach;
          else if (platform.contains('instagram') || platform == 'ig')
            igReach += reach;
          else if (platform.contains('tiktok') || platform == 'tt')
            ttReach += reach;
        }
      }
    } else if (json['stats'] is Map) {
      final stats = json['stats'];
      totalAudience = _toInt(
        stats['totalAudience'] ?? stats['reach'] ?? stats['views'] ?? 0,
      );
      percentageGrowth = _toDouble(
        stats['percentageGrowth'] ?? stats['growth'] ?? 0.0,
      );
      fbReach = _toInt(stats['facebookReach'] ?? stats['fbReach'] ?? 0);
      igReach = _toInt(stats['instagramReach'] ?? stats['igReach'] ?? 0);
      ttReach = _toInt(stats['tiktokReach'] ?? stats['ttReach'] ?? 0);
    }

    // Also check platformStatus for reach numbers
    if (json['platformStatus'] is Map) {
      final ps = json['platformStatus'];
      ps.forEach((key, value) {
        if (value is Map) {
          final reach = _toInt(value['reach'] ?? value['views'] ?? 0);
          if (key.toLowerCase().contains('facebook'))
            fbReach = reach;
          else if (key.toLowerCase().contains('instagram'))
            igReach = reach;
          else if (key.toLowerCase().contains('tiktok'))
            ttReach = reach;
        }
      });
      // Re-calculate total audience if it's still 0
      if (totalAudience == 0) totalAudience = fbReach + igReach + ttReach;
    }

    return HistoryPost(
      imageUrl:
          (json['mediaUrls'] is List && (json['mediaUrls'] as List).isNotEmpty)
          ? json['mediaUrls'][0].toString()
          : json['imageUrl']?.toString() ?? json['media']?.toString() ?? '',
      title:
          json['caption']?.toString() ??
          json['title']?.toString() ??
          json['contentDescription']?.toString() ??
          '',
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'].map((e) => e.toString()))
          : (json['hashtags'] is List)
          ? List<String>.from(json['hashtags'].map((e) => e.toString()))
          : [],
      scheduleTime: SchedulePost._formatScheduleTime(rawTime),
      totalAudience: totalAudience,
      percentageGrowth: percentageGrowth,
      facebookReach: fbReach,
      instagramReach: igReach,
      tiktokReach: ttReach,
      contentType: json['contentType']?.toString() ?? 'post',
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
