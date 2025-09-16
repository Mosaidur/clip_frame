// schedule_post_content_widget.dart
import 'package:flutter/material.dart';
import '../../data/model.dart';

class SchedulePostContentWidget extends StatelessWidget {
  final SchedulePost post;
  const SchedulePostContentWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF6D6D73))),
          const SizedBox(height: 5),
          Wrap(
            children: post.tags
                .map((tag) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text("#$tag",
                  style: const TextStyle(fontSize: 12)),
            ))
                .toList(),
          ),
          const SizedBox(height: 5),
          Text(post.scheduleTime,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black)),
        ],
      ),
    );
  }
}
