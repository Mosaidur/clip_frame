import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:clip_frame/features/home/presentation/controller/homeController.dart';
import 'package:clip_frame/features/subscription/presentation/controller/weekly_checklist_controller.dart';

class WeeklyContentSheet extends StatefulWidget {
  const WeeklyContentSheet({super.key});

  @override
  State<WeeklyContentSheet> createState() => _WeeklyContentSheetState();
}

class _WeeklyContentSheetState extends State<WeeklyContentSheet> {
  late final WeeklyChecklistController _controller;

  @override
  void initState() {
    super.initState();
    // Use Get.put if not already registered, otherwise Get.find
    _controller = Get.isRegistered<WeeklyChecklistController>() 
        ? Get.find<WeeklyChecklistController>() 
        : Get.put(WeeklyChecklistController());
  }

  Widget _buildTopProgress() {
    return Obx(() {
      final model = _controller.checklistModel.value;
      if (model == null) return const SizedBox.shrink();

      final completedCount = _controller.completedTotal;
      final totalCount = _controller.targetTotal;
      final overallProgress = _controller.cumulativeProgress;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5C51FF),
                ),
              ),
              Text(
                '$completedCount/$totalCount completed',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C51FF)),
              minHeight: 10.h,
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6).withOpacity(0.98), // Premium off-white
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Obx(() {
        if (_controller.isLoading.value) {
          return SizedBox(
            height: 400.h,
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF5C51FF))),
          );
        }

        final model = _controller.checklistModel.value;
        if (model == null) {
          return SizedBox(
            height: 400.h,
            child: const Center(child: Text("No checklist found.")),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Content Plan',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20.r, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),
            _buildTopProgress(),
            SizedBox(height: 25.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: model.checklist.length,
                separatorBuilder: (context, index) => SizedBox(height: 15.h),
                itemBuilder: (context, index) {
                  final item = model.checklist[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${item.completed}/${item.target}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: item.isDone ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Individual Task Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            backgroundColor: const Color(0xFFF3F4F6),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              item.isDone ? Colors.green : const Color(0xFF5C51FF),
                            ),
                            minHeight: 6.h,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.allTasksCompleted) {
                    Get.back();
                    Get.snackbar(
                      'Week Completed!',
                      'Fantastic work on finishing your weekly plan.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.back(); // Close sheet
                    Get.find<HomeController>().navigateToPosts(); // Go to Post Feature
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C51FF), // Make it always vibrant
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _controller.allTasksCompleted ? 'Mark Week as Completed' : 'START CREATING NOW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        );
      }),
    );
  }
}
