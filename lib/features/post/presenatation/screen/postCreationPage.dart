import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';
import 'package:flutter/material.dart';
import 'package:clip_frame/features/home/presentation/controller/homeController.dart';
import 'package:get/get.dart';
import '../widgets/PostListPage.dart';
import '../widgets/allReelsInPostPage.dart';
import '../widgets/reelContainer.dart';
import '../widgets/storyListPage.dart';
import 'CustomDrawer.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';

class PostCreationPage extends StatefulWidget {
  const PostCreationPage({Key? key}) : super(key: key);

  @override
  State<PostCreationPage> createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final HomeController homeController = Get.find<HomeController>();
  final ContentCreationController contentController = Get.put(
    ContentCreationController(),
  );
  String? imageUrl;
  String? pageTitle = "Let’s Create your Next Post";
  String? pageSubTitle =
      "Explore the perfect content ideas tailored for your business";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;
  int selectedIndex = 0; // Track selected tab
  final List<String> tabs = ["Reels", "Posts", "Stories"]; // tabs

  final List<String> images = [
    "assets/images/1.jpg",
    "assets/images/2.jpg",
    "assets/images/3.jpg",
    "assets/images/5.jpg",
    "assets/images/6.jpg",
    "assets/images/7.jpg",
    "assets/images/8.jpg",
    "assets/images/9.png",
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      drawer: CustomDrawerPage(),
      body: SafeArea(
        bottom: false,
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomBackButton(
                        onPressed: () => Get.back(),
                        backgroundColor: Colors.black12,
                      ),
                      Obx(() {
                        final profileController =
                            Get.find<MyProfileController>();
                        final user = profileController.userModel.value;
                        final String? avatarUrl = user?.image;

                        return GestureDetector(
                          onTap: () => homeController.changePage(3),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                color: const Color(0xFFFF277F),
                                width: 2,
                              ),
                            ),
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    pageTitle!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: Text(
                      pageSubTitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                //Carousel options

                // Carousel Slider Section
                const SizedBox(height: 20),
                CarouselSlider.builder(
                  itemCount: images.length,
                  options: CarouselOptions(
                    height: 250, // bigger height
                    viewportFraction: 0.4, // side cards peek
                    enableInfiniteScroll: true,
                    enlargeCenterPage: false, // we scale manually
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                        print("=========Current Index $currentIndex");
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final scale = index == currentIndex ? 1.0 : 0.85;
                    final zIndex = index == currentIndex ? 2.0 : 1.0;

                    return Transform.scale(
                      scale: scale,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: index < currentIndex ? -20 : 0,
                            right: index > currentIndex ? -20 : 0,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Dot Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final isActive = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFFF277F)
                            : const Color(0xFFFF277F).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),


                // Tab bar
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(tabs.length, (index) {
                        bool isSelected =
                            index == homeController.postTabIndex.value;
                        return GestureDetector(
                          onTap: () {
                            homeController.postTabIndex.value = index;
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: isSelected
                                  ? const Color(0xFFFF277F)
                                  : Colors.white.withOpacity(0.0),
                              border: Border.all(
                                color: const Color(0xFFFF277F).withOpacity(0.0),
                              ),
                            ),
                            child: Text(
                              tabs[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6D6D73),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Content depending on selected tab
                Obx(() {
                  if (homeController.postTabIndex.value == 0) {
                    // Reels Container
                    if (contentController.isLoading.value &&
                        contentController.reelTemplates.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ReelsListPage(
                        reelsData: contentController.reelTemplates,
                      ),
                    );
                  } else if (homeController.postTabIndex.value == 1) {
                    // Posts Container
                    if (contentController.isLoading.value &&
                        contentController.postTemplates.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return PostListPage(
                      templates: contentController.postTemplates,
                    );
                  } else if (homeController.postTabIndex.value == 2) {
                    // Videos Container (Stories)
                    if (contentController.isLoading.value &&
                        contentController.storyTemplates.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return StoryListPage(
                      templates: contentController.storyTemplates,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
