import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/video_music_controller.dart';

class MusicSelectionSheet extends StatelessWidget {
  final String? controllerTag;
  const MusicSelectionSheet({super.key, this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final VideoMusicController controller = controllerTag != null
        ? Get.find<VideoMusicController>(tag: controllerTag)
        : Get.find<VideoMusicController>();

    final List<Map<String, String>> demoTracks = [
      {"title": "Upbeat Corporate", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"},
      {"title": "Relaxing Lo-Fi", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"},
      {"title": "Tech Future", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Add Background Music",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.folder_open,
                    title: "Local Files",
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        await controller.setMusic(
                          result.files.single.path!,
                          result.files.single.name,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.library_music,
                    title: "Demo Clips",
                    onTap: () {
                      // Logic for demo clips (if any)
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: demoTracks.length,
              itemBuilder: (context, index) {
                final track = demoTracks[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE5D9FF),
                    child: Icon(Icons.music_note, color: Color(0xFF6C63FF)),
                  ),
                  title: Text(
                    track["title"]!,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Stock Music"),
                  trailing: Obx(() {
                    final isThisLoading = controller.loadingTrackUrl.value == track["url"];
                    final isAnyLoading = controller.isMusicLoading.value;
                    
                    return TextButton(
                      onPressed: isAnyLoading
                          ? null
                          : () async {
                              await controller.downloadAndSetMusic(
                                track["url"]!,
                                track["title"]!,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      child: isThisLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6C63FF),
                              ),
                            )
                          : const Text("Use"),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
