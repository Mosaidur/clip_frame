import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widget2/postScrollContent.dart';

class PostScrollPage extends StatefulWidget {
  const PostScrollPage({super.key});

  @override
  State<PostScrollPage> createState() => _PostScrollPageState();
}

class _PostScrollPageState extends State<PostScrollPage> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    // Mock JSON for posts
    const jsonString = '''
    {
      "posts": [
        {
          "imageUrl": "https://picsum.photos/500/900?random=1",
          "category": "Education",
          "format": "JPEG",
          "title": "Learn Flutter in 60 seconds",
          "tags": ["flutter", "mobile", "dart"],
          "musicTitle": "Inspiring Beats",
          "profileImageUrl": "https://i.pravatar.cc/150?img=1"
        },
        {
          "imageUrl": "https://picsum.photos/500/900?random=2",
          "category": "Travel",
          "format": "PNG",
          "title": "Exploring the mountains",
          "tags": ["nature", "adventure", "travel"],
          "musicTitle": "Calm Nature Sound",
          "profileImageUrl": "https://i.pravatar.cc/150?img=2"
        },
        {
          "imageUrl": "https://picsum.photos/500/900?random=3",
          "category": "Entertainment",
          "format": "JPEG",
          "title": "Funny moments compilation",
          "tags": ["funny", "comedy", "viral"],
          "musicTitle": "Comedy Beats",
          "profileImageUrl": "https://i.pravatar.cc/150?img=3"
        },
        {
          "imageUrl": "https://picsum.photos/500/900?random=4",
          "category": "Sports",
          "format": "PNG",
          "title": "Top 10 football goals",
          "tags": ["football", "sports", "goals"],
          "musicTitle": "Stadium Energy",
          "profileImageUrl": "https://i.pravatar.cc/150?img=4"
        }
      ]
    }
    ''';

    final data = json.decode(jsonString);
    setState(() {
      posts = data["posts"];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostScrollContnet(
                imageUrl: post["imageUrl"],
                category: post["category"],
                format: post["format"],
                title: post["title"],
                tags: List<String>.from(post["tags"]),
                musicTitle: post["musicTitle"],
                profileImageUrl: post["profileImageUrl"],
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
