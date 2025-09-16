// history_widget.dart
import 'package:flutter/material.dart';
import '../../data/model.dart';
import 'historyContent.dart';


class HistoryWidget extends StatelessWidget {
  final HistoryPost post;
  const HistoryWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Expanded(child: HistoryContentWidget(post: post)),
      ),
    );
  }
}
