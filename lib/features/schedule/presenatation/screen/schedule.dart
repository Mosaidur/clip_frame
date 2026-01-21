// schedule_controller.dart
import 'package:get/get.dart';
import '../../data/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/SchedulePost.dart';
import '../widgets/history.dart';

class ScheduleController extends GetxController {
  var scheduledPosts = <SchedulePost>[].obs;
  var historyPosts = <HistoryPost>[].obs;

  // Add selected tab state
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDemoData();
  }

  void loadDemoData() {
    // Dummy Scheduled posts
    scheduledPosts.value =   [
      SchedulePost(
        imageUrl: "https://picsum.photos/400/200",
        title: "Eid Festival Offer",
        tags: ["eid", "discount", "shopping"],
        scheduleTime: "12 Sept 2025 - 10:00 AM",
      ),
      SchedulePost(
        imageUrl: "https://picsum.photos/400/201",
        title: "Tech Product Launch",
        tags: ["tech", "launch", "new"],
        scheduleTime: "15 Sept 2025 - 6:00 PM",
      ),
    ];

    // Dummy History posts
    historyPosts.value =    [
      HistoryPost(
        imageUrl: "https://picsum.photos/400/210",
        title: "Summer Sale Campaign",
        tags: ["sale", "summer", "offer"],
        scheduleTime: "2 Sept 2025 - 8:00 PM",
        totalAudience: 12300,
        percentageGrowth: 15.2,
        facebookReach: 4000,
        instagramReach: 5000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/211",
        title: "Product Awareness Drive",
        tags: ["awareness", "product"],
        scheduleTime: "1 Sept 2025 - 7:00 PM",
        totalAudience: 9800,
        percentageGrowth: -4.5,
        facebookReach: 3500,
        instagramReach: 4000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/210",
        title: "Summer Sale Campaign",
        tags: ["sale", "summer", "offer"],
        scheduleTime: "2 Sept 2025 - 8:00 PM",
        totalAudience: 12300,
        percentageGrowth: 15.2,
        facebookReach: 4000,
        instagramReach: 5000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/211",
        title: "Product Awareness Drive",
        tags: ["awareness", "product"],
        scheduleTime: "1 Sept 2025 - 7:00 PM",
        totalAudience: 9800,
        percentageGrowth: -4.5,
        facebookReach: 3500,
        instagramReach: 4000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/210",
        title: "Summer Sale Campaign",
        tags: ["sale", "summer", "offer"],
        scheduleTime: "2 Sept 2025 - 8:00 PM",
        totalAudience: 12300,
        percentageGrowth: 15.2,
        facebookReach: 4000,
        instagramReach: 5000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/211",
        title: "Product Awareness Drive",
        tags: ["awareness", "product"],
        scheduleTime: "1 Sept 2025 - 7:00 PM",
        totalAudience: 9800,
        percentageGrowth: -4.5,
        facebookReach: 3500,
        instagramReach: 4000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/210",
        title: "Summer Sale Campaign",
        tags: ["sale", "summer", "offer"],
        scheduleTime: "2 Sept 2025 - 8:00 PM",
        totalAudience: 12300,
        percentageGrowth: 15.2,
        facebookReach: 4000,
        instagramReach: 5000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/211",
        title: "Product Awareness Drive",
        tags: ["awareness", "product"],
        scheduleTime: "1 Sept 2025 - 7:00 PM",
        totalAudience: 9800,
        percentageGrowth: -4.5,
        facebookReach: 3500,
        instagramReach: 4000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/210",
        title: "Summer Sale Campaign",
        tags: ["sale", "summer", "offer"],
        scheduleTime: "2 Sept 2025 - 8:00 PM",
        totalAudience: 12300,
        percentageGrowth: 15.2,
        facebookReach: 4000,
        instagramReach: 5000,
        tiktokReach: 2300,
      ),
      HistoryPost(
        imageUrl: "https://picsum.photos/400/211",
        title: "Product Awareness Drive",
        tags: ["awareness", "product"],
        scheduleTime: "1 Sept 2025 - 7:00 PM",
        totalAudience: 9800,
        percentageGrowth: -4.5,
        facebookReach: 3500,
        instagramReach: 4000,
        tiktokReach: 2300,
      ),
    ];
  }
}



class ScheduleScreenPage extends StatelessWidget {

  const ScheduleScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? imageUrl ;
    final controller = Get.put(ScheduleController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: SafeArea(
          bottom: false, // Let navigation bar handle the bottom if needed, or keep it true if you want items away from system nav
          child: Column(
            children: [
              // Top Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Menu Icon
                    _roundIcon(Icons.menu, () {
                      // Add your menu action here
                    }),

                    // Title
                    const Text(
                      "Post",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    // Profile Image / Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: ClipOval(
                        child: imageUrl == null || imageUrl!.isEmpty
                            ? Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        )
                            : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  // height: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      color: Colors.white
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [

                        SizedBox(height: 10,),
                        // Custom Tab Switcher
                        Obx(() {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => controller.selectedTab.value = 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: controller.selectedTab.value == 0
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Scheduled",
                                          style: TextStyle(
                                            color: controller.selectedTab.value == 0
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => controller.selectedTab.value = 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: controller.selectedTab.value == 1
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "History",
                                          style: TextStyle(
                                            color: controller.selectedTab.value == 1
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // Tab Content
                        Expanded(
                          child: Obx(() {
                            if (controller.selectedTab.value == 0) {
                              // Scheduled posts list
                              return ListView.builder(
                                itemCount: controller.scheduledPosts.length,
                                itemBuilder: (context, index) {
                                  final post = controller.scheduledPosts[index];
                                  return SchedulePostWidget(post: post);
                                },
                              );
                            } else {
                              // History posts list
                              return ListView.builder(
                                itemCount: controller.historyPosts.length,
                                itemBuilder: (context, index) {
                                  final post = controller.historyPosts[index];
                                  return HistoryWidget(post: post);
                                },
                              );
                            }
                          }),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Round Icon Widget
  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }

}