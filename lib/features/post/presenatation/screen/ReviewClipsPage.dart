
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:clip_frame/features/Video%20Editing/ProfessionalCamera.dart';
import 'package:clip_frame/features/Video%20Editing/VideoEditing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ReviewClipsPage extends StatefulWidget {
  final List<File> recordedClips;

  const ReviewClipsPage({Key? key, required this.recordedClips}) : super(key: key);

  @override
  State<ReviewClipsPage> createState() => _ReviewClipsPageState();
}

class _ReviewClipsPageState extends State<ReviewClipsPage> {
  // Map to store thumbnails for each clip to avoid re-generating them
  Map<String, String?> _thumbnails = {};
  // Map to store durations for each clip
  Map<String, String> _durations = {};

  @override
  void initState() {
    super.initState();
    _generateThumbnails();
  }

  Future<void> _generateThumbnails() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final List<Future> futures = [];

      for (var file in widget.recordedClips) {
        if (!_durations.containsKey(file.path)) {
          final tempController = VideoPlayerController.file(file);
          tempController.initialize().then((_) {
            if (mounted) {
              final duration = tempController.value.duration;
              setState(() {
                _durations[file.path] = _formatDuration(duration.inSeconds);
              });
              tempController.dispose();
            }
          }).catchError((e) {
            debugPrint("Duration fetching error: $e");
            tempController.dispose();
          });
        }

        if (!_thumbnails.containsKey(file.path) || _thumbnails[file.path] == null) {
          futures.add(VideoThumbnail.thumbnailFile(
            video: file.path,
            thumbnailPath: tempDir.path,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 400, // Increased for higher resolution
            quality: 90,    // Increased for better sharpness
          ).then((thumb) {
            if (mounted) {
              setState(() {
                _thumbnails[file.path] = thumb;
              });
            }
          }).catchError((e) {
            debugPrint("Thumbnail generation error for ${file.path}: $e");
            if (mounted) {
              setState(() {
                _thumbnails[file.path] = null; // Ensure it doesn't hang forever
              });
            }
          }));
        }
      }
      await Future.wait(futures);
    } catch (e) {
      debugPrint("Global thumbnail generation error: $e");
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _addNewClip() async {
    // Navigate back to camera to add more
    // We expect the camera to return a NEW file or list of files
    // But since the camera is "above" us in the stack if we came from it, 
    // we might actually want to Push a new camera instance or Pop with a signal?
    // The user flow describes: Camera -> Review -> Camera (add more) -> Review.
    
    // Small delay before pushing camera to allow any background disposal to complete
    await Future.delayed(const Duration(milliseconds: 100));
    
    final File? newVideo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfessionalCameraPage()),
    );

    if (newVideo != null && mounted) {
      setState(() {
        widget.recordedClips.add(newVideo);
      });
      _generateThumbnails();
    }
  }

  void _onReRecord(int index) async {
    // Open camera to replace this specific clip
    // Small delay before pushing camera
    await Future.delayed(const Duration(milliseconds: 100));

    final File? replacedVideo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfessionalCameraPage()),
    );

    if (replacedVideo != null && mounted) {
      setState(() {
        widget.recordedClips[index] = replacedVideo;
        _thumbnails.remove(widget.recordedClips[index].path); // Remove old thumb if path same (unlikely) or just cleanup
      });
      _generateThumbnails();
    }
  }

  void _onConfirm() {
    if (widget.recordedClips.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdvancedVideoEditorPage(videos: widget.recordedClips),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // Beige/Peach background from image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
             backgroundColor: Colors.black12,
             child: IconButton(
               icon: const Icon(Icons.arrow_back, color: Colors.black),
               onPressed: () => Navigator.pop(context),
             ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Review Your Clips",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Preview and finalise your footage",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.recordedClips.length + 1, // +1 for "Add more" button if needed, or just keep it simple
                itemBuilder: (context, index) {
                  if (index == widget.recordedClips.length) {
                     // "Add Another Clip" button at the end of list
                     return Padding(
                       padding: const EdgeInsets.symmetric(vertical: 20),
                       child: Center(
                         child: GestureDetector(
                            onTap: _addNewClip,
                            child: Container(
                              width: 60, 
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white, 
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]
                              ),
                              child: const Icon(Icons.add, size: 30, color: Colors.blueAccent),
                            ),
                         ),
                       ),
                     );
                  }

                  final file = widget.recordedClips[index];
                  final thumbPath = _thumbnails[file.path];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Step ${index + 1}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black26, 
                                image: thumbPath != null 
                                  ? DecorationImage(image: FileImage(File(thumbPath)), fit: BoxFit.cover)
                                  : null,
                              ),
                              child: thumbPath == null 
                                ? const Center(child: CircularProgressIndicator()) 
                                : null,
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _durations[file.path] ?? "00:00",
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                             Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => _onReRecord(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.refresh, size: 16),
                                      SizedBox(width: 4),
                                      Text("Re record", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                               top: 10,
                               right: 10,
                               child: const Icon(Icons.more_horiz, color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF), // Blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm & Continue",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
