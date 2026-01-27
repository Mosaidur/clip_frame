import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clip_frame/features/Video%20Editing/ProfessionalCamera.dart';
import 'package:clip_frame/features/Video%20Editing/VideoEditing.dart';
import 'package:clip_frame/features/post/presenatation/widgets/reelContainer.dart';
import '../Screen_2/video_Highlight.dart';

import '../screen/reelsScrollPage.dart';

class ReelsListPage extends StatefulWidget {
  final List<Map<String, dynamic>> reelsData;

  const ReelsListPage({super.key, required this.reelsData});

  @override
  State<ReelsListPage> createState() => _ReelsListPageState();
}

class _ReelsListPageState extends State<ReelsListPage> {
  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width / 2 - 25;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 10, // horizontal spacing
          runSpacing: 10, // vertical spacing
          children: widget.reelsData.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> reel = entry.value;

            return ReelsContainerPage(
              imagePath: reel["imagePath"],
              time: reel["time"],
              title: reel["title"],
              width: itemWidth,
              isFavorite: reel["isFavorite"],
              onCreate: () async {
                debugPrint("Create clicked for: ${reel["title"]}");
                
                // 1. Open Video Highlight (Start of flow)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoHighlight(url: reel["imagePath"]),
                  ),
                );


              },
              onFavoriteToggle: () {
                setState(() {
                  widget.reelsData[index]["isFavorite"] =
                  !widget.reelsData[index]["isFavorite"];
                  debugPrint(
                      "Favorite toggled for: ${widget.reelsData[index]["title"]}, isFavorite: ${widget.reelsData[index]["isFavorite"]}");
                });
              },
            );
          }).toList(),
        ),
      );
  }
}
