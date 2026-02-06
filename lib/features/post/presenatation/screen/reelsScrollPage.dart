import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:clip_frame/features/post/presenatation/widget2/beautifulEmptyState.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';
import '../widget2/reelsScrollContent.dart';

class Reelsscrollpage extends StatefulWidget {
  final String? initialId;
  const Reelsscrollpage({super.key, this.initialId});

  @override
  State<Reelsscrollpage> createState() => _ReelsscrollpageState();
}

class _ReelsscrollpageState extends State<Reelsscrollpage> {
  List<ContentTemplateModel> templates = [];
  bool isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Get.put(ContentCreationController());
    _loadTemplates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => isLoading = true);
    final results = await ContentTemplateService.fetchTemplatesByType('reel');
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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF277F)),
        ),
      );
    }

    if (templates.isEmpty) {
      return Scaffold(
        body: BeautifulEmptyState(
          title: "No Reels Found",
          subtitle:
              "We couldn't find any reel templates at the moment. Please check back later or try refreshing.",
          onRetry: _loadTemplates,
          icon: Icons.movie_filter_outlined,
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
              // Use the URL from the first step if available, otherwise use a placeholder
              final videoUrl =
                  (template.steps != null && template.steps!.isNotEmpty)
                  ? template.steps![0].url ?? ""
                  : "";

              return ReelsScrollContnet(
                templateId: template.id ?? "",
                videoUrl: videoUrl,
                category: template.category ?? "General",
                format: "MP4", // Default format
                title: template.title ?? "Untitled Reel",
                tags: template.hashtags ?? [],
                musicTitle: "Original Audio",
                profileImageUrl:
                    template.thumbnail ?? template.createdBy?.email, // Fallback
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
