import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ProfessionalCameraPage extends StatefulWidget {


  const ProfessionalCameraPage({super.key,});

  @override
  State<ProfessionalCameraPage> createState() => _ProfessionalCameraPageState();
}

class _ProfessionalCameraPageState extends State<ProfessionalCameraPage> {
  late final List<CameraDescription> cameras;
  CameraController? controller;
  bool isRecording = false;
  bool isFlashOn = false;

  double currentZoom = 1.0;
  double maxZoom = 1.0;

  @override
  void initState() {
    super.initState();
    initCamera(cameras.first);
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

  Future<void> startRecording() async {
    if (!controller!.value.isInitialized) return;

    await controller!.startVideoRecording();
    setState(() => isRecording = true);
  }

  Future<void> stopRecording() async { 
    final file = await controller!.stopVideoRecording();
    setState(() => isRecording = false);

    // Return video file path to previous screen
    Navigator.pop(context, File(file.path));
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
            top: 40,
            left: 20,
            right: 20,
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

          // RECORD BUTTON
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
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
        ],
      ),
    );
  }
}
