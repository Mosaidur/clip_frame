import 'package:clip_frame/features/post/presenatation/widget2/customTabBar.dart';
import 'package:flutter/material.dart';

import '../Screen_2/post_highlight.dart';
import '../widgets/postContent.dart';

// Dummy profile image URL (replace with your logic)
// String? profileImageUrl;

class StoryScrollPage extends StatelessWidget {
  StoryScrollPage({super.key});

  final List<Map<String, dynamic>> posts = const [
    {
      'image': 'assets/images/1.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Alice Wonderland',
      'likeCount': 1200,
      'repostCount': 345,
    },
    {
      'image': 'assets/images/2.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Bob Builder',
      'likeCount': 987,
      'repostCount': 55,
    },
    {
      'image': 'assets/images/3.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Charlie Chaplin',
      'likeCount': 5400,
      'repostCount': 230,
    },
    {
      'image': 'assets/images/5.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Diana Prince',
      'likeCount': 120,
      'repostCount': 12,
    },
    {
      'image': 'assets/images/6.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Eve Online',
      'likeCount': 1500,
      'repostCount': 70,
    },
    {
      'image': 'assets/images/7.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Frank Ocean',
      'likeCount': 2200,
      'repostCount': 150,
    },
    {
      'image': 'assets/images/8.jpg',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Grace Hopper',
      'likeCount': 3100,
      'repostCount': 400,
    },
    {
      'image': 'assets/images/9.png',
      'profileImage': 'assets/images/profile_image.png',
      'name': 'Hank Pym',
      'likeCount': 890,
      'repostCount': 60,
    },
  ];

  String? profileImageUrl = "assets/images/profile_image.png";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double spacing = 8;
    double itemHeight = 280;
    double padding = 12;
    double itemWidth = (screenWidth - spacing * 3) / 2.2;

    return Scaffold(
      drawer: Drawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ Color(0xFFEBC894), Color(0xFFFFFFFF), Color(0xFFB49EF4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20,left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu Icon
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                        child: const Icon(Icons.menu_outlined, color: Colors.white),
                      ),
                    ),
      
                    // Profile Image
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : ClipOval(
                        child: Image.asset(
                          profileImageUrl!,
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      
              const SizedBox(height: 10),
      
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for anything',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
      
              const SizedBox(height: 20),
      
              // Custom Tab Bar (replace with your CustomTabBar widget)
             CustomTabBar(),
      
              const SizedBox(height: 20),
      
              // Posts Grid using Wrap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: posts.map((post) {
                    return GestureDetector(
                      onTap: () {
                        print('Tapped on ${post['name']}');

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostHighlight(url: post['image'], contentType: 'Story' ,)),
                        );

                      },
                      child: SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: PostContent(
                          width: itemWidth,
                          image: post['image'],
                          profileImage: post['profileImage'],
                          name: post['name'],
                          likeCount: post['likeCount'],
                          repostCount: post['repostCount'],
                          padding: padding,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
   );
  }
}
