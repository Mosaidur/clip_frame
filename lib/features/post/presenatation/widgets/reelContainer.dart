import 'package:flutter/material.dart';

class ReelsContainerPage extends StatelessWidget {
  final String imagePath;
  final String time;
  final String title;
  final bool isFavorite;
  final VoidCallback onCreate;
  final VoidCallback onFavoriteToggle;
  final double width;

  const ReelsContainerPage({
    super.key,
    required this.imagePath,
    required this.time,
    required this.title,
    this.isFavorite = false,
    required this.onCreate,
    required this.onFavoriteToggle, required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 220,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          // Image + overlays
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 150,
              width: width,
              child: Stack(
                children: [
                  // Background image
                  ClipRRect(
                    borderRadius:
                     BorderRadius.circular(15),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Top left "Reels"
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF277F),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        "Reels",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                  ),

                  // Bottom left time
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom right favorite
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite: Icons.favorite_border,
                          color: isFavorite
                              ? const Color(0xFFFF277F)
                              : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Title
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                color: Color(0xFF6D6D73),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          ),

          // Create Button
          Padding(
            padding: const EdgeInsets.only(bottom: 10,left: 15,right: 15,top: 10),
            child: SizedBox(
              height: 35,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007CFE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: onCreate,
                child: const Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
