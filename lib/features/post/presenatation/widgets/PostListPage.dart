import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/features/post/presenatation/widgets/postContent.dart';
import 'package:flutter/material.dart';

import '../Screen_2/post_highlight.dart';
import '../screen/postScrollPage.dart';

class PostListPage extends StatelessWidget {
  final List<ContentTemplateModel> templates;

  const PostListPage({super.key, required this.templates});

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const Center(child: Text("No post templates found"));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double spacing = 8;
    double itemHeight = 180;

    // Accounts for the 10px padding on each side of SingleChildScrollView
    double itemWidth = (screenWidth - 20 - spacing * 2) / 3.2;

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
                      contentType: 'Post',
                      template: template,
                    )
                  ),
                );
              },
              child: PostContent(
                width: itemWidth,
                image: template.thumbnail ?? "assets/images/1.jpg",
                profileImage: 'assets/images/profile_image.png', // Fallback
                name: template.title ?? "Untitled",
                likeCount: 0, // Placeholder
                repostCount: 0, // Placeholder
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
