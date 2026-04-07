import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:clip_frame/features/post/presenatation/widget2/beautifulEmptyState.dart';
import 'package:clip_frame/features/post/presenatation/widget2/customTabBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';
import 'package:shimmer/shimmer.dart';



import 'storyFullScreenView.dart';

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double spacing = 8;
    double itemHeight = 280;
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
              ? _buildGridShimmer(itemWidth, itemHeight, spacing)
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
                            CustomBackButton(
                              onPressed: () => Get.back(),
                              backgroundColor: Colors.black26,
                              iconColor: Colors.white,
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

                      // Custom Tab Bar
                      const CustomTabBar(),

                      const SizedBox(height: 20),

                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          mainAxisExtent: itemHeight,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: templates.length,
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          String imageUrl = template.thumbnail ?? "";
                          if (imageUrl.isEmpty || imageUrl.toLowerCase().endsWith('.mp4') || imageUrl.toLowerCase().endsWith('.mov')) {
                            if (template.steps != null && template.steps!.isNotEmpty) {
                              final stepUrl = template.steps![0].url ?? "";
                              if (!stepUrl.toLowerCase().endsWith('.mp4') && !stepUrl.toLowerCase().endsWith('.mov')) {
                                imageUrl = stepUrl;
                              }
                            }
                          }

                          return GestureDetector(
                            key: template.id != null ? _itemKeys[template.id] : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoryFullScreenView(
                                    templates: templates,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xFF1A1A2E),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Background image
                                  if (imageUrl.isNotEmpty &&
                                      imageUrl.startsWith('http'))
                                    Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: const Color(0xFF1A1A2E),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFFF4D8D),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, error, __) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF1A1A2E),
                                                Color(0xFF16213E)
                                              ],
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.image_outlined,
                                                color: Colors.white24, size: 48),
                                          ),
                                        );
                                      },
                                    )
                                  else if (imageUrl.isNotEmpty)
                                    Image.asset(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFF1A1A2E),
                                        child: const Center(
                                          child: Icon(Icons.image_outlined,
                                              color: Colors.white24, size: 48),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1A1A2E),
                                            Color(0xFF16213E)
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.image_outlined,
                                            color: Colors.white24, size: 48),
                                      ),
                                    ),

                                  // Gradient overlay at bottom
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 80,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Title at bottom
                                  Positioned(
                                    bottom: 12,
                                    left: 10,
                                    right: 10,
                                    child: Text(
                                      template.title ?? "Untitled",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGridShimmer(
    double itemWidth,
    double itemHeight,
    double spacing,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 20),

          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.5),
            highlightColor: Colors.white.withOpacity(0.2),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(
                6,
                (index) => Container(
                  width: itemWidth,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
