import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ProfessionalCameraPage extends StatefulWidget {


  const ProfessionalCameraPage({super.key,});

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
    super.dispose();
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
    setState(() => isRecording = false);

    // Return video file path to previous screen
    if (mounted) {
        Navigator.pop(context, File(file.path));
    }
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void toggleFlash() async {
    if (!controller!.value.isInitialized) return;

    isFlashOn = !isFlashOn;
    await controller!.setFlashMode(
      isFlashOn ? FlashMode.torch : FlashMode.off,
    );

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
          // Camera View
          GestureDetector(
            onScaleUpdate: (details) async {
              currentZoom = (details.scale).clamp(1.0, maxZoom);
              await controller!.setZoomLevel(currentZoom);
            },
            child: CameraPreview(controller!),
          ),

          // TOP BUTTONS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Flash Button
                    IconButton(
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: toggleFlash,
                    ),

                    // Switch Camera Button
                    IconButton(
                      icon: const Icon(Icons.cameraswitch,
                          color: Colors.white, size: 32),
                      onPressed: switchCamera,
                    ),
                  ],
                ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // RECORD BUTTON
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
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
