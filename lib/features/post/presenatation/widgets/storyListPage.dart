import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/features/post/presenatation/widgets/postContent.dart';
import 'package:flutter/material.dart';

import '../Screen_2/post_highlight.dart';

class StoryListPage extends StatelessWidget {
  final List<ContentTemplateModel> templates;

  const StoryListPage({super.key, required this.templates});

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const Center(child: Text("No story templates found"));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double spacing = 2;
    double itemHeight = 280;
    double padding = 25;

    // Each item takes 1/3 of screen width minus spacing
    double itemWidth = (screenWidth - spacing * 4) / 2.2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: templates.map((template) {
          return SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: GestureDetector(
              onTap: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostHighlight(
                      url: template.thumbnail ?? "", 
                      contentType: 'Story' 
                    )
                  ),
                );

              },
              child: PostContent(
                width: itemWidth,
                image: template.thumbnail ?? "assets/images/1.jpg",
                profileImage: 'assets/images/profile_image.png',
                name: template.title ?? "Untitled",
                likeCount: 0,
                repostCount: 0,
                padding: padding,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
