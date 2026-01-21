import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../widgets/PostListPage.dart';
import '../widgets/allReelsInPostPage.dart';
import '../widgets/reelContainer.dart';
import '../widgets/storyListPage.dart';
import 'CustomDrawer.dart';

class PostCreationPage extends StatefulWidget {
  const PostCreationPage({Key? key}) : super(key: key);

  @override
  State<PostCreationPage> createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  String? imageUrl;
  String? pageTitle = "Let’s Create your Next Post";
  String? pageSubTitle =
      "Explore the perfect content ideas tailored for your business";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;
  int selectedIndex = 0; // Track selected tab
  final List<String> tabs = ["Reels", "Posts", "Stories"]; // tabs

  TextEditingController searchController = TextEditingController();

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

  final List<Map<String, dynamic>> reelsData = [
    {
      "imagePath": "assets/images/1.jpg",
      "time": "5 s",
      "title": "A good video always gives good lesson and morals",
      "isFavorite": false,
    },
    {
      "imagePath": "assets/images/2.jpg",
      "time": "10 s",
      "title": "Flutter development is fun and easy to learn",
      "isFavorite": false,
    },
    {
      "imagePath": "assets/images/3.jpg",
      "time": "8 s",
      "title": "Always stay positive and keep learning",
      "isFavorite": false,
    },
    {
      "imagePath": "assets/images/7.jpg",
      "time": "12 s",
      "title": "Build amazing apps with Flutter",
      "isFavorite": false,
    },
    {
      "imagePath": "assets/images/5.jpg",
      "time": "6 s",
      "title": "Design beautiful UI/UX with Flutter",
      "isFavorite": false,
    },
    {
      "imagePath": "assets/images/6.jpg",
      "time": "15 s",
      "title": "Learning Dart is essential for Flutter",
      "isFavorite": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawerPage (),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState!.openDrawer(),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black12,
                          ),
                          child:
                          const Icon(Icons.menu_outlined, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: imageUrl == null || imageUrl!.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                            : ClipOval(
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
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
                        horizontal: 15, vertical: 8),
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
            
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    height: 50,
                    // padding: const EdgeInsets.only(left:  15,right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white, // border color
                        width: 1, // border width
                      ),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search for anything",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
                      ),
                    ),
                  ),
                ),

                // Tab bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(tabs.length, (index) {
                      bool isSelected = index == selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: isSelected ? const Color(0xFFFF277F) : Colors.white.withOpacity(0.0),
                            border: Border.all(
                              color: const Color(0xFFFF277F).withOpacity(0.0),
                            ),
                          ),
                          child: Text(
                            tabs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF6D6D73),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Content depending on selected tab
                Builder(
                  builder: (_) {
                    if (selectedIndex == 0) {
                      // Reels Container
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ReelsListPage(reelsData: reelsData)

                        // ReelsContainerPage(
                        //   imagePath: 'assets/images/5.jpg',
                        //   time: "5 s",
                        //   title: "A good video always give good lesson and  good morals",
                        //   // isFavorite: reel["isFavorite"],
                        //   onCreate: () {
                        //     debugPrint("Create clicked for:");
                        //   },
                        //   onFavoriteToggle: () {
                        //     setState(() {
                        //       debugPrint("=============Create clicked for:");
                        //     });
                        //   },
                        //   width: MediaQuery.of(context).size.width/2-15,
                        // ),
                      );
                    } else if (selectedIndex == 1) {
                      // Posts Container
                      return PostListPage();
                    } else if (selectedIndex == 2) {
                      // Videos Container
                      return StoryListPage();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),

                SizedBox(height: 30,)



              ],
            ),
          ),
        ),
      ),
    );
  }
}
