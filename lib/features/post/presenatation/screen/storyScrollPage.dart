import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:clip_frame/features/post/presenatation/widget2/beautifulEmptyState.dart';
import 'package:clip_frame/features/post/presenatation/widget2/customTabBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screen_2/post_highlight.dart';
import '../widgets/postContent.dart';

class StoryScrollPage extends StatefulWidget {
  final String? initialId;
  const StoryScrollPage({super.key, this.initialId});

  @override
  State<StoryScrollPage> createState() => _StoryScrollPageState();
}

class _StoryScrollPageState extends State<StoryScrollPage> {
  List<ContentTemplateModel> templates = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => isLoading = true);
    final results = await ContentTemplateService.fetchTemplatesByType('story');
    setState(() {
      templates = results;
      _itemKeys.clear();
      for (var t in templates) {
        if (t.id != null) {
          _itemKeys[t.id!] = GlobalKey();
        }
      }
      isLoading = false;
    });

    if (widget.initialId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _itemKeys[widget.initialId];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

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
      drawer: const Drawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC894), Color(0xFFFFFFFF), Color(0xFFB49EF4)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF277F)),
                )
              : templates.isEmpty
              ? BeautifulEmptyState(
                  title: "No Stories Found",
                  subtitle:
                      "We couldn't find any story templates. Check back later for fresh content!",
                  onRetry: _loadTemplates,
                  icon: Icons.auto_awesome_motion_outlined,
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 20, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black26,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            // Refresh Button
                            IconButton(
                              onPressed: _loadTemplates,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
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
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Custom Tab Bar
                      const CustomTabBar(),

                      const SizedBox(height: 20),

                      // Posts Grid using Wrap
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: templates.map((template) {
                            final imageUrl =
                                (template.steps != null &&
                                    template.steps!.isNotEmpty)
                                ? template.steps![0].url ?? ""
                                : (template.thumbnail ?? "");

                            return GestureDetector(
                              key: template.id != null
                                  ? _itemKeys[template.id]
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostHighlight(
                                      url: imageUrl,
                                      contentType: 'Story',
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: PostContent(
                                  width: itemWidth,
                                  image: imageUrl,
                                  profileImage:
                                      'assets/images/profile_image.png', // Fallback local asset for now
                                  name: template.createdBy?.name ?? "Unknown",
                                  likeCount: template.stats?.loveCount ?? 0,
                                  repostCount: template.stats?.reuseCount ?? 0,
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
