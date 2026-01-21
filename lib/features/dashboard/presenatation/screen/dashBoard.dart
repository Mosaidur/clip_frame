import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/schedule_list.dart';

class DashBoardPage extends StatelessWidget {
  final TextEditingController customTypeController = TextEditingController();
  final String date = 'March 25, 2024';
  final String day = 'Today';
  final String? imageUrl = null;
  final List<int?> postCounts = [1, 2, 5, 0, 3, 4, 2]; // one value per day
  final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
  final List<int?> dates = [1, 2, 3, 4, 5, 6, 7]; // replace with actual dates
  final int currentIndex = DateTime.now().weekday % 7; // 0 for Sunday
  final int total = 11;
  final List<Map<String, dynamic>> posts = [
    {
      "image": "assets/images/1.jpg",
      "profileImage": "assets/images/profile_image.png",
      "name": "Alice",
      "repostCount": 5,
      "likeCount": 120
    },
    {
      "image": "assets/images/2.jpg",
      "profileImage": "assets/images/profile_image.png",
      "name": "Bob",
      "repostCount": 2,
      "likeCount": 800
    },
    {
      "image": "assets/images/3.jpg",
      "profileImage": "assets/images/profile_image.png",
      "name": "Charlie",
      "repostCount": 700,
      "likeCount": 20
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.h),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 50.r,
                            height: 50.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: imageUrl == null || imageUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 35.r,
                                    color: Colors.white,
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      imageUrl!,
                                      fit: BoxFit.cover,
                                      width: 50.r,
                                      height: 50.r,
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        bool isToday = index == currentIndex;
                        int? postCount = postCounts[index];

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Column(
                              children: [
                                Text(
                                  weekdays[index],
                                  style: TextStyle(
                                    color: isToday ? Colors.black : Colors.grey,
                                    fontSize: 11.sp,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  dates[index].toString(),
                                  style: TextStyle(
                                    color: isToday ? Colors.black : Colors.grey,
                                    fontSize: 14.sp,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                // Dots
                                SizedBox(
                                  height: 12.h,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      (postCount ?? 0) > 3 ? 3 : (postCount ?? 0),
                                      (dotIndex) {
                                        Color circleColor;
                                        if ((postCount ?? 0) > 3 && dotIndex == 2) {
                                          circleColor = Colors.black;
                                        } else {
                                          switch (dotIndex) {
                                            case 0:
                                              circleColor = Colors.blue;
                                              break;
                                            case 1:
                                              circleColor = Colors.grey;
                                              break;
                                            case 2:
                                              circleColor = Colors.pink;
                                              break;
                                            default:
                                              circleColor = Colors.grey;
                                          }
                                        }
                                        return Container(
                                          margin: EdgeInsets.only(right: 2.w),
                                          width: 6.r,
                                          height: 6.r,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: circleColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              // Dashboard Summary
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Post \nPublished",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                            Text(
                              total.toString(),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              total.toString(),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Reels \nPublished",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Story \nCreated",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                            Text(
                              total.toString(),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              total.toString(),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Weekly \nViews",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Average Engagement",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Text(
                        "$total%",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content Create and Calender
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007CFE),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_box_rounded, color: Colors.white, size: 14.r),
                            SizedBox(width: 5.w),
                            Text(
                              "Create Weekly Content",
                              style: TextStyle(color: Colors.white, fontSize: 11.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchedulePage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF277F),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month, color: Colors.white, size: 14.r),
                              SizedBox(width: 5.w),
                              Text(
                                "Calendar",
                                style: TextStyle(color: Colors.white, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Most Recent Post
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Most Recent',
                      style: TextStyle(
                        color: const Color(0xFF6D6D73),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint("=========== Most recent Post");
                      },
                      child: Row(
                        children: [
                          Text(
                            "See All",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.blue,
                            size: 11.r,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: SizedBox(
                  height: 180.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        width: 0.38.sw,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          image: DecorationImage(
                            image: AssetImage(post['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Top-left profile + name
                            Positioned(
                              top: 8.h,
                              left: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 22.r,
                                      height: 22.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage(post['profileImage']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Flexible(
                                      child: Text(
                                        post['name'],
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Bottom row with repost and likes
                            Positioned(
                              bottom: 8.h,
                              left: 8.w,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.repeat, color: Colors.white, size: 12.r),
                                        SizedBox(width: 4.w),
                                        Text(
                                          post['repostCount'].toString(),
                                          style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '|',
                                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.favorite, color: Colors.white, size: 12.r),
                                        SizedBox(width: 4.w),
                                        Text(
                                          post['likeCount'].toString(),
                                          style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 15.h),
              //edit photo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    "assets/images/edit_photo.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              //For You Post
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'For you',
                      style: TextStyle(
                        color: const Color(0xFF6D6D73),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint("=========== For you");
                      },
                      child: Row(
                        children: [
                          Text(
                            "See All",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.blue,
                            size: 11.r,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: SizedBox(
                  height: 180.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        width: 0.38.sw,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          image: DecorationImage(
                            image: AssetImage(post['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8.h,
                              left: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 22.r,
                                      height: 22.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage(post['profileImage']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Flexible(
                                      child: Text(
                                        post['name'],
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8.h,
                              left: 8.w,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.repeat, color: Colors.white, size: 12.r),
                                        SizedBox(width: 4.w),
                                        Text(
                                          post['repostCount'].toString(),
                                          style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '|',
                                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.favorite, color: Colors.white, size: 12.r),
                                        SizedBox(width: 4.w),
                                        Text(
                                          post['likeCount'].toString(),
                                          style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots(int count) {
    int displayCount = count > 3 ? 3 : count;
    return SizedBox(
      height: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(displayCount, (i) {
          Color dotColor = Colors.grey;
          if (count > 3 && i == 2) {
            dotColor = Colors.black;
          } else {
            dotColor = [Colors.blue, Colors.grey, Colors.pink][i % 3];
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          );
        }),
      ),
    );
  }
}



class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(post['image']),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: _buildProfileTag(),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: _buildStatsTag(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundImage: AssetImage(post['profileImage']),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              post['name'],
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(icon: Icons.repeat, count: post['repostCount'].toString()),
          const Text("|", style: TextStyle(color: Colors.white24, fontSize: 10)),
          _StatItem(icon: Icons.favorite, count: post['likeCount'].toString()),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _StatItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 2),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}