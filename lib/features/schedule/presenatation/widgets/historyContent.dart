// history_content_widget.dart
import 'package:flutter/material.dart';
import '../../data/model.dart';

class HistoryContentWidget extends StatelessWidget {
  final HistoryPost post;
  const HistoryContentWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final totalReach =
        post.facebookReach + post.instagramReach + post.tiktokReach;

    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth / 3-30;
    final contentWidth = screenWidth * 2 / 3 - 70 ; // two-thirds minus paddings

    double _barWidth(int reach) {
      if (totalReach == 0) return 0;
      return contentWidth * (reach / totalReach)-5;
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              post.imageUrl,
              width: imageWidth,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: contentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 5,),
                Text(post.title,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF6D6D73))),
                SizedBox(height: 5,),
                Wrap(
                  children: post.tags
                      .map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text("#$tag",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6D6D73))),
                  ))
                      .toList(),
                ),
                SizedBox(height: 5,),
                Text(post.scheduleTime,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101017))),
                const SizedBox(height: 8),
                const Text("Total Audience",
                    style: TextStyle(color: Color(0xFF9D9DA1))),
                SizedBox(height: 8,),
                Row(
                  children: [
                    Text("${post.totalAudience}",
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF007CFE))),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: post.percentageGrowth >= 0
                              ? const Color(0xFF0CCC1E)
                              : Colors.red,
                        ),
                        color: (post.percentageGrowth >= 0
                            ? const Color(0xFF0CCC1E)
                            : Colors.red)
                            .withOpacity(0.1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            post.percentageGrowth >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 14,
                            color: post.percentageGrowth >= 0
                                ? const Color(0xFF0CCC1E)
                                : Colors.red,
                          ),
                          Text(
                            "${post.percentageGrowth.abs()}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: post.percentageGrowth >= 0
                                  ? const Color(0xFF0CCC1E)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Bars
                Row(
                  children: [
                    Container(
                        height: 5,
                        width: _barWidth(post.facebookReach),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF2870F3),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                        height: 5,
                        width: _barWidth(post.instagramReach),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFFF277F),
                      ),

                    ),
                    const SizedBox(width: 5),
                    Container(
                        height: 5,
                        width: _barWidth(post.tiktokReach),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:  Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _LegendDot(color: Color(0xFF2870F3), text: "Facebook"),
                    _LegendDot(color: Color(0xFFFF277F), text: "Instagram"),
                    _LegendDot(color: Colors.black, text: "Tiktok"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6D6D73))),
      ],
    );
  }
}
