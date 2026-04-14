import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WeeklyContentSheet extends StatefulWidget {
  const WeeklyContentSheet({super.key});

  @override
  State<WeeklyContentSheet> createState() => _WeeklyContentSheetState();
}

class _WeeklyContentSheetState extends State<WeeklyContentSheet> {
  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Create 1 Reel',
      'description':
          'Make a short engaging video about your product/service. Keep it under 30 seconds.',
      'completed': false,
    },
    {
      'title': 'Create 1 Post',
      'description':
          'Share a valuable or promotional post with image and caption.',
      'completed': false,
    },
    {
      'title': 'Create 3 Stories',
      'description': 'Post behind-the-scenes, offers, or daily updates.',
      'completed': false,
    },
  ];

  Widget _buildProgressBar() {
    final completedCount = _items.where((item) => item['completed']).length;
    final progress = completedCount / _items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5C51FF),
              ),
            ),
            Text(
              '$completedCount/${_items.length} completed',
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
            value: progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C51FF)),
            minHeight: 10.h,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
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
                'Your Weekly Content Plan',
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
          _buildProgressBar(),
          SizedBox(height: 25.h),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (context, index) => SizedBox(height: 15.h),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            item['completed'] = !item['completed'];
                          });
                        },
                        child: Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: item['completed']
                                ? const Color(0xFF5C51FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: item['completed']
                                  ? const Color(0xFF5C51FF)
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: item['completed']
                              ? Icon(Icons.check,
                                  size: 16.r, color: Colors.white)
                              : null,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              item['description'],
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[500],
                                height: 1.4,
                              ),
                            ),
                          ],
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
                Get.back();
                Get.snackbar(
                  'Success',
                  'Great job! Your weekly progress has been saved.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF5C51FF),
                  colorText: Colors.white,
                  margin: EdgeInsets.all(15.r),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C51FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Mark Week as Completed',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
