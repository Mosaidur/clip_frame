import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'dart:ui' as ui;
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
  int currentVideoIndex = 0; // Tracking the index for sequential playback
  List<Duration> videoDurations = []; // Proportional timeline support
  List<File?> videoThumbnails = []; // Actual video thumbnails
  List<List<File>> videoFilmstrips = []; // New: Multiple thumbnails per clip for timeline

  // History stacks
  final List<EditAction> _history = [];
  final List<EditAction> _redoStack = [];

  // UI state
  bool isExporting = false;
  double timelineScale = 1.0; // zoom level for timeline
  final ImagePicker _picker = ImagePicker();
  String statusText = ""; // Restored
  File? coverImage; // New: to store selected cover frame
  final ScrollController timelineScrollController = ScrollController(); // New: for auto-scroll
  
  // Selection
  int? selectedClipIndex;

  @override
  void initState() {
    super.initState();
    videoList.addAll(widget.videos);
    _initializeAllDurations();
    if (videoList.isNotEmpty) {
      _setCurrentFile(videoList.first, 0, play: false);
    }
  }

  Future<void> _generateThumbnail(File videoFile, int index) async {
    final out = await _tempFilePath("_thumb_$index.jpg");
    final cmd = '-i "${videoFile.path}" -ss 00:00:01 -vframes 1 -s 160x90 -f image2 "$out"';
    final res = await _runFFmpeg(cmd, out);
    if (res != null) {
      setState(() {
        if (index < videoThumbnails.length) {
          videoThumbnails[index] = File(res);
        }
      });
    }
  }

  Future<void> _generateFilmstrip(File videoFile, int index) async {
    final duration = await _getVideoDuration(videoFile);
    final totalFrames = 8; // Extract 8 frames to cover the strip visuals
    final interval = duration.inSeconds / totalFrames;
    
    // Create a directory for this clip's thumbs
    final dir = await getTemporaryDirectory();
    final thumbDir = Directory("${dir.path}/filmstrip_$index");
    if (!await thumbDir.exists()) await thumbDir.create();

    // ffmpeg fps filter: fps=1/interval will extract frames evenly
    // we use a pattern for output
    final outPattern = "${thumbDir.path}/thumb_%03d.jpg";
    final fps = 1 / (interval > 0 ? interval : 1);
    
    // REDUCED RESOLUTION: 80:-1 to save memory (OOM fix)
    final cmd = '-i "${videoFile.path}" -vf "fps=$fps,scale=80:-1" -vframes $totalFrames "$outPattern"';
    
    // We run this and then collect files
    await FFmpegKit.execute(cmd);
    
    final List<File> thumbs = [];
    for (int i = 1; i <= totalFrames; i++) {
        final f = File("${thumbDir.path}/thumb_${i.toString().padLeft(3, '0')}.jpg");
        if (await f.exists()) {
            thumbs.add(f);
        }
    }

    setState(() {
      if (index < videoFilmstrips.length) {
        videoFilmstrips[index] = thumbs;
      } else {
        // This shouldn't happen if initialized correctly, but safety first
        while(videoFilmstrips.length <= index) videoFilmstrips.add([]);
        videoFilmstrips[index] = thumbs;
      }
    });
  }

  Future<void> _initializeAllDurations() async {
    for (int i = 0; i < videoList.length; i++) {
      final file = videoList[i];
      videoThumbnails.add(null); // Placeholder
      videoFilmstrips.add([]); // Placeholder
      final d = await _getVideoDuration(file);
      setState(() {
        videoDurations.add(d);
      });
      _generateThumbnail(file, i);
      _generateFilmstrip(file, i);
    }
  }

  Future<Duration> _getVideoDuration(File file) async {
    final vpc = VideoPlayerController.file(file);
    try {
      await vpc.initialize();
      final duration = vpc.value.duration;
      await vpc.dispose();
      return duration;
    } catch (e) {
      return const Duration(seconds: 5); // Fallback
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    timelineScrollController.dispose();
    super.dispose();
  }

  // --- Helpers ---
  Future<String> _tempFilePath(String suffix) async {
    final dir = await getTemporaryDirectory();
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    return "${dir.path}/$name$suffix";
  }

  Future<void> _setCurrentFile(File f, int index, {bool play = true}) async {
    try {
      currentFile = f;
      currentVideoIndex = index;
      if (initialized) {
        await _controller.pause();
        _controller.removeListener(_videoListener);
        await _controller.dispose();
      }
      _controller = VideoPlayerController.file(f);
      await _controller.initialize();
      _controller.addListener(_videoListener);
      setState(() {
        initialized = true;
      });
      if (play) _controller.play();
    } catch (e) {
      debugPrint("Error setting current file: $e");
    }
  }

  void _videoListener() {
    if (initialized && _controller.value.isInitialized) {
      if (_controller.value.position >= _controller.value.duration) {
        // Video finished, play next if available
        if (currentVideoIndex < videoList.length - 1) {
          _setCurrentFile(videoList[currentVideoIndex + 1], currentVideoIndex + 1);
        }
      }
      
      // AUTO-SCROLL LOGIC
      if (_controller.value.isPlaying) {
        _syncScrollWithPlayback();
      }
      
      setState(() {}); // Update UI for position/duration
    }
  }

  void _syncScrollWithPlayback() {
    if (!timelineScrollController.hasClients) return;
    
    // Calculate global position in ms
    double elapsedMs = 0;
    for (int i = 0; i < currentVideoIndex; i++) {
      elapsedMs += videoDurations[i].inMilliseconds;
    }
    elapsedMs += _controller.value.position.inMilliseconds;
    
    // Convert ms to pixels (50px per second)
    double targetX = (elapsedMs / 1000) * 50.w;
    
    // Center the playhead
    double screenWidth = MediaQuery.of(context).size.width;
    // The scrollable area is one part of the screen (Expanded).
    // It starts at 80.w from the left edge of the screen.
    // We want the playhead to stay roughly at the same position where it starts.
    // Actually, in professional editors, the playhead often stays at a fixed "now" line.
    
    // Let's try to keep the playhead around the middle of the SCROLLABLE area
    double scrollableAreaWidth = screenWidth - 80.w - 20.w; // accounting for 80.w left and 20.w right margin
    double offset = targetX - (scrollableAreaWidth * 0.5); 
    
    if (offset < 0) offset = 0;
    if (offset > timelineScrollController.position.maxScrollExtent) {
        offset = timelineScrollController.position.maxScrollExtent;
    }
    
    timelineScrollController.jumpTo(offset);
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
      await _setCurrentFile(before, currentVideoIndex, play: false);
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
      await _setCurrentFile(after, currentVideoIndex, play: false);
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
      videoThumbnails.add(null);
      videoFilmstrips.add([]);
      final dur = await _getVideoDuration(f);
      videoDurations.add(dur);
      await _setCurrentFile(f, videoList.length - 1);
      _generateThumbnail(f, videoList.length - 1);
      _generateFilmstrip(f, videoList.length - 1);
      setState(() {});
    }
  }

  void removeVideoAt(int index) {
    if (index < videoDurations.length) videoDurations.removeAt(index);
    if (index < videoThumbnails.length) videoThumbnails.removeAt(index);
    if (index < videoFilmstrips.length) videoFilmstrips.removeAt(index);
    final removed = videoList.removeAt(index);
    if (currentFile?.path == removed.path) {
      if (videoList.isNotEmpty) _setCurrentFile(videoList.first, 0);
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
    final out = await _tempFilePath("_trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4");
    
    // Precise trim using re-encoding
    // Use fractional seconds for precision
    final startSec = start.inMilliseconds / 1000.0;
    final durSec = (end - start).inMilliseconds / 1000.0;
    
    // -c:v libx264 -preset ultrafast guarantees frame accuracy at the cost of re-encoding
    final cmd = '-i "${before.path}" -ss $startSec -t $durSec -c:v libx264 -preset ultrafast -c:a copy "$out"';
    
    setState(() => isExporting = true);
    final result = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    
    if (result != null) {
      final afterFile = File(result);
      _pushHistory(EditAction(
        type: EditType.trim,
        description: "Trim ${_formatDuration(start)} - ${_formatDuration(end)}",
        beforePath: before.path,
        afterPath: afterFile.path,
      ));
      
      // Update the sequence
      final newDur = await _getVideoDuration(afterFile);
      setState(() {
        videoList[currentVideoIndex] = afterFile;
        videoDurations[currentVideoIndex] = newDur;
        // Regenerate visuals for this clip
        videoFilmstrips[currentVideoIndex] = []; 
        videoThumbnails[currentVideoIndex] = null;
      });
      
      await _setCurrentFile(afterFile, currentVideoIndex, play: false);
      _generateThumbnail(afterFile, currentVideoIndex);
      _generateFilmstrip(afterFile, currentVideoIndex);
    }
  }

  // 2) Split video at position -> returns pair of paths (part1, part2)
  // 2) Split video at position -> returns pair of paths (part1, part2)
  Future<List<String>?> splitVideoAt(Duration globalPos) async {
    // 1. Determine which clip we are in and the local timestamp
    int accumMs = 0;
    int targetIndex = -1;
    Duration localPos = Duration.zero;

    for (int i = 0; i < videoDurations.length; i++) {
        int dur = videoDurations[i].inMilliseconds;
        if (globalPos.inMilliseconds <= accumMs + dur) {
            targetIndex = i;
            localPos = globalPos - Duration(milliseconds: accumMs);
            break;
        }
        accumMs += dur;
    }

    if (targetIndex == -1) targetIndex = videoList.length - 1;

    final targetFile = videoList[targetIndex];
    final out1 = await _tempFilePath("_part1_${DateTime.now().millisecondsSinceEpoch}.mp4");
    final out2 = await _tempFilePath("_part2_${DateTime.now().millisecondsSinceEpoch}.mp4");
    
    // Precise split using re-encoding for frame accuracy
    // -ss before -i is faster seeking, but for split we want exactness.
    // We use -c:v libx264 -preset ultrafast to be quick but accurate.
    final ms = localPos.inMilliseconds / 1000.0;
    
    // Part 1: Start to split point
    final cmd1 = '-i "${targetFile.path}" -t $ms -c:v libx264 -preset ultrafast -c:a copy "$out1"';
    
    // Part 2: Split point to end
    final cmd2 = '-i "${targetFile.path}" -ss $ms -c:v libx264 -preset ultrafast -c:a copy "$out2"';
    
    setState(() => isExporting = true);
    final r1 = await _runFFmpeg(cmd1, out1);
    final r2 = await _runFFmpeg(cmd2, out2);
    setState(() => isExporting = false);
    
    if (r1 != null && r2 != null) {
      final part1 = File(r1);
      final part2 = File(r2);

      // Update lists
      final dur1 = await _getVideoDuration(part1);
      final dur2 = await _getVideoDuration(part2);

      setState(() {
        videoList[targetIndex] = part1;
        videoDurations[targetIndex] = dur1;
        videoThumbnails[targetIndex] = null; // will regen
        videoFilmstrips[targetIndex] = [];   // will regen
        
        videoList.insert(targetIndex + 1, part2);
        videoDurations.insert(targetIndex + 1, dur2);
        videoThumbnails.insert(targetIndex + 1, null);
        videoFilmstrips.insert(targetIndex + 1, []);
        
        // If we split the current playing video, stay on the second part?
        // Usually better to pause or set to split point.
        currentVideoIndex = targetIndex + 1;
      });

      // Generate visuals
      _generateThumbnail(part1, targetIndex);
      _generateFilmstrip(part1, targetIndex);
      
      _generateThumbnail(part2, targetIndex + 1);
      _generateFilmstrip(part2, targetIndex + 1);

      await _setCurrentFile(videoList[currentVideoIndex], currentVideoIndex, play: false);
      _controller.seekTo(Duration.zero); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Split successful"), duration: Duration(milliseconds: 800)),
        );
      }
      
      return [r1, r2];
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
      final newDur = await _getVideoDuration(afterFile);
      setState(() {
        videoList[currentVideoIndex] = afterFile;
        videoDurations[currentVideoIndex] = newDur;
      });
      await _setCurrentFile(afterFile, currentVideoIndex);
      _generateThumbnail(afterFile, currentVideoIndex);
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
      // No duration change for filter usually, but kept for consistency
      setState(() => videoList[currentVideoIndex] = afterFile);
      await _setCurrentFile(afterFile, currentVideoIndex);
      _generateThumbnail(afterFile, currentVideoIndex);
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
      setState(() => videoList[currentVideoIndex] = afterFile);
      await _setCurrentFile(afterFile, currentVideoIndex);
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
      await _setCurrentFile(afterFile, currentVideoIndex);
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
      setState(() => videoList[currentVideoIndex] = afterFile);
      await _setCurrentFile(afterFile, currentVideoIndex);
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
      setState(() => videoList[currentVideoIndex] = afterFile);
      await _setCurrentFile(afterFile, currentVideoIndex);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return _buildLandscapeLayout();
            } else {
              return _buildPortraitLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Top Section (Header + Clip List)
        _buildTopSection(),

        // Video Player Area (Expanded)
        _buildVideoPlayerSection(),

        // Control Bar (Sandy)
        _buildControlBar(),

        // Timeline & Save Button (Lavender)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE1D5FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimelineSection(),
              SizedBox(height: 5.h),
              _buildSaveButton(),
              SizedBox(height: 10.h),
            ],
          ),
        ),

        // Editing Tools (Bottom)
        _buildBottomActionBar(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Left Column: Video Player and Timeline
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                Expanded(child: _buildVideoPlayerSection()),
                _buildControlBar(),
                Container(
                  color: const Color(0xFFE1D5FF),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: _buildTimelineSection(),
                ),
              ],
            ),
          ),
        ),
        // Vertical Divider
        Container(width: 1.w, color: Colors.grey[300]),
        // Right Column: Controls, clips, and tools
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFFF8E9D2),
            child: Column(
              children: [
                // Condensed Header
                _buildLandscapeHeader(),
                // Video Clip List (Grid-like scroll)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r)),
                    ),
                    child: _buildClipListView(isLandscape: true),
                  ),
                ),
                // Editing tools
                _buildLandscapeTools(),
                // Save Button
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(12.r),
                  child: _buildSaveButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeHeader() {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: Color(0xFFDCC8B0),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.r, color: Colors.black),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            "Video Editor",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeTools() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
             _actionIcon(Icons.crop_free_rounded, "Canvas", onTap: () async {
              final txt = await _inputDialog("Canvas text", "Enter overlay text");
              if (txt != null && txt.trim().isNotEmpty) overlayText(txt.trim());
            }),
            _actionIcon(Icons.layers_clear_rounded, "BG", onTap: () => removeBackground()),
            _actionIcon(Icons.delete_outline_rounded, "Delete", onTap: () => _deleteSelectedClip()),
            _actionIcon(Icons.vertical_split_rounded, "Split", onTap: () async {
              if (initialized) {
                await splitVideoAt(_controller.value.position);
              }
            }),
            _actionIcon(Icons.crop_rounded, "Crop", onTap: () async {
              final crop = await _cropDialog();
              if (crop != null) await cropVideo(x: crop[0], y: crop[1], w: crop[2], h: crop[3]);
            }),
            _actionIcon(Icons.speed_rounded, "Speed", onTap: () async {
              final v = await _speedDialog();
              if (v != null) await changeSpeed(v);
            }),
            _actionIcon(Icons.auto_awesome_motion_rounded, "Filter", onTap: () async {
              final choice = await _filterChoiceDialog();
              if (choice != null) await applyFilter(choice);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      constraints: BoxConstraints(minHeight: 120.h), // Reduced from 150.h
      color: const Color(0xFFF8E9D2), // Cream background for header and clips
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h), // Tightened from 10.h
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCC8B0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r, color: Colors.black),
                    ),
                  ),
                  // Title
                  Text(
                    "Manual Video Edit",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Menu Icon
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFACAAAA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.grid_view_rounded, size: 20.r, color: Colors.black),
                  ),
                ],
              ),
            ),
          // Clip Thumbnails List
          _buildClipListView(),
        ],
      ),
    );
  }

  Widget _buildClipListView({bool isLandscape = false}) {
    return Container(
      height: isLandscape ? null : 80.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: Colors.transparent, // Inherit background from parent
      child: videoList.isEmpty
          ? const Center(child: Text("No videos confirmed", style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: videoList.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                final f = videoList[i];
                return Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => _setCurrentFile(f, i),
                        child: Container(
                          width: isLandscape ? 120.w : 100.w,
                          height: isLandscape ? 70.h : 60.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Fallback color
                            borderRadius: BorderRadius.circular(10.r),
                            border: currentFile?.path == f.path
                                ? Border.all(color: Colors.blue, width: 2.w)
                                : null,
                            image: (i < videoThumbnails.length && videoThumbnails[i] != null)
                                ? DecorationImage(
                                    image: FileImage(videoThumbnails[i]!),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage("assets/images/placeholder_video.png"),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6.h,
                        right: -6.w,
                        child: GestureDetector(
                          onTap: () => removeVideoAt(i),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 10.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildVideoPlayerSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.black, // Dark background for video player
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (currentFile != null && initialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.white)),
            
            // Fullscreen icon
            Positioned(
              bottom: 8.h,
              right: 12.w,
              child: Icon(Icons.fullscreen, color: Colors.white, size: 20.r),
            ),
            
            if (isExporting)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: const Color(0xFFEBC894), 
      padding: EdgeInsets.symmetric(horizontal: 10.w), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.undo_rounded, color: Colors.black54, size: 24.r),
                onPressed: _history.isNotEmpty ? () => undo() : null,
              ),
              IconButton(
                icon: Icon(Icons.redo_rounded, color: Colors.black54, size: 24.r),
                onPressed: _redoStack.isNotEmpty ? () => redo() : null,
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              initialized && _controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 32.r,
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
              // Handle Done
            },
            child: Text(
              "DONE",
              style: TextStyle(
                color: const Color(0xFF5D5D5D),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    int totalMs = videoDurations.fold<int>(0, (p, c) => p + c.inMilliseconds);
    int elapsedMs = 0;
    for (int i = 0; i < currentVideoIndex; i++) {
      if (videoDurations.length > i) elapsedMs += videoDurations[i].inMilliseconds;
    }
    int globalPosMs = initialized ? (elapsedMs + _controller.value.position.inMilliseconds) : 0;
    
    String formattedTime = _formatDuration(Duration(milliseconds: globalPosMs));
    String totalTimeStr = _formatDuration(Duration(milliseconds: totalMs));

    return Column(
      children: [
        // Ruler/Timestamp
        Container(
          color: const Color(0xFFF4E1C8),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
          child: Row(
            children: [
              Text(
                "$formattedTime / $totalTimeStr",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text("00:00   .   00:02   .   00:04   .   00:06   .   00:07   .   00:08",
                    style: TextStyle(fontSize: 10.sp, color: Color(0xFF9D9DA1)),
                    overflow: TextOverflow.ellipsis),
              ),
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
              GestureDetector(
                onTap: () async {
                  if (initialized){
                    final out = await _tempFilePath("_cover.jpg");
                    final pos = _controller.value.position.inSeconds;
                    final cmd = '-i "${currentFile!.path}" -ss $pos -vframes 1 "$out"';
                    setState(() => isExporting = true);
                    final res = await _runFFmpeg(cmd, out);
                    setState(() => isExporting = false);
                    if (res != null) {
                      setState(() {
                        coverImage = File(res);
                      }
                      );
                    }
                  }
                },
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.white, width: 1),
                    image: coverImage != null
                        ? DecorationImage(
                            image: FileImage(coverImage!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage("assets/images/placeholder_video.png"),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          // color: Colors.black54,
                          child: Text("COVER",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SingleChildScrollView(
                  controller: timelineScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.zero,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Visual list of all clips
                        Container(
                          height: 38.h,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: Row(
                              children: [
                                for (int i = 0; i < videoList.length; i++)
                                  Container(
                                    width: (videoDurations.length > i)
                                        ? (videoDurations[i].inMilliseconds / 1000) * 50.w
                                        : 100.w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: i == currentVideoIndex ? Colors.white : Colors.white24,
                                        width: i == currentVideoIndex ? 2.w : 0.5.w,
                                      ),
                                    ),
                                    child: (i < videoFilmstrips.length && videoFilmstrips[i].isNotEmpty)
                                        ? Row(
                                            children: videoFilmstrips[i]
                                                .map((f) => Expanded(
                                                      child: Image.file(
                                                        f,
                                                        fit: BoxFit.cover,
                                                        height: double.infinity,
                                                        cacheWidth: 80,
                                                      ),
                                                    ))
                                                .toList(),
                                          )
                                        : Image.asset(
                                            "assets/images/placeholder_video.png",
                                            fit: BoxFit.cover,
                                            cacheWidth: 80,
                                          ),
                                  ),
                                GestureDetector(
                                  onTap: addVideoFromPicker,
                                  child: Container(
                                    width: 40.w,
                                    height: 38.h,
                                    color: Colors.white10,
                                    child: Icon(Icons.add, color: Colors.white, size: 20.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Playhead / Slider Layer
                        if (initialized && videoDurations.length == videoList.length)
                        Builder(builder: (context) {
                          final totalMs = videoDurations.fold<int>(0, (p, c) => p + c.inMilliseconds);
                          int elapsedMs = 0;
                          for (int i = 0; i < currentVideoIndex; i++) {
                            elapsedMs += videoDurations[i].inMilliseconds;
                          }
                          final globalPosMs = elapsedMs + _controller.value.position.inMilliseconds;
                          double totalWidth = 0;
                          for(var d in videoDurations) totalWidth += (d.inMilliseconds / 1000) * 50.w;

                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 38.h,
                              thumbShape: CustomPlayheadShape(height: 50.h),
                              overlayShape: SliderComponentShape.noOverlay,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                            ),
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                width: totalWidth + 40.w,
                                child: Slider(
                                  min: 0,
                                  max: totalMs.toDouble() > 0 ? totalMs.toDouble() : 1,
                                  value: globalPosMs.toDouble().clamp(0, totalMs.toDouble() > 0 ? totalMs.toDouble() : 1),
                                  onChanged: (v) async {
                                    double target = v;
                                    int accum = 0;
                                    for (int i = 0; i < videoList.length; i++) { 
                                      int dur = videoDurations[i].inMilliseconds;
                                      if (target <= accum + dur) {
                                        int localMs = (target - accum).toInt();
                                        if (currentVideoIndex != i) {
                                          await _setCurrentFile(videoList[i], i, play: false);
                                        }
                                        _controller.seekTo(Duration(milliseconds: localMs));
                                        break;
                                      }
                                      accum += dur;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          );
                        })
                        else const SizedBox.shrink(),
                      ],
                    ),
                  ),
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
              color: Colors.purple.withOpacity(0.3),
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
        height: 42.h,
        child: ElevatedButton(
          onPressed: saveCurrentToGallery,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0080FF), // Bright blue
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            elevation: 0,
          ),
          child: Text(
            "Save",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Delete the currently selected clip (or current if none selected)
  Future<void> _deleteSelectedClip() async {
    int idx = selectedClipIndex ?? currentVideoIndex;
    if (idx < 0 || idx >= videoList.length) return;

    if (videoList.length <= 1) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot delete the only clip")),
        );
       }
      return;
    }

    setState(() {
      videoList.removeAt(idx);
      videoDurations.removeAt(idx);
      videoThumbnails.removeAt(idx);
      if (idx < videoFilmstrips.length) {
        videoFilmstrips.removeAt(idx);
      }
      
      // Adjust currentVideoIndex
      // If we deleted the clip BEFORE current, shift current down
      if (idx < currentVideoIndex) {
        currentVideoIndex--;
      } 
      // If we deleted the CURRENT clip, it now points to the "next" clip (which slid into this slot).
      // If we deleted the LAST clip, we must clamp.
      if (currentVideoIndex >= videoList.length) {
        currentVideoIndex = videoList.length - 1;
      }
      
      selectedClipIndex = null;
    });

    await _setCurrentFile(videoList[currentVideoIndex], currentVideoIndex, play: false);
  }

  Widget _buildBottomActionBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _actionIcon(Icons.crop_free_rounded, "Canvas", onTap: () async {
              final txt = await _inputDialog("Canvas text", "Enter overlay text");
              if (txt != null && txt.trim().isNotEmpty) overlayText(txt.trim());
            }),
            _actionIcon(Icons.layers_clear_rounded, "BG", onTap: () => removeBackground()),
            _actionIcon(Icons.delete_outline_rounded, "Delete", onTap: () => _deleteSelectedClip()),
            _actionIcon(Icons.vertical_split_rounded, "Split", onTap: () async {
              if (initialized) {
                await splitVideoAt(_controller.value.position);
              }
            }),
            _actionIcon(Icons.crop_rounded, "Crop", onTap: () async {
              final crop = await _cropDialog();
              if (crop != null) await cropVideo(x: crop[0], y: crop[1], w: crop[2], h: crop[3]);
            }),
            _actionIcon(Icons.speed_rounded, "Speed", onTap: () async {
              final v = await _speedDialog();
              if (v != null) await changeSpeed(v);
            }),
            _actionIcon(Icons.auto_awesome_motion_rounded, "Filter", onTap: () async {
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

class CustomPlayheadShape extends SliderComponentShape {
  final double height;
  CustomPlayheadShape({required this.height});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(2.0, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required ui.TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(center.dx, center.dy - height / 2),
      Offset(center.dx, center.dy + height / 2),
      paint,
    );
  }
}

