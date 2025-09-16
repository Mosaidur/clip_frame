import 'package:flutter/material.dart';
import 'package:clip_frame/features/post/presenatation/widgets/reelContainer.dart';

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
              onCreate: () {
                debugPrint("Create clicked for: ${reel["title"]}");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Reelsscrollpage()),
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
