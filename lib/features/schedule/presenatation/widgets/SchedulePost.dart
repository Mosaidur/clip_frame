// schedule_post_widget.dart
import 'package:clip_frame/features/schedule/presenatation/widgets/schedulePostContent.dart';
import 'package:flutter/material.dart';

import '../../data/model.dart';


class SchedulePostWidget extends StatelessWidget {
  final SchedulePost post;
  const SchedulePostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    post.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Scheduled",
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal:5, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            print("edit post");
                          },
                        ),
                        Divider(
                          color: Colors.white, // line color
                          thickness: 5,        // line thickness
                          height: 10,          // space around line
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            print("Delete post");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Widget
            SchedulePostContentWidget(post: post),
          ],
        ),
      ),
    );
  }
}
