import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model.dart';
import '../controller/schedule_controller.dart';
import '../widgets/SchedulePost.dart';
import '../widgets/history.dart';


class ScheduleScreenPage extends StatelessWidget {

  const ScheduleScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? imageUrl ;
    // Inject the new controller
    final ScheduleController controller = Get.put(ScheduleController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: SafeArea(
          bottom: false, 
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
                  decoration: const BoxDecoration(
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

                        const SizedBox(height: 10,),
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
                            if (controller.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            if (controller.errorMessage.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(controller.errorMessage.value, textAlign: TextAlign.center),
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.fetchSchedules("scheduled");
                                        controller.fetchSchedules("published");
                                      },
                                      child: const Text("Retry"),
                                    )
                                  ],
                                ),
                              );
                            }

                            if (controller.selectedTab.value == 0) {
                              if (controller.scheduledPosts.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F4F4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 50,
                                          color: Color(0xFFC4C4C4),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No Scheduled Posts",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "You don't have any posts scheduled yet.\nTap the + button to create one!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: controller.scheduledPosts.length,
                                itemBuilder: (context, index) {
                                  final post = controller.scheduledPosts[index];
                                  return SchedulePostWidget(post: post);
                                },
                              );
                            } else {
                              // History posts list
                              if (controller.historyPosts.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F4F4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.history_rounded,
                                          size: 50,
                                          color: Color(0xFFC4C4C4),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No History Available",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Your past published posts will appear here.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
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