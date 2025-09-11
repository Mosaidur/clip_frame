import 'package:clip_frame/features/post/presenatation/widgets/postContent.dart';
import 'package:flutter/material.dart';

class PostListPage extends StatelessWidget {
  const PostListPage({super.key});

  // Demo posts
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double spacing = 2;
    double itemHeight = 180;

    // Each item takes 1/3 of screen width minus spacing
    double itemWidth = (screenWidth - spacing * 4) / 3.2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: posts.map((post) {
          return SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: Expanded(
              child: PostContent(
                width: itemWidth,
                image: post['image'],
                profileImage: post['profileImage'],
                name: post['name'],
                likeCount: post['likeCount'],
                repostCount: post['repostCount'],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
