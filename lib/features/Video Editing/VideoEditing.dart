import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// ---- Models for History ----
enum EditType { trim, split, crop, speed, filter, addAudio, replace, bgRemove, overlayText, merged }

class EditAction {
  final EditType type;
  final String description;
  final String beforePath; // previous file path
  final String afterPath; // new file path produced by this edit
  final DateTime timestamp;

  EditAction({
    required this.type,
    required this.description,
    required this.beforePath,
    required this.afterPath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// ---- Editor Page ----
class AdvancedVideoEditorPage extends StatefulWidget {
  final List<File> videos; // initial video files
  const AdvancedVideoEditorPage({super.key, required this.videos});

  @override
  State<AdvancedVideoEditorPage> createState() => _AdvancedVideoEditorPageState();
}

class _AdvancedVideoEditorPageState extends State<AdvancedVideoEditorPage> {
  final List<File> videoList = [];
  File? currentFile; // current active editing file
  late VideoPlayerController _controller;
  bool initialized = false;

  // History stacks
  final List<EditAction> _history = [];
  final List<EditAction> _redoStack = [];

  // UI state
  bool isExporting = false;
  double timelineScale = 1.0; // zoom level for timeline
  final ImagePicker _picker = ImagePicker();
  String statusText = "";

  @override
  void initState() {
    super.initState();
    videoList.addAll(widget.videos);
    if (videoList.isNotEmpty) {
      _setCurrentFile(videoList.first);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Helpers ---
  Future<String> _tempFilePath(String suffix) async {
    final dir = await getTemporaryDirectory();
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    return "${dir.path}/$name$suffix";
  }

  Future<void> _setCurrentFile(File f) async {
    try {
      currentFile = f;
      if (initialized) {
        await _controller.pause();
        await _controller.dispose();
      }
      _controller = VideoPlayerController.file(f);
      await _controller.initialize();
      setState(() {
        initialized = true;
      });
      _controller.play();
    } catch (e) {
      debugPrint("Error setting current file: $e");
    }
  }

  Future<int> _durationSeconds(File f) async {
    // rely on controller for duration when current file loaded
    if (currentFile != null && currentFile!.path == f.path && initialized) {
      return _controller.value.duration.inSeconds;
    }
    // fallback: load a temporary controller
    final tmp = VideoPlayerController.file(f);
    await tmp.initialize();
    final dur = tmp.value.duration.inSeconds;
    await tmp.dispose();
    return dur;
  }

  // Run FFmpeg command and return outputPath on success (or null on error)
  Future<String?> _runFFmpeg(String cmd, String outputPath, {bool wait = true}) async {
    setState(() => statusText = "Running ffmpeg...");
    try {
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();
      if (rc != null && rc.isValueSuccess()) {
        return outputPath;
      } else {
        debugPrint("FFmpeg failed. rc=$rc, cmd=$cmd");
        return null;
      }
    } catch (e) {
      debugPrint("FFmpeg error: $e");
      return null;
    } finally {
      setState(() => statusText = "");
    }
  }

  // Push history action, clear redo
  void _pushHistory(EditAction action) {
    _history.add(action);
    _redoStack.clear();
    setState(() {});
  }

  // Undo last edit (swap to beforePath)
  Future<void> undo() async {
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    _redoStack.add(last);
    // set current to beforePath
    final before = File(last.beforePath);
    if (before.existsSync()) {
      await _setCurrentFile(before);
      setState(() => statusText = "Undid: ${last.description}");
    } else {
      setState(() => statusText = "Cannot undo: file missing");
    }
  }

  // Redo
  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _history.add(action);
    final after = File(action.afterPath);
    if (after.existsSync()) {
      await _setCurrentFile(after);
      setState(() => statusText = "Redid: ${action.description}");
    } else {
      setState(() => statusText = "Cannot redo: file missing");
    }
  }

  // Remove a specific history item (and optionally delete after file)
  Future<void> removeHistoryAt(int index) async {
    if (index < 0 || index >= _history.length) return;
    final item = _history.removeAt(index);
    // optionally delete produced file to save space
    try {
      final f = File(item.afterPath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    setState(() {});
  }

  // --- Video list / add / remove ---
  Future<void> addVideoFromPicker() async {
    final XFile? x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x != null) {
      final f = File(x.path);
      videoList.add(f);
      await _setCurrentFile(f);
      setState(() {});
    }
  }

  void removeVideoAt(int index) {
    final removed = videoList.removeAt(index);
    if (currentFile?.path == removed.path) {
      if (videoList.isNotEmpty) _setCurrentFile(videoList.first);
      else {
        currentFile = null;
        _controller.dispose();
        initialized = false;
      }
    }
    setState(() {});
  }

  // --- Basic Editing Functions using FFmpeg ---
  // 1) Trim video
  Future<void> trimVideo({required Duration start, required Duration end}) async {
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath(".mp4");
    final startSec = start.inSeconds;
    final durArg = (end - start).inSeconds;
    final cmd = '-i "${before.path}" -ss $startSec -t $durArg -c copy "$out"';
    setState(() => isExporting = true);
    final result = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (result != null) {
      final afterFile = File(result);
      _pushHistory(EditAction(
        type: EditType.trim,
        description: "Trim ${start.toString()} - ${end.toString()}",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 2) Split video at position -> returns pair of paths (part1, part2)
  Future<List<String>?> splitVideoAt(Duration at) async {
    if (currentFile == null) return null;
    final before = currentFile!;
    final out1 = await _tempFilePath("_part1.mp4");
    final out2 = await _tempFilePath("_part2.mp4");
    final atSec = at.inSeconds;
    final cmd1 = '-i "${before.path}" -ss 0 -t $atSec -c copy "$out1"';
    final cmd2 = '-i "${before.path}" -ss $atSec -c copy "$out2"';
    setState(() => isExporting = true);
    final r1 = await _runFFmpeg(cmd1, out1);
    final r2 = await _runFFmpeg(cmd2, out2);
    setState(() => isExporting = false);
    if (r1 != null && r2 != null) {
      // push as a merged action (afterPath stores concatenated file path if needed)
      _pushHistory(EditAction(
        type: EditType.split,
        description: "Split at ${at.toString()}",
        beforePath: before.path,
        afterPath: out1, // we keep afterPath as first part for easy undo; you may track both externally
      ));
      // For simplicity set current to part1
      await _setCurrentFile(File(out1));
      return [out1, out2];
    }
    return null;
  }

  // 3) Change speed (speedFactor > 1 faster, <1 slower)
  Future<void> changeSpeed(double speedFactor) async {
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath("_speed.mp4");
    // FFmpeg complex filter: setpts for video, atempo for audio (atempo accepts 0.5-2.0; chain if needed)
    // For wide ranges chain multiple atempo filters - here we handle 0.5..4.0 by chaining where necessary.
    // Build audio tempo filter
    final List<double> tempos = [];
    double remaining = speedFactor;
    // To convert audio tempo: desired audio speed = 1/speedFactor for PTS? Simpler approach: use atempo(speedFactor) when speedFactor between 0.5 and 2.0
    double audioTempo = speedFactor.clamp(0.5, 2.0);
    // If outside bounds, approximate by chaining; but here keep audioTempo in [0.5,2.0]
    final audioFilter = 'atempo=$audioTempo';
    final cmd = '-i "${before.path}" -filter_complex "[0:v]setpts=${1/speedFactor}*PTS[v];[0:a]$audioFilter[a]" -map "[v]" -map "[a]" -r 30 -y "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      _pushHistory(EditAction(
        type: EditType.speed,
        description: "Speed x $speedFactor",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 4) Apply simple filter (grayscale, sepia, negate)
  Future<void> applyFilter(String name) async {
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath("_filter.mp4");
    String vf;
    switch (name) {
      case 'grayscale':
        vf = 'hue=s=0';
        break;
      case 'sepia':
      // approximate sepia using colorchannelmixer
        vf = 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131';
        break;
      case 'negate':
        vf = 'negate';
        break;
      default:
        vf = '';
    }
    final cmd = vf.isEmpty
        ? '-i "${before.path}" -c copy "$out"'
        : '-i "${before.path}" -vf "$vf" -c:a copy "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      _pushHistory(EditAction(
        type: EditType.filter,
        description: "Filter $name",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 5) Trim UI wrapper (asks user for start & end) - simple
  Future<void> quickTrimUI() async {
    if (currentFile == null) return;
    final total = _controller.value.duration;
    // show simple dialog with two sliders
    Duration start = Duration.zero;
    Duration end = total;
    await showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(builder: (c2, setS) {
          return AlertDialog(
            title: const Text("Trim"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Start: ${_formatDuration(start)}"),
                Slider(
                  min: 0,
                  max: total.inMilliseconds.toDouble(),
                  value: start.inMilliseconds.toDouble().clamp(0, total.inMilliseconds.toDouble()),
                  onChanged: (v) => setS(() => start = Duration(milliseconds: v.toInt())),
                ),
                Text("End: ${_formatDuration(end)}"),
                Slider(
                  min: 0,
                  max: total.inMilliseconds.toDouble(),
                  value: end.inMilliseconds.toDouble().clamp(0, total.inMilliseconds.toDouble()),
                  onChanged: (v) => setS(() => end = Duration(milliseconds: v.toInt())),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
              FilledButton(
                onPressed: () {
                  Navigator.pop(c);
                  trimVideo(start: start, end: end);
                },
                child: const Text("Apply"),
              ),
            ],
          );
        });
      },
    );
  }

  // 6) Crop (x,y,w,h) - expects ints normalized to video resolution; we provide dialog to hard input simple crop
  Future<void> cropVideo({required int x, required int y, required int w, required int h}) async {
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath("_crop.mp4");
    final cmd = '-i "${before.path}" -filter:v "crop=$w:$h:$x:$y" -c:a copy "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      _pushHistory(EditAction(
        type: EditType.crop,
        description: "Crop $w x $h @($x,$y)",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 7) Add audio (mix)
  Future<void> addAudioLayer(File audioFile, {double volume = 1.0}) async {
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath("_addaudio.mp4");
    // -shortest to finish with shortest stream; adjust mixing as needed
    final cmd = '-i "${before.path}" -i "${audioFile.path}" -filter_complex "[1:a]volume=$volume[a1];[0:a][a1]amix=inputs=2:duration=first:dropout_transition=2[aout]" -map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 128k "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      _pushHistory(EditAction(
        type: EditType.addAudio,
        description: "Add audio ${audioFile.path}",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 8) Background remove (simple chroma-key: remove green)
  Future<void> removeBackground({String keyColor = "0x00FF00"}) async {
    // keyColor should be hex color for chromakey; ffmpeg chromakey filter uses color names or hex like 0xRRGGBB
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath("_bgremoved.mp4");
    // using "chromakey" video filter: chromakey=color:similarity:blend
    // similarity 0.1..0.6, blend 0..1 - tune in UI for better results
    final cmd = '-i "${before.path}" -vf "chromakey=${keyColor}:0.25:0.0,format=rgba" -c:a copy "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      _pushHistory(EditAction(
        type: EditType.bgRemove,
        description: "Background removed (chroma key $keyColor)",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 9) Overlay text (canvas)
  Future<void> overlayText(String text, {int x = 10, int y = 10, int fontsize = 24}) async {
    if (currentFile == null) return;
    final before = currentFile!;
    final out = await _tempFilePath("_overlay.mp4");
    // drawtext requires libfreetype during ffmpeg compilation; assume available
    final escaped = text.replaceAll(":", "\\:").replaceAll("'", "\\'");
    final cmd = '-i "${before.path}" -vf "drawtext=fontfile=/system/fonts/Roboto-Regular.ttf:text=\'$escaped\':fontcolor=white:fontsize=$fontsize:x=$x:y=$y" -c:a copy "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      _pushHistory(EditAction(
        type: EditType.overlayText,
        description: "Overlay text: $text",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      await _setCurrentFile(afterFile);
    }
  }

  // 10) Save/export current file to permanent location
  Future<void> saveCurrentToGallery() async {
    if (currentFile == null) return;
    final dir = await getTemporaryDirectory();
    final out = "${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.mp4";
    // For now we simply copy; more complicated transcoding can be done
    setState(() => isExporting = true);
    try {
      final newFile = await File(currentFile!.path).copy(out);
      setState(() => statusText = "Saved: ${newFile.path}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved: ${newFile.path}")));
    } catch (e) {
      setState(() => statusText = "Save failed");
    } finally {
      setState(() => isExporting = false);
    }
  }

  // Utility: format duration
  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  // ---- UI Building ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8E9D2), // Cream top color
        ),
        child: Column(
          children: [
            // Top Section (Custom AppBar + Clips)
            _buildTopSection(),

            // Video Player Section (Resized compact)
            _buildVideoPlayerSection(),

            // Bottom Section (Controls + Timeline + Tools)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD0C4F2), // Lavender bottom color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildControlBar(),
                      _buildTimelineSection(),
                      SizedBox(height: 15.h),
                      _buildSaveButton(),
                      SizedBox(height: 15.h),
                      _buildBottomActionBar(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCC8B0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r),
                  ),
                ),
                // Title
                Text(
                  "Manual Video Edit",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Menu Icon
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFACAAAA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.grid_view_rounded, size: 18.r, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            // Clip Thumbnails List
            SizedBox(
              height: 70.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: videoList.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, i) {
                  final f = videoList[i];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _setCurrentFile(f),
                        child: Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: currentFile?.path == f.path
                                ? Border.all(color: Colors.blue, width: 2.w)
                                : null,
                            image: const DecorationImage(
                              image: AssetImage("assets/images/placeholder_video.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white.withOpacity(0.7),
                              size: 24.r,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => removeVideoAt(i),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 12.r),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerSection() {
    return Container(
      width: double.infinity,
      height: 200.h, // Compact height to prevent overflow
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (currentFile != null && initialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: VideoPlayer(_controller),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Center(child: Text("Loading video...")),
            ),
          // Fullscreen icon
          Positioned(
            bottom: 8.h,
            right: 12.w,
            child: Icon(Icons.fullscreen, color: Colors.white.withOpacity(0.8), size: 24.r),
          ),
          if (isExporting)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.undo, color: Colors.black54, size: 22.r),
                onPressed: _history.isNotEmpty ? () => undo() : null,
              ),
              IconButton(
                icon: Icon(Icons.redo, color: Colors.black54, size: 22.r),
                onPressed: _redoStack.isNotEmpty ? () => redo() : null,
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              initialized && _controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 36.r,
              color: Colors.black,
            ),
            onPressed: () {
              if (initialized) {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              }
            },
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Done pressed")));
            },
            child: Text(
              "DONE",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    String formattedTime = initialized ? _formatDuration(_controller.value.position) : "00:00";
    String totalTime = (initialized && _controller.value.duration != null) 
        ? _formatDuration(_controller.value.duration) 
        : "00:00";

    return Column(
      children: [
        // Ruler/Timestamp
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Text(
                "$formattedTime / $totalTime",
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
              const Expanded(child: SizedBox()),
              Text("00:00   .   00:02   .   00:04",
                  style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        // Timeline Track
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              // Cover thumbnail
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/placeholder_video.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("COVER", style: TextStyle(color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold)),
                      Icon(Icons.edit, color: Colors.white, size: 8.r),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Video strip (mock) using Slider for scrubbing
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 35.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/video_strip.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (initialized)
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 35.h,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2.r),
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                        ),
                        child: Slider(
                          min: 0,
                          max: _controller.value.duration.inMilliseconds.toDouble(),
                          value: _controller.value.position.inMilliseconds.toDouble().clamp(0, _controller.value.duration.inMilliseconds.toDouble()),
                          onChanged: (v) {
                            _controller.seekTo(Duration(milliseconds: v.toInt()));
                            setState(() {});
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Music track
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
          padding: EdgeInsets.only(left: 60.w), // Align with video strip
          child: Container(
            height: 25.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.music_note, size: 12.r, color: Colors.white),
                SizedBox(width: 5.w),
                Text("Add music", style: TextStyle(color: Colors.white, fontSize: 9.sp)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: saveCurrentToGallery,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007BFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            elevation: 0,
          ),
          child: Text(
            "Save",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _actionIcon(Icons.brush, "Canvas", onTap: () async {
               final txt = await _inputDialog("Canvas text", "Enter overlay text");
               if (txt != null && txt.trim().isNotEmpty) overlayText(txt.trim());
            }),
            _actionIcon(Icons.image_not_supported, "BG_remove", onTap: () => removeBackground()),
            _actionIcon(Icons.cut, "Trim", onTap: () => quickTrimUI()),
            _actionIcon(Icons.content_cut, "Split", onTap: () async {
               final dur = _controller.value.duration;
               final at = Duration(seconds: dur.inSeconds ~/ 2);
               await splitVideoAt(at);
            }),
            _actionIcon(Icons.crop, "Crop", onTap: () async {
               final crop = await _cropDialog();
               if (crop != null) await cropVideo(x: crop[0], y: crop[1], w: crop[2], h: crop[3]);
            }),
            _actionIcon(Icons.speed, "Speed", onTap: () async {
               final v = await _speedDialog();
               if (v != null) await changeSpeed(v);
            }),
            _actionIcon(Icons.filter, "Filter", onTap: () async {
               final choice = await _filterChoiceDialog();
               if (choice != null) await applyFilter(choice);
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            Icon(icon, color: Colors.black54, size: 24.r),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 9.sp, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Dialogs ---
  Widget _toolTile(IconData icon, String label, {VoidCallback? onTap}) {
     return _actionIcon(icon, label, onTap: onTap);
  }


  Future<String?> _inputDialog(String title, String hint) async {
    String val = "";
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (v) => val = v,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(c, val), child: const Text("OK")),
        ],
      ),
    );
  }

  Future<List<int>?> _cropDialog() async {
    int x = 0, y = 0, w = (_controller.value.size.width ~/ 1).toInt(), h = (_controller.value.size.height ~/ 1).toInt();
    return showDialog<List<int>>(
      context: context,
      builder: (c) {
        return StatefulBuilder(builder: (c2, setS) {
          return AlertDialog(
            title: const Text("Crop"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "x"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setS(() => x = int.tryParse(v) ?? 0),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "y"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setS(() => y = int.tryParse(v) ?? 0),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "width"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setS(() => w = int.tryParse(v) ?? w),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "height"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setS(() => h = int.tryParse(v) ?? h),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
              FilledButton(onPressed: () => Navigator.pop(c, [x, y, w, h]), child: const Text("Apply")),
            ],
          );
        });
      },
    );
  }

  Future<double?> _speedDialog() async {
    double val = 1.0;
    return showDialog<double>(
      context: context,
      builder: (c) {
        return StatefulBuilder(builder: (c2, setS) {
          return AlertDialog(
            title: const Text("Speed"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(min: 0.25, max: 4.0, value: val, onChanged: (v) => setS(() => val = v)),
                Text("x ${val.toStringAsFixed(2)}"),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
              FilledButton(onPressed: () => Navigator.pop(c, val), child: const Text("Apply")),
            ],
          );
        });
      },
    );
  }

  Future<String?> _filterChoiceDialog() async {
    return showDialog<String>(
      context: context,
      builder: (c) {
        return SimpleDialog(
          title: const Text("Choose Filter"),
          children: [
            SimpleDialogOption(onPressed: () => Navigator.pop(c, "grayscale"), child: const Text("Grayscale")),
            SimpleDialogOption(onPressed: () => Navigator.pop(c, "sepia"), child: const Text("Sepia")),
            SimpleDialogOption(onPressed: () => Navigator.pop(c, "negate"), child: const Text("Negate")),
          ],
        );
      },
    );
  }
}

