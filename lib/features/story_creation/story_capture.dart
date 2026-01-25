import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'story_preview.dart';

class StoryCapturePage extends StatefulWidget {
  final bool isAddingMore;
  const StoryCapturePage({super.key, this.isAddingMore = false});

  @override
  State<StoryCapturePage> createState() => _StoryCapturePageState();
}

class _StoryCapturePageState extends State<StoryCapturePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.max, enableAudio: true);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isReady = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    XFile file;
    if (_isRecording) {
      file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
    } else {
      file = await _controller!.takePicture();
    }

    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPreviewPage(
            file: File(file.path),
            isVideo: _isRecording,
            isAddingMore: widget.isAddingMore,
          ),
        ),
      );
      
      if (widget.isAddingMore && result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),

          // 2. Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 28.r),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Take Picture", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10.h),
                          Text("Capture Footage", style: TextStyle(color: const Color(0xFFEBC894), fontSize: 18.sp, fontWeight: FontWeight.w900)),
                          Text("Try to keep the phone steady. Landscape orientation works best for reels.", 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.help_outline, color: Colors.white, size: 24.r),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Controls Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Functional Icons Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _iconButton(Icons.flash_off_rounded),
                        _iconButton(Icons.exposure_rounded),
                        _iconButton(Icons.timer_off_outlined),
                        _iconButton(Icons.blur_on_rounded), // Placeholder for BG tool in capture?
                        _iconButton(Icons.aspect_ratio_rounded, label: "4:3"),
                        _iconButton(Icons.grid_on_rounded),
                        _iconButton(Icons.cameraswitch_rounded),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // Capture Button
                  _buildCaptureButton(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {String? label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22.r),
        if (label != null) Text(label, style: TextStyle(color: Colors.white, fontSize: 8.sp)),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _onCapture,
      onLongPressStart: (_) {
        setState(() => _isRecording = true);
        _controller?.startVideoRecording();
      },
      onLongPressEnd: (_) => _onCapture(),
      child: Container(
        width: 75.r,
        height: 75.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4.r),
        ),
        child: Center(
          child: Container(
            width: 60.r,
            height: 60.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
