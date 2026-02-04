import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:flutter/foundation.dart';

class ScheduleService {
  /// Fetch all scheduled posts
  static Future<List<SchedulePost>> fetchScheduledPosts() async {
    try {
      final token = await AuthService.getToken();
      debugPrint("📅 ScheduleService: Fetching from ${Urls.schedulingUrl}");

      final response = await NetworkCaller.getRequest(
        url: Urls.schedulingUrl,
        token: token,
      );

      debugPrint(
        "📅 ScheduleService: Response success = ${response.isSuccess}",
      );
      debugPrint(
        "📅 ScheduleService: Response body type = ${response.responseBody.runtimeType}",
      );

      if (response.isSuccess && response.responseBody != null) {
        final data = response.responseBody!;

        // Handle both array and object with 'data' field
        List<dynamic> contentList = [];
        if (data is List) {
          contentList = data as List<dynamic>;
          debugPrint(
            "📅 ScheduleService: Data is List with ${contentList.length} items",
          );
        } else if (data is Map) {
          debugPrint("📅 ScheduleService: Data is Map with keys: ${data.keys}");

          // Debug: Check what's in 'data' field
          if (data.containsKey('data')) {
            var responseData = data['data'];
            debugPrint(
              "📅 ScheduleService: 'data' field type: ${responseData.runtimeType}",
            );

            // Handle nested structure like ScheduleController: data.data.data
            if (responseData is Map && responseData['data'] != null) {
              contentList = responseData['data'] as List<dynamic>;
              debugPrint(
                "📅 ScheduleService: Found NESTED 'data.data' with ${contentList.length} items",
              );
            } else if (responseData is List) {
              contentList = responseData as List<dynamic>;
              debugPrint(
                "📅 ScheduleService: 'data' is List with ${contentList.length} items",
              );
            }
          } else if (data['contents'] is List) {
            contentList = data['contents'] as List<dynamic>;
            debugPrint(
              "📅 ScheduleService: Found 'contents' field with ${contentList.length} items",
            );
          }
        }

        debugPrint(
          "📅 ScheduleService: Fetched ${contentList.length} scheduled posts",
        );

        final posts = contentList
            .map((json) => SchedulePost.fromJson(json))
            .toList();
        debugPrint(
          "📅 ScheduleService: Parsed ${posts.length} SchedulePost objects",
        );

        if (posts.isNotEmpty) {
          debugPrint(
            "📅 ScheduleService: First post - ${posts[0].title} on ${posts[0].scheduleTime}",
          );
        }

        return posts;
      } else {
        debugPrint("❌ ScheduleService: Response failed or body is null");
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint("⛔ ScheduleService Error: $e");
      debugPrint("⛔ StackTrace: $stackTrace");
      return [];
    }
  }

  /// Group posts by date for calendar display
  static Map<DateTime, List<SchedulePost>> groupPostsByDate(
    List<SchedulePost> posts,
  ) {
    Map<DateTime, List<SchedulePost>> grouped = {};

    debugPrint("📅 ScheduleService: Grouping ${posts.length} posts by date");

    for (var post in posts) {
      try {
        debugPrint("📅 Processing post: ${post.title}");
        debugPrint("📅 Raw schedule time: ${post.rawScheduleTime}");

        DateTime date = extractDate(post);
        debugPrint("📅 Extracted DateTime: $date");

        DateTime dateOnly = DateTime(date.year, date.month, date.day);
        debugPrint("📅 Date only (for grouping): $dateOnly");

        if (!grouped.containsKey(dateOnly)) {
          grouped[dateOnly] = [];
        }
        grouped[dateOnly]!.add(post);
        debugPrint(
          "📅 Added to group. Total for $dateOnly: ${grouped[dateOnly]!.length}",
        );
      } catch (e) {
        debugPrint("Error grouping post: $e");
        debugPrint(
          "Post title: ${post.title}, rawScheduleTime: ${post.rawScheduleTime}",
        );
      }
    }

    debugPrint("📅 ScheduleService: Grouped into ${grouped.length} dates");
    grouped.forEach((date, postList) {
      debugPrint("📅   $date: ${postList.length} posts");
    });

    return grouped;
  }

  /// Extract DateTime from raw schedule time string
  static DateTime extractDate(SchedulePost post) {
    String rawTime = post.rawScheduleTime;
    try {
      if (rawTime.isEmpty || rawTime == "{type: any}") {
        return (post.createdAt ?? DateTime.now()).toLocal();
      }

      if (rawTime.contains('date:') && rawTime.contains('time:')) {
        final datePart = rawTime.split('date:')[1].split(',')[0].trim();
        final timePart = rawTime.split('time:')[1].split('}')[0].trim();

        DateTime date = DateTime.parse(datePart);
        final timeSplit = timePart.split(':');
        int hour = int.parse(timeSplit[0]);
        int minute = int.parse(timeSplit[1]);

        return DateTime(date.year, date.month, date.day, hour, minute); // Local
      }

      return DateTime.parse(rawTime).toLocal();
    } catch (e) {
      return (post.createdAt ?? DateTime.now()).toLocal();
    }
  }

  /// Get post count for a specific date
  static int getPostCountForDate(
    Map<DateTime, List<SchedulePost>> groupedPosts,
    DateTime date,
  ) {
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    return groupedPosts[dateOnly]?.length ?? 0;
  }
}
