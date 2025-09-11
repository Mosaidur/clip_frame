import 'package:flutter/material.dart';

class PostContent extends StatelessWidget {
  final double width;
  final String image;
  final String profileImage;
  final String name;
  final int likeCount;
  final int repostCount;
  final double? padding;

  const PostContent({
    super.key,
    required this.width,
    required this.image,
    required this.profileImage,
    required this.name,
    required this.likeCount,
    required this.repostCount,
    this.padding = 0.0 ,
  });

  // Format count: 1000 -> 1K, 1500 -> 1.5K
  String formatCount(int count) {
    if (count >= 1000) {
      double result = count / 1000;
      return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1) + 'K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Top-left profile + name
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              // height: 24,
              // width: width-15,
              // padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12.5,
                    backgroundImage: AssetImage(profileImage),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ),
          // Bottom row with repost and likes
          Positioned(
            bottom: 5,
            left: 5,
            right: 5,
            child: Padding(
              padding: EdgeInsets.only(right: padding!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.repeat, color: Colors.white, size: 12),
                    // const SizedBox(width: 4),
                    Text(
                      formatCount(repostCount),
                      overflow: TextOverflow.fade,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    // const SizedBox(width: 4),
                    const Text(
                      ' | ',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    // const SizedBox(width: 4),
                    const Icon(Icons.favorite_border, color: Colors.white, size: 12),
                    // const SizedBox(width: 4),
                    Text(
                       formatCount(likeCount),
                      overflow: TextOverflow.fade,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
