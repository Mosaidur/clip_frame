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

  @override
  void onInit() {
    super.onInit();
    print("🔥 [ScheduleController] onInit called");
    _loadFromCache();
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


  @override
  void onClose() {
    print("⏲️ [ScheduleController] Controller closing - cleaning up");
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

    // SILENT REFRESH: Only show blocking loader if we have NO data yet
    if (scheduledPosts.isEmpty && historyPosts.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      print("🚀 [ScheduleController] Starting parallel fetch for all data...");
      
      final results = await Future.wait([
        _fetchStatusData("scheduled"),
        _fetchStatusData("draft"),
        _fetchStatusData("published"),
      ]);

      final List<SchedulePost> fetchedSchedules = (results[0] ?? []).cast<SchedulePost>();
      final List<SchedulePost> fetchedDrafts = (results[1] ?? []).cast<SchedulePost>();
      final List<HistoryPost> fetchedHistory = (results[2] ?? []).cast<HistoryPost>();

      // Update Observables in one go to prevent UI flickering
      scheduledPosts.assignAll([...fetchedSchedules, ...fetchedDrafts]);
      historyPosts.assignAll(fetchedHistory);

      // Persist to Cache
      await DatabaseService.savePosts([...fetchedSchedules, ...fetchedDrafts]);
      
      // Sync Notifications
      _syncNotifications(fetchedSchedules);

      print("✅ [ScheduleController] All data fetching process completed.");
    } catch (e) {
      print("⛔ [ScheduleController] Error in loadAllData: $e");
      errorMessage.value = "Failed to load data: $e";
    } finally {
      isLoading.value = false;
      print("🏁 [ScheduleController] isLoading set to false");
    }
  }

  /// Internal helper to fetch and parse data without updating the UI directly
  Future<List<dynamic>?> _fetchStatusData(String status) async {
    print("📡 [ScheduleController] Background fetching $status...");
    final String? token = await AuthService.getToken();
    if (token == null) return null;

    String baseUrlClean = Urls.schedulingUrl.split('?')[0];
    String url = "$baseUrlClean?status=$status";

    try {
      final response = await NetworkCaller.getRequest(url: url, token: token);
      if (response.isSuccess && response.responseBody != null && response.responseBody!['data'] != null) {
        var responseData = response.responseBody!['data'];
        List<dynamic> listData = [];

        if (responseData is Map && responseData['data'] != null) {
          listData = responseData['data'];
        } else if (responseData is List) {
          listData = responseData;
        }

        if (status == "published") {
          return listData.map((json) {
            if (json is Map<String, dynamic>) json['status'] = 'published';
            return HistoryPost.fromJson(json);
          }).toList();
        } else {
          return listData.map((json) {
            if (json is Map<String, dynamic>) json['status'] = status;
            return SchedulePost.fromJson(json);
          }).toList();
        }
      }
    } catch (e) {
      print("⛔ [ScheduleController] Error fetching $status: $e");
    }
    return null;
  }

  @Deprecated("Use loadAllData for optimized fetching")
  Future<void> fetchSchedules(String status, {bool skipLoading = false}) async {
    await loadAllData(); 
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
