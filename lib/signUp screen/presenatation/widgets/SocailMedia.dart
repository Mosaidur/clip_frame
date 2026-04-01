import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/BusinessTypeSelectionController.dart';

class ScoicalMediaPage extends StatefulWidget {
  const ScoicalMediaPage({super.key});

  @override
  State<ScoicalMediaPage> createState() => _ScoicalMediaPageState();
}

class _ScoicalMediaPageState extends State<ScoicalMediaPage> {
  final Set<String> _selectedPlatforms = {};

  final List<Map<String, String>> platforms = [
    {"name": "Facebook", "icon": "assets/images/facebook.png"},
    {"name": "Instagram", "icon": "assets/images/instagram.png"},
    {"name": "TikTok", "icon": "assets/images/tiktok.png"},
  ];

  void _togglePlatform(String name) {
    setState(() {
      if (_selectedPlatforms.contains(name)) {
        _selectedPlatforms.remove(name);
      } else {
        _selectedPlatforms.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Social Media Platforms Selection",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Choose one or more social media platforms",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: const Text("Content Languages", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: platforms.map((platform) {
                        final isSelected = _selectedPlatforms.contains(platform['name']);
                        return GestureDetector(
                          onTap: () => _togglePlatform(platform['name']!),
                          child: Container(
                            height: 60,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(platform['icon']!),
                                  ),
                                ),
                                if (isSelected)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10,),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}