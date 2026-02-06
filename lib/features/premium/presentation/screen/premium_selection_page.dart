import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/premium_selection_controller.dart';

class PremiumSelectionPage extends StatelessWidget {
  const PremiumSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PremiumSelectionController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/plane_backgroud.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () => controller.fetchPlans(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        _buildFeaturesCard(),
                        SizedBox(height: 20.h),
                        ...controller.plans.map((plan) {
                          final bool isRecommended = plan.title
                              .toLowerCase()
                              .contains('starter');
                          final String period =
                              plan.paymentType.toLowerCase().contains('month')
                              ? '/month'
                              : '/week';
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildPlanOption(
                              title: plan.title,
                              price:
                                  "€${plan.price} / ${plan.paymentType.toLowerCase().replaceAll('ly', '')}",
                              reels: plan.limits.reelsPerWeek.toString(),
                              posts: plan.limits.postsPerWeek.toString(),
                              stories: plan.limits.storiesPerWeek.toString(),
                              period: period,
                              isRecommended: isRecommended,
                              gradient: isRecommended
                                  ? [
                                      const Color(0xFF8E2DE2),
                                      const Color(0xFF4A00E0),
                                    ]
                                  : null,
                              businessManageable: plan
                                  .limits
                                  .businessesManageable
                                  .toString(),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  );
                }),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: Colors.white, size: 24.r),
          ),
          Row(
            children: [
              Icon(Icons.play_circle_fill, color: Colors.blue, size: 28.r),
              SizedBox(width: 8.w),
              Text(
                "ClipFrame",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(width: 40.w), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildFeatureItem(Icons.bolt, "Lorem Ipsum is simply dummy text."),
          _buildFeatureItem(
            Icons.sentiment_satisfied,
            "Lorem Ipsum is simply dummy text.",
          ),
          _buildFeatureItem(Icons.timer, "Faster image processing"),
          _buildFeatureItem(Icons.visibility_off, "No watermarks!"),
          _buildFeatureItem(Icons.ads_click, "Remove ads"),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20.r),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required String title,
    String? price,
    String? reels,
    String? posts,
    String? stories,
    String? period,
    String? businessManageable,
    String? tag,
    bool isRecommended = false,
    List<Color>? gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: gradient == null ? Colors.white.withOpacity(0.1) : null,
        gradient: gradient != null ? LinearGradient(colors: gradient) : null,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isRecommended
              ? Colors.pinkAccent
              : Colors.white.withOpacity(0.05),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isRecommended)
            Positioned(
              left: -17.w,
              top: 5.h,
              child: RotatedBox(
                quarterTurns: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "Recommended",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (price != null)
                        Text(
                          price,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  if (businessManageable != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          businessManageable,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Business Manageable",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (reels != null || tag != null) ...[
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (reels != null)
                      Row(
                        children: [
                          _buildCountItem(reels, "reel"),
                          _buildCountItem(posts!, "post"),
                          _buildCountItem(stories!, "story"),
                          Text(
                            period ?? "/month",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    if (tag != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem(String count, String label) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          SizedBox(
            width: 320.w,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                "Get Access Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink("Terms"),
              _buildVerticalDivider(),
              _buildFooterLink("Privacy"),
              _buildVerticalDivider(),
              _buildFooterLink("Restore"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.sp),
    );
  }

  Widget _buildVerticalDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        width: 1,
        height: 12,
        color: Colors.white.withOpacity(0.2),
      ),
    );
  }
}
