import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'CaptionGeneratorPage.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class AiVideoEditPage extends StatefulWidget {
  final File videoFile;
  const AiVideoEditPage({super.key, required this.videoFile});

  @override
  State<AiVideoEditPage> createState() => _AiVideoEditPageState();
}

class _AiVideoEditPageState extends State<AiVideoEditPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isProcessing = false;
  int _selectedFilterIndex = -1;

  final List<List<double>> _filters = [
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    [
      1.2,
      0.1,
      0.1,
      0,
      0,
      0.1,
      1.2,
      0.1,
      0,
      0,
      0.1,
      0.1,
      1.2,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    [1.5, 0, 0, 0, 0, 0, 1.3, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1, 0],
    [0.9, 0, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1, 0],
  ];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB49EF4), Color(0xFFEBC894)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCC8B0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.r,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      "Ai Video Edit",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFACAAAA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 20.r,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 350.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                  child: _initialized
                                      ? Center(
                                          child: AspectRatio(
                                            aspectRatio:
                                                _controller.value.aspectRatio,
                                            child: _selectedFilterIndex >= 0
                                                ? ColorFiltered(
                                                    colorFilter: ColorFilter.matrix(
                                                      _filters[_selectedFilterIndex],
                                                    ),
                                                    child: VideoPlayer(
                                                      _controller,
                                                    ),
                                                  )
                                                : VideoPlayer(_controller),
                                          ),
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15.h,
                              right: 15.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "Enhance",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_initialized && !_controller.value.isPlaying)
                              const Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 60,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: List.generate(4, (index) {
                          bool isSelected = _selectedFilterIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10.w),
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: isSelected
                                    ? Border.all(color: Colors.blue, width: 3)
                                    : null,
                                image: DecorationImage(
                                  image: AssetImage(
                                    index == 0
                                        ? "assets/images/edit_photo.png"
                                        : "assets/images/$index.jpg",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 25.h),
                      _buildLargeButton(
                        label: "Enhance video quality",
                        color: const Color(0xFFD44BFF),
                        onTap: () {
                          // Visual feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Video quality enhanced (AI)"),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildLargeButton(
                        label: "Add voiceover suggestion",
                        color: const Color(0xFF2E76FF),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Voiceover suggested (AI)"),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallButton(
                              label: "Add logo overlay",
                              icon: Icons.add,
                              color: const Color(0xFFF1D5A7),
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildSmallButton(
                              label: "Add watermark",
                              icon: Icons.add,
                              color: const Color(0xFFCDC1F4),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),
                      Text(
                        "Select Background music",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMusicChip(
                              "Calm Vibe (AI)",
                              Icons.music_note,
                              true,
                            ),
                            SizedBox(width: 10.w),
                            _buildMusicChip(
                              "Uplifting Promo",
                              Icons.music_note,
                              false,
                            ),
                            SizedBox(width: 10.w),
                            _buildMusicChip(
                              "Upload",
                              Icons.cloud_upload_outlined,
                              false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  if (_initialized) {
                                    _controller.pause();
                                  }

                                  File finalFile = widget.videoFile;

                                  if (_selectedFilterIndex > 0) {
                                    setState(() => _isProcessing = true);
                                    try {
                                      final res = await _processVideo(
                                        widget.videoFile,
                                        _filters[_selectedFilterIndex],
                                      );
                                      if (res != null) {
                                        finalFile = res;
                                      }
                                    } catch (e) {
                                      debugPrint("Ai filter baking error: $e");
                                    } finally {
                                      if (mounted)
                                        setState(() => _isProcessing = false);
                                    }
                                  }

                                  if (_initialized) {
                                    _controller.dispose();
                                    _initialized = false;
                                  }

                                  // Update mediaPath in controller for final post
                                  if (Get.isRegistered<
                                    ContentCreationController
                                  >()) {
                                    final controller =
                                        Get.find<ContentCreationController>();
                                    controller.mediaPath.value = finalFile.path;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CaptionGeneratorPage(
                                            videoFile: finalFile,
                                          ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0080FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20.r,
                                      height: 20.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "Processing...",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Save",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicChip(String label, IconData icon, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.pink, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<File?> _processVideo(File input, List<double> matrix) async {
    final tempDir = await getTemporaryDirectory();
    final outPath =
        "${tempDir.path}/ai_baked_${DateTime.now().millisecondsSinceEpoch}.mp4";

    final rr = matrix[0];
    final rg = matrix[1];
    final rb = matrix[2];
    final ra = matrix[3];
    final gr = matrix[5];
    final gg = matrix[6];
    final gb = matrix[7];
    final ga = matrix[8];
    final br = matrix[10];
    final bg = matrix[11];
    final bb = matrix[12];
    final ba = matrix[13];
    final ar = matrix[15];
    final ag = matrix[16];
    final ab = matrix[17];
    final aa = matrix[18];
    final rO = matrix[4];
    final gO = matrix[9];
    final bO = matrix[14];

    String filter =
        "colorchannelmixer=rr=$rr:rg=$rg:rb=$rb:ra=$ra:gr=$gr:gg=$gg:gb=$gb:ga=$ga:br=$br:bg=$bg:bb=$bb:ba=$ba:ar=$ar:ag=$ag:ab=$ab:aa=$aa";
    if (rO.abs() > 0.1 || gO.abs() > 0.1 || bO.abs() > 0.1) {
      filter += ",lutrgb=r='val+$rO':g='val+$gO':b='val+$bO'";
    }

    final cmd =
        '-i "${input.path}" -vf "$filter" -c:v libx264 -preset superfast -y "$outPath"';
    return await _runFFmpeg(cmd, outPath);
  }

  Future<File?> _runFFmpeg(String command, String outPath) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    if (returnCode != null && returnCode.isValueSuccess()) {
      return File(outPath);
    } else {
      final logs = await session.getLogs();
      for (var log in logs) {
        debugPrint("FFmpeg Log: ${log.getMessage()}");
      }
      return null;
    }
  }
}
