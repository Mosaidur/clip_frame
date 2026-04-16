import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';
import 'package:image_picker/image_picker.dart';
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
  int _currentCameraIndex = 0;
  bool _isReady = false;
  bool _isRecording = false;
  bool _hasError = false; // Added to handle error state

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
        // Small delay to ensure hardware is released
        await Future.delayed(const Duration(milliseconds: 150));
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![_currentCameraIndex], 
          ResolutionPreset.max, 
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isReady = true;
            _hasError = false;
          });
        }
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _isReady = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    });
    await _initCamera();
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

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    final bool isVideo = picked.path.toLowerCase().endsWith('.mp4') ||
        picked.path.toLowerCase().endsWith('.mov');

    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPreviewPage(
            file: File(picked.path),
            isVideo: isVideo,
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
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: const CustomBackButton(iconColor: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50.r),
              SizedBox(height: 10.h),
              Text(
                "Failed to initialize camera.\nPlease check your permissions.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isReady || _controller == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 1 / (_controller!.value.aspectRatio),
                    child: CameraPreview(_controller!),
                  ),
                ),
              ],
            ),
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
                    const CustomBackButton(
                      backgroundColor: Colors.black26,
                      iconColor: Colors.white,
                    ),
                    Text("Story", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(width: 48.w),
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
                  SizedBox(height: 10.h),
                  // Gallery | Capture | Switch Camera
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gallery Picker Button
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white54, width: 1.5),
                          ),
                          child: Icon(Icons.photo_library_rounded, color: Colors.white, size: 22.r),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      // Capture Button (center)
                      _buildCaptureButton(),
                      SizedBox(width: 20.w),
                      // Camera Switch Button
                      GestureDetector(
                        onTap: _switchCamera,
                        child: Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 24.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
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
