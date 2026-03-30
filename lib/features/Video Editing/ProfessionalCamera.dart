import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

class ProfessionalCameraPage extends StatefulWidget {
  final Map<String, dynamic>? stepData;
  final int? stepIndex;
  final int? totalSteps;

  const ProfessionalCameraPage({
    super.key,
    this.stepData,
    this.stepIndex,
    this.totalSteps,
  });

  @override
  State<ProfessionalCameraPage> createState() => _ProfessionalCameraPageState();
}

class _ProfessionalCameraPageState extends State<ProfessionalCameraPage> {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool isRecording = false;
  bool isFlashOn = false;

  double currentZoom = 1.0;
  double maxZoom = 1.0;

  // Preview State
  File? recordedVideoFile;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        initCamera(cameras.first);
      } else {
        debugPrint("No cameras found");
      }
    } catch (e) {
      debugPrint("Error fetching cameras: $e");
    }
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: true,
    );

    await controller!.initialize();

    maxZoom = await controller!.getMaxZoomLevel();

    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    _videoPlayerController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initVideoPlayer(File file) async {
    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.setLooping(true);
    _videoPlayerController!.play();
    setState(() {});
  }

  void _retakeVideo() {
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    if (recordedVideoFile != null && recordedVideoFile!.existsSync()) {
      recordedVideoFile!.deleteSync();
    }
    setState(() {
      recordedVideoFile = null;
      isRecording = false;
      _recordDuration = 0;
    });
  }

  void _approveVideo() {
    _videoPlayerController?.pause();
    // Return video file path to previous screen
    if (mounted && recordedVideoFile != null) {
      Navigator.pop(context, recordedVideoFile);
    }
  }

  Timer? _timer;
  int _recordDuration = 0;

  Future<void> startRecording() async {
    if (!controller!.value.isInitialized) return;

    await controller!.startVideoRecording();
    setState(() {
      isRecording = true;
      _recordDuration = 0;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      }
    });
  }

  Future<void> stopRecording() async {
    _timer?.cancel();
    final file = await controller!.stopVideoRecording();
    
    setState(() {
      isRecording = false;
      recordedVideoFile = File(file.path);
    });

    _initVideoPlayer(recordedVideoFile!);
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void toggleFlash() async {
    if (!controller!.value.isInitialized) return;

    isFlashOn = !isFlashOn;
    await controller!.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);

    setState(() {});
  }

  void switchCamera() {
    final current = controller!.description.lensDirection;

    CameraDescription newCamera;

    if (current == CameraLensDirection.back) {
      newCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
    } else {
      newCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
    }

    initCamera(newCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                // Camera View or Video Preview
                if (recordedVideoFile != null &&
                    _videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoPlayerController!.value.size.width,
                        height: _videoPlayerController!.value.size.height,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onScaleUpdate: (details) async {
                      currentZoom = (details.scale).clamp(1.0, maxZoom);
                      await controller!.setZoomLevel(currentZoom);
                    },
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller!.value.previewSize?.height ?? MediaQuery.of(context).size.width,
                          height: controller!.value.previewSize?.width ?? MediaQuery.of(context).size.height,
                          child: CameraPreview(controller!),
                        ),
                      ),
                    ),
                  ),

                // TOP BUTTONS
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Close Button
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),

                          // Flash Button
                          if (recordedVideoFile == null)
                            IconButton(
                              icon: Icon(
                                isFlashOn ? Icons.flash_on : Icons.flash_off,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: toggleFlash,
                            ),

                          // Switch Camera Button
                          if (recordedVideoFile == null)
                            IconButton(
                              icon: const Icon(
                                Icons.cameraswitch,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: switchCamera,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Step Info Display (Top Center)
                if (widget.stepData != null)
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Step ${widget.stepIndex ?? 1}${widget.totalSteps != null ? ' of ${widget.totalSteps}' : ''}: ${widget.stepData!['title'] ?? ''}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.stepData!['description'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.stepData!['description'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                // Timer Display
                if (isRecording)
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(_recordDuration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                // RECORD OR PREVIEW BUTTONS
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      child: recordedVideoFile != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _retakeVideo,
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text("Retake", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _approveVideo,
                                  icon: const Icon(Icons.check, color: Colors.white),
                                  label: const Text("Use Clip", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: isRecording ? stopRecording : startRecording,
                                child: Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isRecording ? Colors.red : Colors.white,
                                    border: Border.all(color: Colors.white, width: 6),
                                  ),
                                ),
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
