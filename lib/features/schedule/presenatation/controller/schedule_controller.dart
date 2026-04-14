import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import '../../data/model.dart';

import 'package:clip_frame/core/services/database_service.dart';
import 'package:clip_frame/core/services/notification_service.dart';
import 'package:intl/intl.dart';

class ScheduleController extends GetxController {
  var scheduledPosts = <SchedulePost>[].obs;
  var historyPosts = <HistoryPost>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var lastSyncedAt = Rxn<DateTime>();

  // Add selected tab state
  var selectedTab = 0.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    print("🔥 [ScheduleController] onInit called");
    _loadFromCache();
    _startPolling();
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedScheduled = await DatabaseService.getPostsByStatus(
        "scheduled",
      );
      final cachedDrafts = await DatabaseService.getPostsByStatus("draft");

      scheduledPosts.assignAll([...cachedScheduled, ...cachedDrafts]);
      print(
        "📦 [ScheduleController] Loaded ${scheduledPosts.length} posts from cache",
      );
    } catch (e) {
      print("⚠️ [ScheduleController] Error loading from cache: $e");
    }
  }

  void _startPolling() {
    print("⏲️ [ScheduleController] Starting polling timer (30s)");
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!isLoading.value) {
        print("⏲️ [ScheduleController] Auto-refreshing data...");
        loadAllData();
      }
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    print("⏲️ [ScheduleController] Polling timer cancelled");
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    print("🔥 [ScheduleController] onReady called - starting data load");
    loadAllData();
  }

  Future<void> loadAllData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print("🚀 [ScheduleController] Starting to fetch all data...");
      await fetchSchedules("scheduled", skipLoading: true);
      await fetchSchedules("draft", skipLoading: true); // Added draft fetch
      await fetchSchedules("published", skipLoading: true);
      print("✅ [ScheduleController] All data fetching process completed.");
    } catch (e) {
      print("⛔ [ScheduleController] Error in _loadAllData: $e");
      errorMessage.value = "Failed to load data: $e";
    } finally {
      isLoading.value = false;
      print("🏁 [ScheduleController] isLoading set to false");
    }
  }

  Future<void> fetchSchedules(String status, {bool skipLoading = false}) async {
    if (!skipLoading) isLoading.value = true;
    errorMessage.value = '';

    print("📡 [ScheduleController] Preparing to fetch $status...");
    final String? token = await AuthService.getToken();

    String baseUrlClean = Urls.schedulingUrl.split('?')[0];
    String url = "$baseUrlClean?status=$status";

    print("📡 [ScheduleController] Fetching $status from: $url");

    if (token == null) {
      print("⛔ [ScheduleController] Token is null, cannot fetch $status.");
      if (!skipLoading) isLoading.value = false;
      return;
    }

    try {
      final response = await NetworkCaller.getRequest(url: url, token: token);

      print(
        "📥 [ScheduleController] Response for $status: ${response.statusCode}",
      );

      if (response.isSuccess) {
        lastSyncedAt.value = DateTime.now();
        if (response.responseBody != null &&
            response.responseBody!['data'] != null) {
          var responseData = response.responseBody!['data'];

          List<dynamic> listData = [];

          if (responseData is Map && responseData['data'] != null) {
            listData = responseData['data'];
          } else if (responseData is List) {
            listData = responseData;
          }

          print(
            "📦 [ScheduleController] Parsed ${listData.length} items for $status",
          );

          if (status == "scheduled") {
            final posts = listData.map((json) {
              if (json is Map<String, dynamic>) {
                json['status'] = 'scheduled';
              }
              return SchedulePost.fromJson(json);
            }).toList();

            scheduledPosts.assignAll(posts);
            // Save to cache
            await DatabaseService.savePosts(posts);
            // Schedule notifications for newly fetched scheduled posts
            _syncNotifications(posts);
          } else if (status == "draft") {
            // Append drafts to scheduled posts
            List<SchedulePost> drafts = listData.map((json) {
              if (json is Map<String, dynamic>) {
                json['status'] = 'draft';
              }
              return SchedulePost.fromJson(json);
            }).toList();
            scheduledPosts.addAll(drafts);
            // Save to cache
            await DatabaseService.savePosts(drafts);
          } else if (status == "published") {
            historyPosts.assignAll(
              listData.map((json) {
                if (json is Map<String, dynamic>) {
                  json['status'] = 'published';
                }
                return HistoryPost.fromJson(json);
              }).toList(),
            );
          }
        } else {
          print(
            "⚠️ [ScheduleController] Response body or data is null for $status",
          );
        }
      } else {
        print(
          "⛔ [ScheduleController] Fetch failed for $status: ${response.errorMessage}",
        );
        errorMessage.value =
            response.errorMessage ?? 'Failed to fetch schedules';
      }
    } catch (e) {
      print("⛔ [ScheduleController] Exception in fetchSchedules ($status): $e");
      errorMessage.value = "Error: $e";
    }

    if (!skipLoading) isLoading.value = false;
  }

  void _syncNotifications(List<SchedulePost> posts) {
    for (var post in posts) {
      if (post.status == 'scheduled') {
        try {
          // Extract DateTime from rawScheduleTime or similar
          // This depends on how _formatScheduleTime works, but let's try to parse
          // In model.dart, it uses rawScheduleTime with 'date:' and 'time:'
          DateTime? scheduledDate;
          if (post.rawScheduleTime.contains('date:') &&
              post.rawScheduleTime.contains('time:')) {
            final datePart = post.rawScheduleTime
                .split('date:')[1]
                .split(',')[0]
                .trim();
            final timePart = post.rawScheduleTime
                .split('time:')[1]
                .split('}')[0]
                .trim();
            DateTime date = DateTime.parse(datePart);
            final timeSplit = timePart.split(':');
            scheduledDate = DateTime(
              date.year,
              date.month,
              date.day,
              int.parse(timeSplit[0]),
              int.parse(timeSplit[1]),
            );
          } else {
            scheduledDate = DateTime.tryParse(post.rawScheduleTime);
          }

          if (scheduledDate != null) {
            // Use hash of ID as notification ID
            int notificationId = post.id.hashCode.abs();
            NotificationService.scheduleNotification(
              id: notificationId,
              title: "Time to post!",
              body: "Your post '${post.title}' is scheduled for now.",
              scheduledDate: scheduledDate,
              payload: post.id,
            );
          }
        } catch (e) {
          print(
            "⚠️ [ScheduleController] Could not schedule notification for post ${post.id}: $e",
          );
        }
      }
    }
  }

  Future<void> deletePost(String id) async {
    print("🗑️ [ScheduleController] Prompting to delete post: $id");

    // Using a more structured dialog with styling matching the app
    bool? confirmed = await Get.defaultDialog<bool>(
      title: "Delete Post",
      middleText:
          "Are you sure you want to delete this post? This action cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFF277F),
      onConfirm: () => Get.back(result: true),
    );

    if (confirmed == true) {
      isLoading.value = true;
      final String? token = await AuthService.getToken();
      if (token == null) return;

      final url = Urls.deleteContentUrl(id);
      final response = await NetworkCaller.deleteRequest(
        url: url,
        token: token,
      );

      if (response.isSuccess) {
        scheduledPosts.removeWhere((post) => post.id == id);
        // Remove from DB and cancel notification
        await DatabaseService.deletePost(id);
        await NotificationService.cancelNotification(id.hashCode.abs());

        Get.snackbar(
          "Success",
          "Post deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response.errorMessage ?? "Failed to delete post",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
      isLoading.value = false;
    }
  }

  // Edit logic usually involves navigation, but providing API call functionality here
  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    final String? token = await AuthService.getToken();
    if (token == null) return;

    final url = Urls.updateContentUrl(id);
    final response = await NetworkCaller.patchRequest(
      url: url,
      body: data,
      token: token,
    );

    if (response.isSuccess) {
      loadAllData(); // Refresh list
      Get.snackbar("Success", "Post updated successfully");
    } else {
      Get.snackbar("Error", response.errorMessage ?? "Failed to update post");
    }
    isLoading.value = false;
  }
}
