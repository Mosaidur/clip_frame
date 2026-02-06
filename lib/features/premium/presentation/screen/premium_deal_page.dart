import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../screen/premium_selection_page.dart';

class PremiumDealPage extends StatelessWidget {
  const PremiumDealPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        "Offer expires in:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      _buildCountdown(),
                      SizedBox(height: 40.h),
                      _buildGiftBox(),
                      SizedBox(height: 30.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          "Spring into Savings! Get 50% off Premium - Limited Time Only!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Reg. Yearly: €1199.99",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14.sp,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "Now: €600.99",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.off(() => const PremiumSelectionPage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Get Deal",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
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
            icon: Icon(Icons.close, color: Colors.white, size: 30.r),
          ),
          Row(
            children: [
              Image.asset(
                'assets/images/ClipFramelogo.png',
                height: 40.r,
                width: 40.r,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.play_circle_fill,
                  color: Colors.blue,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "ClipFrame",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(width: 40.w), // Balance
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBox("9", "days"),
        _buildDivider(),
        _buildTimeBox("18", "hours"),
        _buildDivider(),
        _buildTimeBox("22", "min"),
      ],
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      width: 75.w,
      height: 85.h,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.padLeft(2, '0'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        ":",
        style: TextStyle(
          color: Colors.white,
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGiftBox() {
    return SizedBox(
      width: 150.r,
      height: 150.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lid
          Positioned(
            top: 40.r,
            child: Container(
              width: 120.r,
              height: 35.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD59E), // Light beige/lid color
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
          ),
          // Base
          Positioned(
            top: 75.r,
            child: Container(
              width: 105.r,
              height: 75.r,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF), // Blue base
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(5.r),
                ),
              ),
              child: Stack(
                children: [
                  // Little white/pink stars
                  for (int i = 0; i < 5; i++)
                    Positioned(
                      left: (15 + (i * 18)).r,
                      top: (10 + (i % 2 * 20)).r,
                      child: Icon(
                        Icons.star,
                        size: 10.r,
                        color: i.isEven ? Colors.white70 : Colors.pinkAccent,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Ribbon vertical
          Positioned(
            top: 40.r,
            child: Container(
              width: 18.r,
              height: 110.r,
              color: const Color(0xFFFF2D55), // Pink ribbon
            ),
          ),
          // Bow
          Positioned(
            top: 0.r,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(angle: -0.4, child: _buildBowPart()),
                SizedBox(width: 2.r),
                Transform.rotate(angle: 0.4, child: _buildBowPart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowPart() {
    return Container(
      width: 50.r,
      height: 45.r,
      decoration: BoxDecoration(
        color: const Color(0xFFFF2D55), // Pink bow
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}
