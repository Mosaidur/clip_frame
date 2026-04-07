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
    this.padding = 0.0,
  });

  // Format count: 1000 -> 1K, 1500 -> 1.5K
  String formatCount(int count) {
    if (count >= 1000) {
      double result = count / 1000;
      return result.toStringAsFixed(
            result.truncateToDouble() == result ? 0 : 1,
          ) +
          'K';
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
          image: image.isEmpty
              ? const AssetImage('assets/images/1.jpg') as ImageProvider
              : (image.startsWith('http')
                  ? NetworkImage(image)
                  : AssetImage(image)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: profileImage.isEmpty
                              ? const AssetImage('assets/images/profile_image.png') as ImageProvider
                              : (profileImage.startsWith('http')
                                      ? NetworkImage(profileImage)
                                      : AssetImage(profileImage))
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom row with repost and likes
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Padding(
              padding: EdgeInsets.only(right: padding!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.repeat, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            formatCount(repostCount),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('|', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ),
                          const Icon(Icons.favorite_border, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            formatCount(likeCount),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
