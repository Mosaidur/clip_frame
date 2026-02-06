import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clip_frame/features/Video%20Editing/ProfessionalCamera.dart';
import 'package:clip_frame/features/Video%20Editing/VideoEditing.dart';
import 'package:clip_frame/features/post/presenatation/widgets/reelContainer.dart';
import 'package:clip_frame/core/model/content_template_model.dart';
import '../Screen_2/video_Highlight.dart';

import '../screen/reelsScrollPage.dart';

class ReelsListPage extends StatefulWidget {
  final List<ContentTemplateModel> reelsData;

  const ReelsListPage({super.key, required this.reelsData});

  @override
  State<ReelsListPage> createState() => _ReelsListPageState();
}

class _ReelsListPageState extends State<ReelsListPage> {
  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width / 2 - 25;

    if (widget.reelsData.isEmpty) {
      return const Center(child: Text("No templates found"));
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 10, // horizontal spacing
          runSpacing: 10, // vertical spacing
          children: widget.reelsData.asMap().entries.map((entry) {
            int index = entry.key;
            ContentTemplateModel reel = entry.value;

            // Calculate duration
            int duration = 0;
            if (reel.steps != null) {
              for (var step in reel.steps!) {
                duration += step.duration ?? 0;
              }
            }

            return ReelsContainerPage(
              imagePath: reel.thumbnail ?? "assets/images/1.jpg", // Fallback
              time: "${duration}s",
              title: reel.title ?? "Untitled",
              width: itemWidth,
              isFavorite: false, // TODO: Add isFavorite to model
              onCreate: () async {
                debugPrint("Create clicked for: ${reel.title}");
                
                // 1. Open Video Highlight (Start of flow)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoHighlight(url: reel.thumbnail ?? ""),
                  ),
                );
              },
              onFavoriteToggle: () {
                // TODO: Implement toggle
              },
            );
          }).toList(),
        ),
      );
  }
}
