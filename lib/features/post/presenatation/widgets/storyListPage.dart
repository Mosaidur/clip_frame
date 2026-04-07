import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:flutter/material.dart';

import '../screen/storyFullScreenView.dart';

class StoryListPage extends StatelessWidget {
  final List<ContentTemplateModel> templates;

  const StoryListPage({super.key, required this.templates});

  String _getImageUrl(ContentTemplateModel template) {
    String imageUrl = template.thumbnail ?? "";
    if (imageUrl.isEmpty || imageUrl.toLowerCase().endsWith('.mp4') || imageUrl.toLowerCase().endsWith('.mov')) {
      if (template.steps != null && template.steps!.isNotEmpty) {
        final stepUrl = template.steps![0].url ?? "";
        if (!stepUrl.toLowerCase().endsWith('.mp4') && !stepUrl.toLowerCase().endsWith('.mov')) {
          imageUrl = stepUrl;
        }
      }
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const Center(child: Text("No story templates found"));
    }

    double spacing = 10;
    double padding = 16;
    double itemHeight = 280;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: padding),
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
        final imageUrl = _getImageUrl(template);

        return GestureDetector(
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
                if (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
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
                      debugPrint("❌ Image load error: $error for URL: $imageUrl");
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
    );
  }
}
