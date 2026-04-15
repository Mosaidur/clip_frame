import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/features/post/presenatation/Screen_2/Content_Steps.dart';

class StoryFullScreenView extends StatefulWidget {
  final List<ContentTemplateModel> templates;
  final int initialIndex;

  const StoryFullScreenView({
    super.key,
    required this.templates,
    required this.initialIndex,
  });

  @override
  State<StoryFullScreenView> createState() => _StoryFullScreenViewState();
}

class _StoryFullScreenViewState extends State<StoryFullScreenView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen vertical PageView (like Reels)
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.templates.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final template = widget.templates[index];
              String imageUrl = template.thumbnail ?? "";
              if (imageUrl.isEmpty || imageUrl.toLowerCase().endsWith('.mp4') || imageUrl.toLowerCase().endsWith('.mov')) {
                if (template.steps != null && template.steps!.isNotEmpty) {
                  final stepUrl = template.steps![0].url ?? "";
                  if (!stepUrl.toLowerCase().endsWith('.mp4') && !stepUrl.toLowerCase().endsWith('.mov')) {
                    imageUrl = stepUrl;
                  }
                }
              }

              return _StoryCard(
                template: template,
                imageUrl: imageUrl,
              );
            },
          ),

          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),


        ],
      ),
    );
  }
}

class _StoryCard extends StatefulWidget {
  final ContentTemplateModel template;
  final String imageUrl;

  const _StoryCard({required this.template, required this.imageUrl});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background image full-screen
          Positioned.fill(
            child: widget.imageUrl.isNotEmpty
                ? Stack(
                    children: [
                      // Blurred Background
                      Positioned.fill(
                        child: widget.imageUrl.startsWith('http')
                            ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                            : Image.asset(widget.imageUrl, fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(color: Colors.black.withOpacity(0.4)),
                        ),
                      ),
                      // Main Content
                      Center(
                        child: widget.imageUrl.startsWith('http')
                            ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(color: Color(0xFFFF4D8D)),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: Colors.white38, size: 64),
                                ),
                              )
                            : Image.asset(
                                widget.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: Colors.white38, size: 64),
                                ),
                              ),
                      ),
                    ],
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.white38, size: 64),
                    ),
                  ),
          ),

          // Dark gradient overlay at bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.45, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Bottom left: "Start Creating" CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StepByStepPage(
                        contentType: 'Story',
                        template: widget.template.toJson(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4D8D), Color(0xFFFF8A65)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4D8D).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Start Creating',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Swipe hint at top (only for first card)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up,
                      color: Colors.white.withOpacity(0.5), size: 20),
                  Text(
                    'Swipe up for next',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
