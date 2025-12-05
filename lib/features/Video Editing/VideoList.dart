import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../../video_edit.dart';
import '../post/presenatation/widget2/MediaDisplayWidget.dart';
import 'ProfessionalCamera.dart';
import 'VideoEditing.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final List<File> videoList = [];
  final ImagePicker picker = ImagePicker();

  // Pick video from gallery
  Future<void> pickVideo() async {
    final XFile? file =
    await picker.pickVideo(source: ImageSource.gallery);

    if (file != null) {
      setState(() => videoList.add(File(file.path)));
    }
  }

  // Record video using camera
  Future<void> recordVideo() async {
    final XFile? file =
    await picker.pickVideo(source: ImageSource.camera);

    if (file != null) {
      setState(() => videoList.add(File(file.path)));
    }
  }

  // Re-record a video and replace the old one
  Future<void> reRecordVideo(int index) async {
    try {
      final XFile? file =
      await picker.pickVideo(source: ImageSource.camera);

      if (file != null) {
        setState(() {
          videoList[index] = File(file.path);  // Replace old video
        });
      }
    } catch (e) {
      print("Error re-recording video: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC894), Color(0xFFFFFFFF), Color(0xFFB49EF4)],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

              const SizedBox(height: 20),
                
                Center(
                  child: Text(
                    "Review Your Clips",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "Preview and finalise your footage",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 16
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// List of selected/recorded videos
                Expanded(
                  child: videoList.isEmpty
                      ? const Center(
                    child: Text("No videos added yet"),
                  )
                      : ListView.builder(
                    itemCount: videoList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Step ${index + 1}"),
                          ),
                          subtitle: Container(
                            width: double.infinity  ,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Positioned.fill(
                                    child: MediaDisplayWidget(videoUrl: videoList[index].path,autoPlay: false,)
                                ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Time Container
                                // Container(
                                //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                //   decoration: BoxDecoration(
                                //     color: Colors.white.withOpacity(0.4),
                                //     borderRadius: BorderRadius.circular(15),
                                //   ),
                                //   child: Text(
                                //     "time", // your $time variable
                                //     style: const TextStyle(
                                //       color: Colors.white,
                                //       fontSize: 14,
                                //     ),
                                //   ),
                                // ),

                                /// Re-record Container
                                GestureDetector(
                                  onTap: () => reRecordVideo(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.videocam,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Re Record",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ],
                            ),
                          ),
                          onTap: () {
                            // Open custom video player
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MediaDisplayWidget(
                                  videoUrl: videoList[index].path, // pass local video path
                                ),
                              ),
                            );
                          },
                        ),

                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,      // Blue fill
                        foregroundColor: Colors.white,     // White text
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),  // Radius 10
                        ),
                      ),
                      onPressed: recordVideo,
                      child: const Text("Record Video"),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: pickVideo,
                      child: const Text("Pick Video"),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdvancedVideoEditorPage ( videos: videoList,),
                          ),
                        );
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  final List<File> videos;
  const NextPage({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Next Page"),
      ),
      body: Center(
        child: Text("Received ${videos.length} videos"),
      ),
    );
  }
}
