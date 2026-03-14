import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:clip_frame/features/post/presenatation/widget2/beautifulEmptyState.dart';
import '../widget2/postScrollContent.dart';

class PostScrollPage extends StatefulWidget {
  final String? initialId;
  const PostScrollPage({super.key, this.initialId});

  @override
  State<PostScrollPage> createState() => _PostScrollPageState();
}

class _PostScrollPageState extends State<PostScrollPage> {
  List<ContentTemplateModel> templates = [];
  bool isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTemplates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => isLoading = true);
    final results = await ContentTemplateService.fetchTemplatesByType('post');
    setState(() {
      templates = results;
      isLoading = false;
    });

    if (widget.initialId != null) {
      final index = templates.indexWhere((t) => t.id == widget.initialId);
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Stack(
            children: [
              Container(color: Colors.black),
              Positioned(
                bottom: 100,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 20, color: Colors.white),
                    const SizedBox(height: 10),
                    Container(width: 100, height: 15, color: Colors.white),
                  ],
                ),
              ),
              Positioned(
                bottom: 100,
                right: 20,
                child: Column(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (templates.isEmpty) {
      return Scaffold(
        body: BeautifulEmptyState(
          title: "No Posts Found",
          subtitle:
              "It seems like there are no post templates available right now. Stay tuned for updates!",
          onRetry: _loadTemplates,
          icon: Icons.post_add_outlined,
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final imageUrl =
                  (template.steps != null &&
                      template.steps!.isNotEmpty &&
                      template.steps![0].url != null &&
                      template.steps![0].url!.isNotEmpty)
                  ? template.steps![0].url!
                  : (template.thumbnail ?? "");

              return PostScrollContnet(
                template: template,
                imageUrl: imageUrl,
                category: template.category ?? "General",
                format: "JPEG",
                title: template.title ?? "Untitled Post",
                tags: template.hashtags ?? [],
                musicTitle: "Original Audio",
                profileImageUrl:
                    template.thumbnail ?? template.createdBy?.email,
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
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
