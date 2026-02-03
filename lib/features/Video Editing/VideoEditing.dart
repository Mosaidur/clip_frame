import 'dart:io';
import 'package:gal/gal.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';
import 'package:get/get.dart';
import 'AiVideoEditPage.dart';
import 'ProfessionalCamera.dart';

/// ---- Models for Video Segments ----
class ClipSegment {
  File originalFile;
  Duration startOffset;
  Duration endOffset;
  double speed;
  final String? filter;
  int rotation; // 0, 90, 180, 270

  ClipSegment({
    required this.originalFile,
    required this.startOffset,
    required this.endOffset,
    this.speed = 1.0,
    this.filter,
    this.rotation = 0,
  });

  Duration get duration => Duration(
    microseconds: ((endOffset - startOffset).inMicroseconds / speed).round(),
  );

  // Clone for history
  ClipSegment copy() => ClipSegment(
    originalFile: originalFile,
    startOffset: startOffset,
    endOffset: endOffset,
    speed: speed,
    filter: filter,
    rotation: rotation,
  );
}

/// ---- Models for History ----
enum EditType {
  trim,
  split,
  crop,
  speed,
  filter,
  addAudio,
  replace,
  bgRemove,
  overlayText,
  merged,
}

class EditAction {
  final EditType type;
  final String description;
  // Non-destructive snapshots
  final List<ClipSegment> beforeSegments;
  final List<ClipSegment> afterSegments;
  final int? affectedIndex;
  final DateTime timestamp;

  EditAction({
    required this.type,
    required this.description,
    required this.beforeSegments,
    required this.afterSegments,
    this.affectedIndex,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// ---- Editor Page ----
class AdvancedVideoEditorPage extends StatefulWidget {
  final List<File> videos; // initial video files
  const AdvancedVideoEditorPage({super.key, required this.videos});

  @override
  State<AdvancedVideoEditorPage> createState() =>
      _AdvancedVideoEditorPageState();
}

class _AdvancedVideoEditorPageState extends State<AdvancedVideoEditorPage> {
  // NON-DESTRUCTIVE CORE
  final List<ClipSegment> videoSegments = [];

  // Original resources mapping (Path -> Thumbnails/Filmstrips)
  final Map<String, File?> originalThumbnails = {};
  final Map<String, List<File>> originalFilmstrips = {};
  final Map<String, Duration> originalDurations = {};

  ClipSegment? currentSegment;
  late VideoPlayerController _controller;
  bool initialized = false;
  int currentVideoIndex = 0;
  double projectAspectRatio = 9 / 16; // Default to vertical/Reels

  // History stacks
  final List<EditAction> _history = [];
  final List<EditAction> _redoStack = [];

  // UI state
  bool isExporting = false;
  double timelineScale = 1.0;
  final ImagePicker _picker = ImagePicker();
  String statusText = "";
  File? coverImage;

  // Controllers
  final ScrollController timelineScrollController = ScrollController();
  final ScrollController _rulerScrollController = ScrollController();

  // Selection
  int? selectedClipIndex;

  // Scrolling
  bool _isUserDragging = false;
  bool _isAutoScrolling = false;
  DateTime _lastUserScrollTime = DateTime.now();

  // Flexible Playhead
  double _playheadOffset = 0;
  double get startPadding => 7.w;

  // New: Cropping State
  bool _isCropping = false;
  Rect _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8); // Normalized 0..1

  // New: Speeding State
  bool _isSpeeding = false;
  double _tempSpeed = 1.0;
  int? _lastFFmpegRC;

  // New: Filtering State
  bool _isFiltering = false;
  String _selectedFilterCategory = "Trending";
  int _selectedFilterIndex = 0; // "NONE"
  double _filterIntensity = 0.5;
  int _initialFilterIndex = 0;
  double _initialFilterIntensity = 0.5;

  // Filter Data
  final Map<String, List<Map<String, dynamic>>> _filterCategories = {
    "Trending": [
      {"name": "NONE", "image": "assets/images/edit_photo.png"},
      {"name": "DUAL", "image": "assets/images/1.jpg"},
      {"name": "POP", "image": "assets/images/2.jpg"},
      {"name": "NEON", "image": "assets/images/filter_img1.png"},
      {"name": "FILM", "image": "assets/images/5.jpg"},
      {"name": "GLOW", "image": "assets/images/filter_img2.png"},
      {"name": "VIBE", "image": "assets/images/7.jpg"},
      {"name": "MOOD", "image": "assets/images/8.jpg"},
      {"name": "VINTAGE", "image": "assets/images/9.png"},
      {"name": "SOFT", "image": "assets/images/1.jpg"},
    ],
    "Glitch": [
      {"name": "GLITCH", "image": "assets/images/2.jpg"},
      {"name": "RGB", "image": "assets/images/filter_img3.png"},
      {"name": "SHIFT", "image": "assets/images/5.jpg"},
      {"name": "ERROR", "image": "assets/images/filter_img4.png"},
      {"name": "PIXEL", "image": "assets/images/7.jpg"},
      {"name": "NOISE", "image": "assets/images/8.jpg"},
      {"name": "WARP", "image": "assets/images/9.png"},
    ],
    "Weather": [
      {"name": "SUN", "image": "assets/images/1.jpg"},
      {"name": "WARM", "image": "assets/images/2.jpg"},
      {"name": "COOL", "image": "assets/images/3.jpg"},
      {"name": "FOG", "image": "assets/images/5.jpg"},
      {"name": "RAIN", "image": "assets/images/6.jpg"},
      {"name": "SNOW", "image": "assets/images/7.jpg"},
      {"name": "DUST", "image": "assets/images/8.jpg"},
    ],
    "Vintage": [
      {"name": "VINT", "image": "assets/images/9.png"},
      {"name": "SEPIA", "image": "assets/images/1.jpg"},
      {"name": "RETRO", "image": "assets/images/2.jpg"},
      {"name": "FADE", "image": "assets/images/3.jpg"},
      {"name": "OLD", "image": "assets/images/5.jpg"},
      {"name": "FILM2", "image": "assets/images/6.jpg"},
      {"name": "BROWN", "image": "assets/images/7.jpg"},
    ],
    "Color / Pop": [
      {"name": "POP2", "image": "assets/images/8.jpg"},
      {"name": "BRIGHT", "image": "assets/images/9.png"},
      {"name": "SAT", "image": "assets/images/1.jpg"},
      {"name": "PASTEL", "image": "assets/images/filter_img5.png"},
      {"name": "FRESH", "image": "assets/images/3.jpg"},
      {"name": "BOOST", "image": "assets/images/5.jpg"},
      {"name": "JUICY", "image": "assets/images/6.jpg"},
    ],
    "Moody": [
      {"name": "DARK", "image": "assets/images/7.jpg"},
      {"name": "SHADOW", "image": "assets/images/8.jpg"},
      {"name": "NIGHT", "image": "assets/images/9.png"},
      {"name": "BLUE", "image": "assets/images/1.jpg"},
      {"name": "LOW", "image": "assets/images/2.jpg"},
      {"name": "DEEP", "image": "assets/images/3.jpg"},
      {"name": "SAD", "image": "assets/images/5.jpg"},
    ],
  };

  @override
  void initState() {
    super.initState();
    // Initialize playhead at startPadding initially?
    // We need screen info. We'll set it in build or first frame post-build if needed.
    // Or just default to a safe value.
    // .w depends on ScreenUtil init, usually safe in initState if ScreenUtilInit is up.
    // But safely, let's init to 0 and set it to startPadding in logic if 0.

    // Sync Ruler with Timeline
    timelineScrollController.addListener(() {
      if (!_isUserDragging && !_isAutoScrolling) {
        _lastUserScrollTime = DateTime.now();
      }
    });

    // Initialize segments from input videos
    for (var file in widget.videos) {
      videoSegments.add(
        ClipSegment(
          originalFile: file,
          startOffset: Duration.zero,
          endOffset:
              Duration.zero, // will be updated in _initializeAllDurations
        ),
      );
    }

    _initializeAllDurations();
    if (videoSegments.isNotEmpty) {
      _setCurrentSegment(videoSegments.first, 0, play: false);
    }
  }

  Future<void> _generateThumbnailForOriginal(File videoFile) async {
    if (originalThumbnails.containsKey(videoFile.path) &&
        originalThumbnails[videoFile.path] != null)
      return;

    final uniqueId = videoFile.path.hashCode.abs();
    final out = await _tempFilePath("_thumb_orig_$uniqueId.jpg");
    final cmd =
        '-i "${videoFile.path}" -ss 00:00:01 -vframes 1 -s 160x90 -f image2 "$out"';
    final res = await _runFFmpeg(cmd, out);
    if (res != null) {
      setState(() {
        originalThumbnails[videoFile.path] = File(res);
      });
    }
  }

  Future<void> _generateFilmstripForOriginal(File videoFile) async {
    if (originalFilmstrips.containsKey(videoFile.path) &&
        originalFilmstrips[videoFile.path]!.isNotEmpty)
      return;

    final duration = await _getVideoDuration(videoFile);

    // Dynamic frame count based on duration (1 frame every 2 seconds for caching)
    int totalFrames = (duration.inSeconds / 2.0).ceil();
    if (totalFrames < 5) totalFrames = 5;
    if (totalFrames > 30) totalFrames = 30;

    final interval = duration.inSeconds / totalFrames;

    final dir = await getTemporaryDirectory();
    final uniqueId = videoFile.path.hashCode.abs();
    final thumbDir = Directory("${dir.path}/orig_filmstrip_$uniqueId");

    if (!await thumbDir.exists()) await thumbDir.create(recursive: true);

    final outPattern = "${thumbDir.path}/thumb_%03d.jpg";
    final fps = 1 / (interval > 0 ? interval : 1);

    final cmd =
        '-i "${videoFile.path}" -vf "fps=$fps,scale=120:-1" -vframes $totalFrames "$outPattern"';
    await FFmpegKit.execute(cmd);

    final List<File> thumbs = [];
    for (int i = 1; i <= totalFrames; i++) {
      final f = File(
        "${thumbDir.path}/thumb_${i.toString().padLeft(3, '0')}.jpg",
      );
      if (await f.exists()) thumbs.add(f);
    }

    if (!mounted) return;
    setState(() {
      originalFilmstrips[videoFile.path] = thumbs;
    });
  }

  Future<void> _initializeAllDurations() async {
    for (int i = 0; i < videoSegments.length; i++) {
      final seg = videoSegments[i];
      final file = seg.originalFile;

      Duration d;
      if (originalDurations.containsKey(file.path)) {
        d = originalDurations[file.path]!;
      } else {
        d = await _getVideoDuration(file);
        originalDurations[file.path] = d;
      }

      setState(() {
        // If it's a new segment from picker/init, set its endOffset to the full duration
        if (seg.endOffset == Duration.zero) {
          seg.endOffset = d;
        }
      });

      _generateThumbnailForOriginal(file);
      _generateFilmstripForOriginal(file);
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

  Future<bool> _hasAudio(File file) async {
    try {
      final session = await FFprobeKit.getMediaInformation(file.path);
      final info = session.getMediaInformation();
      if (info == null) return false;
      final streams = info.getStreams();
      for (var stream in streams) {
        if (stream.getType() == "audio") return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error checking audio via ffprobe: $e");
      return false;
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

  Future<void> _setCurrentSegment(
    ClipSegment seg,
    int index, {
    bool play = true,
    Duration? seekTo,
  }) async {
    try {
      final bool sameFile =
          currentSegment?.originalFile.path == seg.originalFile.path;
      currentSegment = seg;
      currentVideoIndex = index;

      if (!sameFile) {
        if (initialized) {
          initialized = false;
          await _controller.pause();
          _controller.removeListener(_videoListener);
          await _controller.dispose();
        }
        _controller = VideoPlayerController.file(seg.originalFile);
        await _controller.initialize();
        _controller.addListener(_videoListener);
        setState(() => initialized = true);
      }

      // Respect segment start point
      final Duration actualSeek = seekTo ?? seg.startOffset;
      await _controller.seekTo(actualSeek);

      if (play) _controller.play();
    } catch (e) {
      debugPrint("Error setting current segment: $e");
      setState(() => initialized = false);
    }
  }

  void _videoListener() {
    if (initialized &&
        _controller.value.isInitialized &&
        currentSegment != null) {
      final pos = _controller.value.position;
      final end = currentSegment!.endOffset;

      if (pos >= end) {
        // Segment finished, play next if available
        if (currentVideoIndex < videoSegments.length - 1) {
          _setCurrentSegment(
            videoSegments[currentVideoIndex + 1],
            currentVideoIndex + 1,
          );
        } else {
          _controller.pause();
          _controller.seekTo(currentSegment!.startOffset);
        }
      }

      if (_controller.value.isPlaying) {
        final timeSinceScroll = DateTime.now()
            .difference(_lastUserScrollTime)
            .inMilliseconds;
        if (timeSinceScroll > 300) {
          _syncScrollWithPlayback();
        }
      }
    }
  }

  void _syncScrollWithPlayback() {
    if (!timelineScrollController.hasClients || currentSegment == null) return;
    if (_playheadOffset == 0) _playheadOffset = startPadding;

    double elapsedMs = 0;
    for (int i = 0; i < currentVideoIndex; i++) {
      elapsedMs += videoSegments[i].duration.inMilliseconds;
    }

    // Position relative to segment start
    final localPos = _controller.value.position - currentSegment!.startOffset;
    elapsedMs += localPos.inMilliseconds.clamp(
      0,
      currentSegment!.duration.inMilliseconds,
    );

    double targetX =
        (elapsedMs / 1000.0) * 50.w - _playheadOffset + startPadding;

    _isAutoScrolling = true;
    timelineScrollController.jumpTo(targetX);
    _isAutoScrolling = false;
  }

  Future<int> _durationSeconds(File f) async {
    // rely on controller for duration when current segment loaded
    if (currentSegment != null &&
        currentSegment!.originalFile.path == f.path &&
        initialized) {
      return _controller.value.duration.inSeconds;
    }
    // fallback: load a temporary controller
    final tmp = VideoPlayerController.file(f);
    await tmp.initialize();
    final dur = tmp.value.duration.inSeconds;
    await tmp.dispose();
    return dur;
  }

  Future<String?> _runFFmpeg(
    String cmd,
    String outputPath, {
    bool wait = true,
  }) async {
    setState(() => statusText = "Running ffmpeg...");
    debugPrint("FFmpeg Executing: $cmd");
    try {
      final session = await FFmpegKit.execute(cmd);

      // Capture detailed logs for debugging
      final logs = await session.getLogs();
      for (var log in logs) {
        debugPrint("[FFMPEG LOG] ${log.getMessage()}");
      }

      final rc = await session.getReturnCode();
      _lastFFmpegRC = rc?.getValue();

      final failStackTrace = await session.getFailStackTrace();
      if (failStackTrace != null) {
        debugPrint("FFmpeg StackTrace: $failStackTrace");
      }

      if (rc != null && rc.isValueSuccess()) {
        return outputPath;
      } else {
        debugPrint(
          "FFmpeg failed with return code $_lastFFmpegRC. Check logs above.",
        );
        return null;
      }
    } catch (e) {
      debugPrint("FFmpeg exception: $e");
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
    final action = _history.removeLast();
    _redoStack.add(action);

    setState(() {
      videoSegments.clear();
      videoSegments.addAll(action.beforeSegments.map((s) => s.copy()));

      final targetIdx = action.affectedIndex ?? currentVideoIndex;
      currentVideoIndex = targetIdx.clamp(0, videoSegments.length - 1);
    });

    await _setCurrentSegment(
      videoSegments[currentVideoIndex],
      currentVideoIndex,
      play: false,
    );
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _history.add(action);

    setState(() {
      videoSegments.clear();
      videoSegments.addAll(action.afterSegments.map((s) => s.copy()));

      final targetIdx = action.affectedIndex ?? currentVideoIndex;
      currentVideoIndex = targetIdx.clamp(0, videoSegments.length - 1);
    });

    await _setCurrentSegment(
      videoSegments[currentVideoIndex],
      currentVideoIndex,
      play: false,
    );
  }

  // Remove a specific history item
  void removeHistoryAt(int index) {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    setState(() {});
  }

  Future<void> pickVideo() async {
    final XFile? x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x != null) {
      final f = File(x.path);
      final dur = await _getVideoDuration(f);

      final newSeg = ClipSegment(
        originalFile: f,
        startOffset: Duration.zero,
        endOffset: dur,
      );

      setState(() {
        videoSegments.add(newSeg);
      });

      originalDurations[f.path] = dur;
      _generateThumbnailForOriginal(f);
      _generateFilmstripForOriginal(f);

      await _setCurrentSegment(newSeg, videoSegments.length - 1, play: false);
    }
  }

  Future<void> removeVideoAt(int index) async {
    if (index < 0 || index >= videoSegments.length) return;

    final removed = videoSegments.removeAt(index);
    if (currentSegment == removed) {
      if (videoSegments.isNotEmpty) {
        _setCurrentSegment(videoSegments.first, 0);
      } else {
        currentSegment = null;
        if (initialized) {
          initialized = false;
          _controller.dispose();
        }
      }
    } else {
      // update current index if we removed something before it
      if (index < currentVideoIndex) {
        currentVideoIndex--;
      }
    }
    setState(() {});
  }

  // --- Basic Editing Functions using FFmpeg ---
  // 1) Trim video
  Future<void> trimVideo({
    required Duration start,
    required Duration end,
  }) async {
    if (currentSegment == null) return;

    final before = videoSegments.map((s) => s.copy()).toList();

    // Non-destructive: just update offsets
    // 'start' and 'end' are relative to the current segment's view
    final newStart = currentSegment!.startOffset + start;
    final newEnd = currentSegment!.startOffset + end;

    setState(() {
      currentSegment!.startOffset = newStart;
      currentSegment!.endOffset = newEnd;
    });

    _pushHistory(
      EditAction(
        type: EditType.trim,
        description: "Trim ${_formatDuration(start)} - ${_formatDuration(end)}",
        beforeSegments: before,
        afterSegments: videoSegments.map((s) => s.copy()).toList(),
        affectedIndex: currentVideoIndex,
      ),
    );

    await _setCurrentSegment(currentSegment!, currentVideoIndex, play: false);
  }

  // 2) Split video at position -> returns pair of paths (part1, part2)
  Future<void> splitVideoAt(int targetIndex, Duration localPos) async {
    if (targetIndex < 0 || targetIndex >= videoSegments.length) return;

    final target = videoSegments[targetIndex];
    final before = videoSegments.map((s) => s.copy()).toList();

    // Calculate split point absolute to original file
    final splitPoint = target.startOffset + localPos;

    // Create segments
    final part1 = target.copy();
    part1.endOffset = splitPoint;

    final part2 = target.copy();
    part2.startOffset = splitPoint;

    setState(() {
      videoSegments[targetIndex] = part1;
      videoSegments.insert(targetIndex + 1, part2);
      currentVideoIndex = targetIndex + 1;
    });

    _pushHistory(
      EditAction(
        type: EditType.split,
        description: "Split at ${_formatDuration(localPos)}",
        beforeSegments: before,
        afterSegments: videoSegments.map((s) => s.copy()).toList(),
        affectedIndex: targetIndex,
      ),
    );

    await _setCurrentSegment(
      videoSegments[currentVideoIndex],
      currentVideoIndex,
      play: false,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Split successful"),
          duration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  // 3) Change speed (speedFactor > 1 faster, <1 slower)

  Future<void> changeSpeed(double speedFactor, {int? index}) async {
    int targetIdx = index ?? currentVideoIndex;
    if (targetIdx < 0 || targetIdx >= videoSegments.length) return;

    final seg = videoSegments[targetIdx];
    final before = videoSegments.map((s) => s.copy()).toList();

    setState(() {
      seg.speed = speedFactor;
    });

    _pushHistory(
      EditAction(
        type: EditType.speed,
        description: "Speed x $speedFactor",
        beforeSegments: before,
        afterSegments: videoSegments.map((s) => s.copy()).toList(),
        affectedIndex: targetIdx,
      ),
    );

    if (targetIdx == currentVideoIndex) {
      await _setCurrentSegment(seg, targetIdx, play: false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Speed applied: ${speedFactor.toStringAsFixed(1)}x"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void applyFilter(int filterIndex, double intensity) {
    if (currentSegment == null) return;

    final before = videoSegments.map((s) => s.copy()).toList();
    final name = _getFilterNameOfIndex(filterIndex);

    setState(() {
      // For now we just update the field, in real CapCut this would change the preview
      // currentSegment!.filter = name; // If we wanted to persist this
    });

    _pushHistory(
      EditAction(
        type: EditType.filter,
        description: "Filter $name applied",
        beforeSegments: before,
        afterSegments: videoSegments.map((s) => s.copy()).toList(),
        affectedIndex: currentVideoIndex,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Filter $name applied (Preview)"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  double interpolation(double start, double end, double t) {
    return start + (end - start) * t;
  }

  List<double> _getInterpolatedFilterMatrix() {
    final List<double> identity = [
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
    ];

    if (_selectedFilterIndex == 0) return identity;

    final target = _getFilterMatrix(_selectedFilterIndex);
    final result = List<double>.filled(20, 0.0);

    for (int i = 0; i < 20; i++) {
      result[i] = identity[i] + (target[i] - identity[i]) * _filterIntensity;
    }

    return result;
  }

  List<double> _getFilterMatrix(int index) {
    final String name = _getFilterNameOfIndex(index);
    switch (name) {
      // --- Trending ---
      case "DUAL":
        return [
          1.2,
          0.1,
          0.1,
          0.0,
          0.0,
          1.2,
          0.1,
          0.1,
          0.0,
          0.0,
          0.1,
          1.1,
          0.1,
          0.0,
          0.0,
          0.1,
          0.1,
          1.5,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "POP":
        return [
          1.5,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.3,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.2,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "NEON":
        return [
          1.5,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.5,
          0.0,
          0.0,
          0.0,
          1.5,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "FILM":
        return [
          0.9,
          0.2,
          0.0,
          0.0,
          0.0,
          0.1,
          0.9,
          0.1,
          0.0,
          0.0,
          0.0,
          0.2,
          0.8,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "GLOW":
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          40.0,
          0.0,
          1.0,
          0.0,
          0.0,
          40.0,
          0.0,
          0.0,
          1.0,
          0.0,
          40.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "VIBE":
        return [
          1.1,
          0.0,
          0.0,
          0.0,
          10.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.9,
          0.0,
          -10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "MOOD":
        return [
          0.9,
          0.0,
          0.0,
          0.0,
          -10.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.1,
          0.0,
          10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "VINTAGE":
      case "VINT":
        return [
          0.393,
          0.769,
          0.189,
          0.0,
          0.0,
          0.349,
          0.686,
          0.168,
          0.0,
          0.0,
          0.272,
          0.534,
          0.131,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "SOFT":
        return [
          1.0,
          0.4,
          0.4,
          0.0,
          0.0,
          0.4,
          1.0,
          0.4,
          0.0,
          0.0,
          0.4,
          0.4,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];

      // --- Glitch ---
      case "GLITCH":
        return [
          -1.0,
          0.0,
          0.0,
          0.0,
          255.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          -1.0,
          0.0,
          255.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "RGB":
        return [
          1.0,
          0.5,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.5,
          0.0,
          0.0,
          0.5,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "SHIFT":
        return [
          1.0,
          0.0,
          0.2,
          0.0,
          0.0,
          0.2,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.2,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "ERROR":
        return [
          -1.0,
          -1.0,
          -1.0,
          0.0,
          255.0,
          -1.0,
          -1.0,
          -1.0,
          0.0,
          255.0,
          -1.0,
          -1.0,
          -1.0,
          0.0,
          255.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "PIXEL":
        return [
          1.0,
          0.2,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.2,
          0.0,
          0.0,
          0.2,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "NOISE":
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          20.0,
          0.0,
          1.0,
          0.0,
          0.0,
          20.0,
          0.0,
          0.0,
          1.0,
          0.0,
          20.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "WARP":
        return [
          1.5,
          -0.5,
          0.0,
          0.0,
          0.0,
          0.0,
          1.5,
          -0.5,
          0.0,
          0.0,
          -0.5,
          0.0,
          1.5,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];

      // --- Weather ---
      case "SUN":
        return [
          1.1,
          0.0,
          0.0,
          0.0,
          30.0,
          0.0,
          1.0,
          0.0,
          0.0,
          20.0,
          0.0,
          0.0,
          0.9,
          0.0,
          -10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "WARM":
        return [
          1.2,
          0.0,
          0.0,
          0.0,
          20.0,
          0.0,
          1.1,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "COOL":
        return [
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          1.2,
          0.0,
          20.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "FOG":
        return [
          0.8,
          0.0,
          0.0,
          0.0,
          50.0,
          0.0,
          0.8,
          0.0,
          0.0,
          50.0,
          0.0,
          0.0,
          0.8,
          0.0,
          50.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "RAIN":
        return [
          0.7,
          0.0,
          0.0,
          0.0,
          10.0,
          0.0,
          0.7,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.9,
          0.0,
          30.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "SNOW":
        return [
          1.2,
          0.0,
          0.0,
          0.0,
          40.0,
          0.0,
          1.2,
          0.0,
          0.0,
          40.0,
          0.0,
          0.0,
          1.3,
          0.0,
          50.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "DUST":
        return [
          1.0,
          0.2,
          0.2,
          0.0,
          10.0,
          0.2,
          1.0,
          0.2,
          0.0,
          10.0,
          0.2,
          0.2,
          0.8,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];

      // --- Vintage ---
      case "SEPIA":
        return [
          0.393,
          0.769,
          0.189,
          0.0,
          0.0,
          0.349,
          0.686,
          0.168,
          0.0,
          0.0,
          0.272,
          0.534,
          0.131,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "RETRO":
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          30.0,
          0.0,
          0.8,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.2,
          0.0,
          -20.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "FADE":
        return [
          0.9,
          0.1,
          0.1,
          0.0,
          20.0,
          0.1,
          0.9,
          0.1,
          0.0,
          20.0,
          0.1,
          0.1,
          0.9,
          0.0,
          20.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "OLD":
        return [
          0.7,
          0.2,
          0.1,
          0.0,
          30.0,
          0.2,
          0.7,
          0.1,
          0.0,
          30.0,
          0.1,
          0.1,
          0.7,
          0.0,
          30.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "FILM2":
        return [
          1.1,
          0.1,
          -0.1,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          -0.1,
          0.1,
          1.1,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "BROWN":
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          30.0,
          0.0,
          0.9,
          0.0,
          0.0,
          15.0,
          0.0,
          0.0,
          0.8,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];

      // --- Color / Pop ---
      case "POP2":
        return [
          1.6,
          -0.1,
          -0.1,
          0.0,
          0.0,
          -0.1,
          1.6,
          -0.1,
          0.0,
          0.0,
          -0.1,
          -0.1,
          1.6,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "BRIGHT":
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          50.0,
          0.0,
          1.0,
          0.0,
          0.0,
          50.0,
          0.0,
          0.0,
          1.0,
          0.0,
          50.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "SAT":
        return [
          1.3,
          -0.15,
          -0.15,
          0.0,
          0.0,
          -0.15,
          1.3,
          -0.15,
          0.0,
          0.0,
          -0.15,
          -0.15,
          1.3,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "PASTEL":
        return [
          0.8,
          0.1,
          0.1,
          0.0,
          60.0,
          0.1,
          0.8,
          0.1,
          0.0,
          60.0,
          0.1,
          0.1,
          0.8,
          0.0,
          60.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "FRESH":
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.2,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          1.2,
          0.0,
          10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "BOOST":
        return [
          1.4,
          0.0,
          0.0,
          0.0,
          -20.0,
          0.0,
          1.4,
          0.0,
          0.0,
          -20.0,
          0.0,
          0.0,
          1.4,
          0.0,
          -20.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "JUICY":
        return [
          1.5,
          0.0,
          0.0,
          0.0,
          20.0,
          0.0,
          1.2,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];

      // --- Moody ---
      case "DARK":
        return [
          0.6,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.6,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.6,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "SHADOW":
        return [
          1.2,
          0.0,
          0.0,
          0.0,
          -50.0,
          0.0,
          1.2,
          0.0,
          0.0,
          -50.0,
          0.0,
          0.0,
          1.2,
          0.0,
          -50.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "NIGHT":
        return [
          0.5,
          0.0,
          0.0,
          0.0,
          -20.0,
          0.0,
          0.5,
          0.0,
          0.0,
          -20.0,
          0.0,
          0.0,
          0.8,
          0.0,
          10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "BLUE":
        return [
          0.7,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.7,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.1,
          0.0,
          30.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "LOW":
        return [
          0.4,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.4,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.4,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "DEEP":
        return [
          1.5,
          0.0,
          0.0,
          0.0,
          -40.0,
          0.0,
          1.5,
          0.0,
          0.0,
          -40.0,
          0.0,
          0.0,
          1.5,
          0.0,
          -40.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case "SAD":
        return [
          0.5,
          0.2,
          0.1,
          0.0,
          -10.0,
          0.1,
          0.5,
          0.1,
          0.0,
          -10.0,
          0.1,
          0.2,
          0.5,
          0.0,
          -10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];

      default:
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
    }
  }

  Future<void> quickTrimUI() async {
    if (currentSegment == null) return;
    final total = _controller.value.duration;
    // show simple dialog with two sliders
    Duration start = Duration.zero;
    Duration end = total;
    await showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (c2, setS) {
            return AlertDialog(
              title: const Text("Trim"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Start: ${_formatDuration(start)}"),
                  Slider(
                    min: 0,
                    max: total.inMilliseconds.toDouble(),
                    value: start.inMilliseconds.toDouble().clamp(
                      0.0,
                      total.inMilliseconds.toDouble(),
                    ),
                    onChanged: (v) =>
                        setS(() => start = Duration(milliseconds: v.toInt())),
                  ),
                  Text("End: ${_formatDuration(end)}"),
                  Slider(
                    min: 0.0,
                    max: total.inMilliseconds.toDouble(),
                    value: end.inMilliseconds.toDouble().clamp(
                      0.0,
                      total.inMilliseconds.toDouble(),
                    ),
                    onChanged: (v) =>
                        setS(() => end = Duration(milliseconds: v.toInt())),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(c);
                    trimVideo(start: start, end: end);
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 6) Crop (x,y,w,h) - expects ints normalized to video resolution
  Future<void> cropVideo({
    required int x,
    required int y,
    required int w,
    required int h,
  }) async {
    if (currentSegment == null) return;
    final beforeSegments = videoSegments.map((s) => s.copy()).toList();
    final beforeFile = currentSegment!.originalFile;
    final out = await _tempFilePath("_crop.mp4");

    int finalW = (w ~/ 2) * 2;
    int finalH = (h ~/ 2) * 2;
    if (finalW < 2) finalW = 2;
    if (finalH < 2) finalH = 2;

    final cmd =
        '-i "${beforeFile.path}" -vf "crop=$finalW:$finalH:$x:$y" -c:v libx264 -c:a aac -pix_fmt yuv420p -preset ultrafast -crf 23 -r 30 -tune fastdecode -g 30 -y "$out"';

    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);

    if (res != null) {
      final afterFile = File(res);
      final dur = await _getVideoDuration(afterFile);

      setState(() {
        currentSegment!.originalFile = afterFile;
        // Since it's a new baked file, reset offsets
        currentSegment!.startOffset = Duration.zero;
        currentSegment!.endOffset = dur;
      });

      _pushHistory(
        EditAction(
          type: EditType.crop,
          description: "Crop $finalW x $finalH @($x,$y)",
          beforeSegments: beforeSegments,
          afterSegments: videoSegments.map((s) => s.copy()).toList(),
          affectedIndex: currentVideoIndex,
        ),
      );

      originalDurations[afterFile.path] = dur;
      _generateThumbnailForOriginal(afterFile);
      _generateFilmstripForOriginal(afterFile);

      await _setCurrentSegment(currentSegment!, currentVideoIndex, play: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Crop applied successfully")),
        );
      }
    }
  }

  // 7) Add audio (mix)
  Future<void> addAudioLayer(File audioFile, {double volume = 1.0}) async {
    if (currentSegment == null) return;
    final beforeSegments = videoSegments.map((s) => s.copy()).toList();
    final beforeFile = currentSegment!.originalFile;
    final out = await _tempFilePath("_addaudio.mp4");

    final bool hasOriginalAudio = await _hasAudio(beforeFile);

    String cmd;
    if (hasOriginalAudio) {
      cmd =
          '-i "${beforeFile.path}" -i "${audioFile.path}" -filter_complex "[1:a]volume=$volume[a1];[0:a][a1]amix=inputs=2:duration=first:dropout_transition=2[aout]" -map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 128k -y "$out"';
    } else {
      cmd =
          '-i "${beforeFile.path}" -i "${audioFile.path}" -filter_complex "[1:a]volume=$volume[aout]" -map 0:v -map "[aout]" -shortest -c:v copy -c:a aac -b:a 128k -y "$out"';
    }

    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      final dur = await _getVideoDuration(afterFile);

      _pushHistory(
        EditAction(
          type: EditType.addAudio,
          description: "Add audio ${audioFile.path.split('/').last}",
          beforeSegments: beforeSegments,
          afterSegments: videoSegments.map((s) => s.copy()).toList(),
          affectedIndex: currentVideoIndex,
        ),
      );

      setState(() {
        currentSegment!.originalFile = afterFile;
        currentSegment!.startOffset = Duration.zero;
        currentSegment!.endOffset = dur;
        originalDurations[afterFile.path] = dur;
      });
      await _setCurrentSegment(currentSegment!, currentVideoIndex, play: false);
    }
  }

  Future<void> pickAndAddAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        File audioFile = File(result.files.single.path!);
        await addAudioLayer(audioFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Audio layer added successfully!")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking audio: $e");
    }
  }

  // 8) Background remove (simple chroma-key: remove green)
  Future<void> removeBackground({String keyColor = "0x00FF00"}) async {
    // keyColor should be hex color for chromakey; ffmpeg chromakey filter uses color names or hex like 0xRRGGBB
    if (currentSegment == null) return;
    final beforeSegments = videoSegments.map((s) => s.copy()).toList();
    final before = currentSegment!.originalFile;
    final out = await _tempFilePath("_bgremoved.mp4");
    // using "chromakey" video filter: chromakey=color:similarity:blend
    // similarity 0.1..0.6, blend 0..1 - tune in UI for better results
    final cmd =
        '-i "${before.path}" -vf "chromakey=${keyColor}:0.25:0.0,format=rgba" -c:a copy "$out"';
    setState(() => isExporting = true);
    final res = await _runFFmpeg(cmd, out);
    setState(() => isExporting = false);
    if (res != null) {
      final afterFile = File(res);
      final dur = await _getVideoDuration(afterFile);

      setState(() {
        currentSegment!.originalFile = afterFile;
        currentSegment!.startOffset = Duration.zero;
        currentSegment!.endOffset = dur;
      });

      _pushHistory(
        EditAction(
          type: EditType.bgRemove,
          description: "Background removed (chroma key $keyColor)",
          beforeSegments: beforeSegments,
          afterSegments: videoSegments.map((s) => s.copy()).toList(),
          affectedIndex: currentVideoIndex,
        ),
      );

      originalDurations[afterFile.path] = dur;
      _generateThumbnailForOriginal(afterFile);
      _generateFilmstripForOriginal(afterFile);

      await _setCurrentSegment(currentSegment!, currentVideoIndex);
    }
  }

  // 9) Overlay text (canvas)
  void overlayText(String text) {
    if (currentSegment == null) return;
    // Simple placeholder
  }

  void _rotateCurrentClip() {
    if (currentSegment == null) return;
    setState(() {
      currentSegment!.rotation = (currentSegment!.rotation + 90) % 360;
    });

    _pushHistory(
      EditAction(
        type: EditType.crop,
        description: "Rotated clip to ${currentSegment!.rotation}°",
        beforeSegments: videoSegments.map((s) => s.copy()).toList(),
        afterSegments: videoSegments.map((s) => s.copy()).toList(),
        affectedIndex: currentVideoIndex,
      ),
    );
  }

  void _showRatioSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Canvas / Ratio",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            SizedBox(height: 20.h),
            Wrap(
              spacing: 15.w,
              runSpacing: 15.h,
              children: [
                _ratioTile("9:16", 9 / 16, Icons.portrait),
                _ratioTile("16:9", 16 / 9, Icons.landscape),
                _ratioTile("1:1", 1.0, Icons.crop_square),
                _ratioTile("4:5", 0.8, Icons.stay_current_portrait),
                _ratioTile("3:4", 0.75, Icons.stay_current_portrait),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _ratioTile(String label, double ratio, IconData icon) {
    bool isSelected = (projectAspectRatio - ratio).abs() < 0.01;
    return GestureDetector(
      onTap: () {
        setState(() => projectAspectRatio = ratio);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black54,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? Colors.blue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 10) Save/export all clips as one video to Gallery
  Future<void> exportAndSaveVideo() async {
    if (videoSegments.isEmpty) return;

    setState(() {
      isExporting = true;
      statusText = "Processing final video...";
    });

    try {
      final out = await _tempFilePath("_final_export.mp4");

      // We'll use filter_complex to trim and concat all segments
      // This is the most accurate way.
      // Example: [0:v]trim=start=1:end=5,setpts=PTS-STARTPTS[v0]; [0:a]atrim=start=1:end=5,asetpts=PTS-STARTPTS[a0]; ... concat=n=2:v=1:a=1[outv][outa]

      final StringBuffer inputs = StringBuffer();
      final StringBuffer filter = StringBuffer();
      final StringBuffer concatInput = StringBuffer();

      for (int i = 0; i < videoSegments.length; i++) {
        final seg = videoSegments[i];
        inputs.write('-i "${seg.originalFile.path}" ');

        final hasAudio = await _hasAudio(seg.originalFile);
        final start = seg.startOffset.inMilliseconds / 1000.0;
        final end = seg.endOffset.inMilliseconds / 1000.0;

        // --- Video Filter ---
        filter.write('[$i:v]trim=start=$start:end=$end,setpts=PTS-STARTPTS');
        if (seg.speed != 1.0) {
          filter.write(',setpts=PTS/${seg.speed}');
        }
        // Normalized scale and pad for mixed aspect ratios (540p for faster upload)
        filter.write(
          ',scale=w=540:h=960:force_original_aspect_ratio=decrease,pad=540:960:(540-iw)/2:(960-ih)/2,setsar=1,fps=30[v$i]; ',
        );

        // --- Audio Filter ---
        if (hasAudio) {
          filter.write(
            '[$i:a]atrim=start=$start:end=$end,asetpts=PTS-STARTPTS',
          );
          if (seg.speed != 1.0) {
            filter.write(',atempo=${seg.speed}');
          }
          filter.write(
            ',aformat=sample_rates=44100:channel_layouts=stereo[a$i]; ',
          );
        } else {
          double durSec =
              (seg.endOffset - seg.startOffset).inMilliseconds /
              1000.0 /
              seg.speed;
          if (durSec <= 0) durSec = 0.1; // Guard against zero duration
          filter.write('anullsrc=r=44100:cl=stereo:d=$durSec[a$i]; ');
        }

        // Add to concat sequence in order: [v0][a0][v1][a1]...
        concatInput.write('[v$i][a$i]');
      }

      filter.write(
        '${concatInput.toString()}concat=n=${videoSegments.length}:v=1:a=1[outv][outa]',
      );

      final cmd =
          '${inputs.toString()}-filter_complex "${filter.toString()}" -map "[outv]" -map "[outa]" -c:v libx264 -preset superfast -b:v 2M -maxrate 2M -bufsize 4M -pix_fmt yuv420p -vsync cfr -c:a aac -b:a 128k -async 1 -y "$out"';

      final res = await _runFFmpeg(cmd, out);
      if (res == null) throw Exception("Export failed at FFmpeg stage");

      // Set mediaPath in controller
      if (Get.isRegistered<ContentCreationController>()) {
        Get.find<ContentCreationController>().mediaPath.value = res;
      }

      if (mounted) {
        if (initialized) {
          initialized = false;
          _controller.removeListener(_videoListener);
          _controller.pause();
          _controller.dispose();
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AiVideoEditPage(videoFile: File(res)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Export error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isExporting = false;
        statusText = "";
      });
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

        // Toggle timeline/speed/filter visibility
        if (!_isFiltering && !_isSpeeding && !_isCropping) ...[
          // Default View: Control Bar + Timeline + Save
          _buildControlBar(),
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
        ],

        _buildBottomActionBar(), // This now handles internal visibility of Filter, Speed, and Crop sheets
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
                if (!_isFiltering && !_isSpeeding && !_isCropping) ...[
                  _buildControlBar(),
                  Container(
                    color: const Color(0xFFE1D5FF),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: _buildTimelineSection(),
                  ),
                ],
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
                if (!_isFiltering && !_isSpeeding && !_isCropping)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                        ),
                      ),
                      child: _buildClipListView(isLandscape: true),
                    ),
                  )
                else
                  const Spacer(),

                // Editing tools (Handles internal Filter, Speed, Crop sheets)
                _buildLandscapeTools(),

                // Save Button (Only if not in specialized mode to save vertical space in landscape)
                if (!_isFiltering && !_isSpeeding && !_isCropping)
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
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.r,
                color: Colors.black,
              ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isCropping) const SizedBox.shrink(),

        if (_isSpeeding) _buildSpeedControlBar(),

        if (_isFiltering) _buildFilterBottomSheet(),

        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          color: Colors.transparent,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _actionIcon(
                  Icons.crop_free_rounded,
                  "Canvas",
                  onTap: () async {
                    final txt = await _inputDialog(
                      "Canvas text",
                      "Enter overlay text",
                    );
                    if (txt != null && txt.trim().isNotEmpty)
                      overlayText(txt.trim());
                  },
                ),
                _actionIcon(
                  Icons.layers_clear_rounded,
                  "BG",
                  onTap: () => removeBackground(),
                ),
                _actionIcon(
                  Icons.content_cut_rounded,
                  "Trim",
                  onTap: () => _deleteSelectedClip(),
                ),
                _actionCustomIcon(
                  "assets/images/split_icon.png",
                  "Split",
                  onTap: () async {
                    if (initialized) {
                      await splitVideoAt(
                        currentVideoIndex,
                        _controller.value.position,
                      );
                    }
                  },
                ),
                _actionIcon(
                  Icons.crop_rounded,
                  "Crop",
                  onTap: () {
                    setState(() {
                      _isCropping = !_isCropping;
                      if (_isCropping) {
                        _isFiltering = false;
                        _isSpeeding = false;
                        _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
                      }
                    });
                  },
                  isActive: _isCropping,
                ),
                _actionIcon(
                  Icons.speed_rounded,
                  "Speed",
                  onTap: () {
                    setState(() {
                      _isSpeeding = !_isSpeeding;
                      if (_isSpeeding) {
                        _isFiltering = false;
                        _isCropping = false;
                        int idx = selectedClipIndex ?? currentVideoIndex;
                        if (idx >= 0 && idx < videoSegments.length) {
                          _tempSpeed = videoSegments[idx].speed;
                        } else {
                          _tempSpeed = 1.0;
                        }
                      }
                    });
                  },
                  isActive: _isSpeeding,
                ),
                _actionIcon(
                  Icons.auto_awesome_motion_rounded,
                  "Filter",
                  onTap: () {
                    setState(() {
                      _isFiltering = !_isFiltering;
                      if (_isFiltering) {
                        _isCropping = false;
                        _isSpeeding = false;
                        _initialFilterIndex = _selectedFilterIndex;
                        _initialFilterIntensity = _filterIntensity;
                      }
                    });
                  },
                  isActive: _isFiltering,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection() {
    return Container(
      constraints: BoxConstraints(minHeight: 95.h), // Reduced from 120.h
      color: const Color(0xFFF8E9D2), // Cream background for header and clips
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 5.h,
            ), // Tightened from 10.h
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
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20.r,
                      color: Colors.black,
                    ),
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
                // Save Button
                GestureDetector(
                  onTap: exportAndSaveVideo,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFACAAAA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      size: 20.r,
                      color: Colors.black,
                    ),
                  ),
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
      height: isLandscape ? null : 65.h, // Reduced from 80.h
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: Colors.transparent, // Inherit background from parent
      child: videoSegments.isEmpty
          ? const Center(
              child: Text(
                "No videos confirmed",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ReorderableListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: videoSegments.length,
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        final double animValue = Curves.easeInOut.transform(
                          animation.value,
                        );
                        final double scale = ui.lerpDouble(1, 1.05, animValue)!;
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: child,
                    );
                  },
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }

                  final before = videoSegments.map((s) => s.copy()).toList();
                  final item = videoSegments.removeAt(oldIndex);
                  videoSegments.insert(newIndex, item);

                  // Update current index if the moved item was current or if it shifted the current item
                  if (currentVideoIndex == oldIndex) {
                    currentVideoIndex = newIndex;
                  } else if (oldIndex < currentVideoIndex &&
                      newIndex >= currentVideoIndex) {
                    currentVideoIndex--;
                  } else if (oldIndex > currentVideoIndex &&
                      newIndex <= currentVideoIndex) {
                    currentVideoIndex++;
                  }

                  _pushHistory(
                    EditAction(
                      type: EditType.merged, // Reuse or add Enum for reorder
                      description: "Clips reordered",
                      beforeSegments: before,
                      afterSegments: videoSegments
                          .map((s) => s.copy())
                          .toList(),
                      affectedIndex: newIndex,
                    ),
                  );
                });
              },
              itemBuilder: (context, i) {
                final seg = videoSegments[i];
                final thumb = originalThumbnails[seg.originalFile.path];
                return Center(
                  key: ValueKey(seg.hashCode ^ i),
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _setCurrentSegment(seg, i, play: false);
                          },
                          child: Container(
                            width: isLandscape ? 120.w : 85.w,
                            height: isLandscape ? 70.h : 45.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: currentSegment == seg
                                  ? Border.all(color: Colors.blue, width: 2.w)
                                  : null,
                              image: (thumb != null)
                                  ? DecorationImage(
                                      image: FileImage(thumb),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: (thumb != null) ? null : Colors.grey[300],
                            ),
                            child: (thumb != null)
                                ? null
                                : const Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.white54,
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
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 10.r,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
            if (currentSegment != null &&
                initialized &&
                _controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: projectAspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .black, // Background for the chosen canvas ratio
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: (currentSegment!.rotation / 90).round(),
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Stack(
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.matrix(
                                  _getInterpolatedFilterMatrix(),
                                ),
                                child: VideoPlayer(_controller),
                              ),
                              if (_isCropping) _buildCropOverlay(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Fullscreen icon (hide when cropping)
            if (!_isCropping)
              Positioned(
                bottom: 8.h,
                right: 12.w,
                child: Icon(Icons.fullscreen, color: Colors.white, size: 20.r),
              ),

            if (isExporting) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildCropOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Convert normalized _cropRect to pixels
        final rect = Rect.fromLTWH(
          _cropRect.left * w,
          _cropRect.top * h,
          _cropRect.width * w,
          _cropRect.height * h,
        );

        return Stack(
          children: [
            // 1. Darkened areas outside the crop rect
            GestureDetector(
              onPanUpdate: (details) {
                // Move the whole rect
                setState(() {
                  double dx = details.delta.dx / w;
                  double dy = details.delta.dy / h;
                  _cropRect = Rect.fromLTWH(
                    (_cropRect.left + dx).clamp(0.0, 1.0 - _cropRect.width),
                    (_cropRect.top + dy).clamp(0.0, 1.0 - _cropRect.height),
                    _cropRect.width,
                    _cropRect.height,
                  );
                });
              },
              child: CustomPaint(size: Size(w, h), painter: CropPainter(rect)),
            ),

            // 2. Corner Handles
            _buildCropHandle(
              rect.topLeft,
              (d) => _updateCropRect(d, w, h, isTop: true, isLeft: true),
            ),
            _buildCropHandle(
              rect.topRight,
              (d) => _updateCropRect(d, w, h, isTop: true, isLeft: false),
            ),
            _buildCropHandle(
              rect.bottomLeft,
              (d) => _updateCropRect(d, w, h, isTop: false, isLeft: true),
            ),
            _buildCropHandle(
              rect.bottomRight,
              (d) => _updateCropRect(d, w, h, isTop: false, isLeft: false),
            ),
          ],
        );
      },
    );
  }

  void _updateCropRect(
    Offset delta,
    double w,
    double h, {
    required bool isTop,
    required bool isLeft,
  }) {
    setState(() {
      double dx = delta.dx / w;
      double dy = delta.dy / h;

      double left = _cropRect.left;
      double top = _cropRect.top;
      double width = _cropRect.width;
      double height = _cropRect.height;

      if (isLeft) {
        double newLeft = (left + dx).clamp(0.0, left + width - 0.1);
        width += (left - newLeft);
        left = newLeft;
      } else {
        width = (width + dx).clamp(0.1, 1.0 - left);
      }

      if (isTop) {
        double newTop = (top + dy).clamp(0.0, top + height - 0.1);
        height += (top - newTop);
        top = newTop;
      } else {
        height = (height + dy).clamp(0.1, 1.0 - top);
      }

      _cropRect = Rect.fromLTWH(left, top, width, height);
    });
  }

  Widget _buildCropHandle(Offset pos, Function(Offset) onDrag) {
    return Positioned(
      left: pos.dx - 15,
      top: pos.dy - 15,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          width: 30,
          height: 30,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
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
                icon: Icon(
                  Icons.undo_rounded,
                  color: Colors.black54,
                  size: 24.r,
                ),
                onPressed: _history.isNotEmpty ? () => undo() : null,
              ),
              IconButton(
                icon: Icon(
                  Icons.redo_rounded,
                  color: Colors.black54,
                  size: 24.r,
                ),
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
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              }
            },
          ),
          TextButton(
            onPressed: isExporting ? null : exportAndSaveVideo,
            child: Text(
              "SAVE",
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
    int totalMs = videoSegments.fold<int>(
      0,
      (p, c) => p + c.duration.inMilliseconds,
    );
    String totalTimeStr = _formatDuration(Duration(milliseconds: totalMs));

    // We need the screen width to calculate spacers
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = screenWidth / 2;

    return Column(
      children: [
        // Total Time / Current Time Header (Static + Scrolling Ruler)
        Container(
          color: const Color(0xFFF4E1C8),
          padding: EdgeInsets.symmetric(
            vertical: 5.h,
          ), // Removed horizontal padding to manage manually
          child: Column(
            children: [
              // 1. Time Display
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<void>(
                      stream: Stream.periodic(
                        const Duration(milliseconds: 100),
                      ),
                      builder: (context, snapshot) {
                        int current = 0;
                        if (initialized && currentSegment != null) {
                          int preDuration = 0;
                          for (int i = 0; i < currentVideoIndex; i++)
                            preDuration +=
                                videoSegments[i].duration.inMilliseconds;
                          final localPos =
                              _controller.value.position -
                              currentSegment!.startOffset;
                          current = preDuration + localPos.inMilliseconds;
                        }
                        return Text(
                          "${_formatDuration(Duration(milliseconds: current))} / $totalTimeStr",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),

              // 2. Synchronized Scrollable Ruler
              SizedBox(
                height: 15.h,
                child: SingleChildScrollView(
                  controller: _rulerScrollController,
                  scrollDirection: Axis.horizontal,
                  physics:
                      const NeverScrollableScrollPhysics(), // Scroll driven by timeline only
                  child: Row(
                    children: [
                      // Offset calculation:
                      // Timeline starts after Cover Button.
                      // Cover Button Area: 20.w (Left Margin) + 50.w (Width) + 10.w (Right Margin) = 80.w
                      // Inside Timeline: 7.w (startPadding).
                      // Total from Left Edge: 87.w.
                      // This ScrollView is full width.
                      SizedBox(width: 87.w),

                      // Ticks (Same scale as video: 50.w = 1 sec)
                      // We show ticks every 2s (100.w)
                      Row(
                        children: List.generate(((totalMs / 2000).ceil() + 2), (
                          index,
                        ) {
                          return Container(
                            width: 100.w,
                            alignment: Alignment.topLeft,
                            child: Text(
                              _formatDuration(Duration(seconds: index * 2)),
                              style: TextStyle(
                                color: const Color(0xFF9D9DA1),
                                fontSize: 10.sp,
                              ),
                            ),
                          );
                        }),
                      ),

                      // End Padding matching layout builder
                      // We don't have constraints here easily, relying on content width.
                      // Add extra buffer.
                      SizedBox(width: 500.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h), // Reduced from 8.h
        // TIMELINE TRACK (Row: Fixed Cover + Expanded Stack)
        SizedBox(
          height: 100.h, // Reduced from 130.h
          child: Row(
            children: [
              // 1. Fixed "Cover" Button (Left Side)
              GestureDetector(
                onTap: () async {
                  if (initialized && currentSegment != null) {
                    final out = await _tempFilePath("_cover.jpg");
                    final pos = _controller.value.position.inSeconds;
                    // Extract frame at current position
                    final cmd =
                        '-i "${currentSegment!.originalFile.path}" -ss $pos -vframes 1 "$out"';
                    setState(() => isExporting = true);
                    final res = await _runFFmpeg(cmd, out);
                    setState(() => isExporting = false);
                    if (res != null) {
                      setState(() {
                        coverImage = File(res);
                      });
                    }
                  }
                },
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  margin: EdgeInsets.only(left: 20.w, right: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.white, width: 1),
                    image: coverImage != null
                        ? DecorationImage(
                            image: FileImage(coverImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: coverImage != null ? null : Colors.grey[300],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          child: Text(
                            "COVER",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Timeline Stack (Expanded)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (_playheadOffset == 0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted)
                          setState(() => _playheadOffset = startPadding);
                      });
                    }

                    final double endPadding = constraints.maxWidth;

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. Scrollable Content (Video + Music)
                        NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollUpdateNotification) {
                              if (_isAutoScrolling) return true;

                              _lastUserScrollTime = DateTime.now();

                              if (videoSegments.isNotEmpty) {
                                final offset = notification.metrics.pixels;

                                double pixelDist =
                                    offset + _playheadOffset - startPadding;
                                if (pixelDist < 0) pixelDist = 0;

                                final double seconds = pixelDist / 50.w;
                                final int targetTotalMs = (seconds * 1000)
                                    .toInt();

                                // Seek Logic
                                int accumulated = 0;
                                for (int i = 0; i < videoSegments.length; i++) {
                                  int dur =
                                      videoSegments[i].duration.inMilliseconds;
                                  if (targetTotalMs <= accumulated + dur) {
                                    int localMs = targetTotalMs - accumulated;
                                    final absoluteMs =
                                        videoSegments[i]
                                            .startOffset
                                            .inMilliseconds +
                                        localMs;

                                    if (currentVideoIndex != i) {
                                      _setCurrentSegment(
                                        videoSegments[i],
                                        i,
                                        play: false,
                                        seekTo: Duration(
                                          milliseconds: absoluteMs,
                                        ),
                                      );
                                    } else {
                                      _controller.seekTo(
                                        Duration(milliseconds: absoluteMs),
                                      );
                                    }
                                    break;
                                  }
                                  accumulated += dur;
                                }
                              }
                            }
                            return true;
                          },
                          child: SingleChildScrollView(
                            controller: timelineScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Video Strip
                                Row(
                                  children: [
                                    SizedBox(width: startPadding),
                                    for (
                                      int i = 0;
                                      i < videoSegments.length;
                                      i++
                                    )
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => selectedClipIndex = i);
                                        },
                                        child: Container(
                                          width:
                                              (videoSegments[i]
                                                      .duration
                                                      .inMilliseconds /
                                                  1000) *
                                              50.w,
                                          height: 50.h,
                                          decoration: BoxDecoration(
                                            border: i == selectedClipIndex
                                                ? Border.all(
                                                    color: Colors.cyanAccent,
                                                    width: 2.5.w,
                                                  )
                                                : Border.all(
                                                    color: Colors.white24,
                                                    width: 0.5.w,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                            color: Colors.black38,
                                          ),
                                          child: Stack(
                                            children: [
                                              // Filmstrip Content (Clipped to segment window)
                                              if (originalFilmstrips
                                                  .containsKey(
                                                    videoSegments[i]
                                                        .originalFile
                                                        .path,
                                                  ))
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                  child: LayoutBuilder(
                                                    builder: (context, box) {
                                                      final allThumbs =
                                                          originalFilmstrips[videoSegments[i]
                                                              .originalFile
                                                              .path]!;
                                                      final origDur =
                                                          originalDurations[videoSegments[i]
                                                              .originalFile
                                                              .path]!;

                                                      // Calculate which thumbs fall within [startOffset, endOffset]
                                                      final startPct =
                                                          videoSegments[i]
                                                              .startOffset
                                                              .inMilliseconds /
                                                          origDur
                                                              .inMilliseconds;
                                                      // final endPct = videoSegments[i].endOffset.inMilliseconds / origDur.inMilliseconds;

                                                      // Better: Show all thumbs but offset/scale the container
                                                      final segmentDurPct =
                                                          (videoSegments[i]
                                                                      .endOffset -
                                                                  videoSegments[i]
                                                                      .startOffset)
                                                              .inMilliseconds /
                                                          origDur
                                                              .inMilliseconds;

                                                      return SizedBox(
                                                        width: box.maxWidth,
                                                        height: box.maxHeight,
                                                        child: OverflowBox(
                                                          maxWidth:
                                                              box.maxWidth /
                                                              segmentDurPct,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Transform.translate(
                                                            offset: Offset(
                                                              -(box.maxWidth /
                                                                      segmentDurPct) *
                                                                  startPct,
                                                              0,
                                                            ),
                                                            child: Row(
                                                              children: allThumbs
                                                                  .map(
                                                                    (
                                                                      f,
                                                                    ) => Expanded(
                                                                      child: Image.file(
                                                                        f,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            double.infinity,
                                                                        cacheWidth:
                                                                            80,
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              else
                                                const Center(
                                                  child: Icon(
                                                    Icons.movie,
                                                    color: Colors.white54,
                                                    size: 16,
                                                  ),
                                                ),

                                              // Left Handle (Selected Only)
                                              if (i == selectedClipIndex)
                                                Positioned(
                                                  left: 0,
                                                  top: 6.h,
                                                  bottom: 6.h,
                                                  child: Container(
                                                    width: 4.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.cyanAccent,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                  4.r,
                                                                ),
                                                            bottomRight:
                                                                Radius.circular(
                                                                  4.r,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),

                                              // Right Handle (Selected Only)
                                              if (i == selectedClipIndex)
                                                Positioned(
                                                  right: 0,
                                                  top: 6.h,
                                                  bottom: 6.h,
                                                  child: Container(
                                                    width: 4.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.cyanAccent,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                  4.r,
                                                                ),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  4.r,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),

                                              // Title / Action Overlay can go here
                                            ],
                                          ),
                                        ),
                                      ),
                                    SizedBox(width: endPadding),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                // Music Track
                                Row(
                                  children: [
                                    SizedBox(width: startPadding),
                                    GestureDetector(
                                      onTap: pickAndAddAudio,
                                      child: Container(
                                        width: (totalMs / 1000) * 50.w,
                                        height: 25.h,
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            5.r,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8.w),
                                            Icon(
                                              Icons.music_note,
                                              size: 12.r,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5.w),
                                            Text(
                                              "Add music",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: endPadding),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Playhead (Draggable)
                        Positioned(
                          left: _playheadOffset - 10.w, // Hitbox padding
                          child: GestureDetector(
                            onHorizontalDragStart: (details) {
                              // Pause for smooth scrubbing
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              }
                            },
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                _playheadOffset += details.delta.dx;
                                // Clamp
                                if (_playheadOffset < startPadding)
                                  _playheadOffset = startPadding;
                                if (_playheadOffset >
                                    constraints.maxWidth - 20.w)
                                  _playheadOffset = constraints.maxWidth - 20.w;
                              });

                              // Seek Video on Drag
                              // Same logic as scroll update
                              if (videoSegments.isNotEmpty) {
                                double offset =
                                    timelineScrollController.hasClients
                                    ? timelineScrollController.offset
                                    : 0;
                                double pixelDist =
                                    offset + _playheadOffset - startPadding;
                                if (pixelDist < 0) pixelDist = 0;

                                final double seconds = pixelDist / 50.w;
                                final int targetTotalMs = (seconds * 1000)
                                    .toInt();

                                int accumulated = 0;
                                for (int i = 0; i < videoSegments.length; i++) {
                                  int dur =
                                      videoSegments[i].duration.inMilliseconds;
                                  if (targetTotalMs <= accumulated + dur) {
                                    int localMs = targetTotalMs - accumulated;
                                    final absoluteMs =
                                        videoSegments[i]
                                            .startOffset
                                            .inMilliseconds +
                                        localMs;

                                    if (currentVideoIndex != i) {
                                      _setCurrentSegment(
                                        videoSegments[i],
                                        i,
                                        play: false,
                                        seekTo: Duration(
                                          milliseconds: absoluteMs,
                                        ),
                                      );
                                    } else {
                                      _controller.seekTo(
                                        Duration(milliseconds: absoluteMs),
                                      );
                                    }
                                    break;
                                  }
                                  accumulated += dur;
                                }
                              }
                            },
                            child: Container(
                              color: Colors.transparent, // Hitbox
                              width: 20.w, // Wider touch area
                              height:
                                  100.h, // Reduced from 130.h to match track
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  // Vertical Line
                                  Container(
                                    width: 1.5.w, // Slightly thinner line
                                    height: double.infinity,
                                    color:
                                        Colors.black, // Dark line as per image
                                  ),
                                  // Handle Head
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      width: 12.w,
                                      height: 12.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          2.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.5.w,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 2.w,
                                          height: 4.h,
                                          color: Colors
                                              .transparent, // Empty center
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
          onPressed: isExporting ? null : exportAndSaveVideo,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0080FF), // Bright blue
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
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
    if (idx < 0 || idx >= videoSegments.length) return;

    if (videoSegments.length <= 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot delete the only clip")),
        );
      }
      return;
    }

    setState(() {
      videoSegments.removeAt(idx);

      if (idx < currentVideoIndex) {
        currentVideoIndex--;
      }
      if (currentVideoIndex >= videoSegments.length) {
        currentVideoIndex = videoSegments.length - 1;
      }

      selectedClipIndex = null;
    });

    await _setCurrentSegment(
      videoSegments[currentVideoIndex],
      currentVideoIndex,
      play: false,
    );
  }

  Widget _buildBottomActionBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isCropping)
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isCropping = false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black54, fontSize: 16.sp),
                  ),
                ),
                Text(
                  "Crop Video",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final size = _controller.value.size;
                    int x = (_cropRect.left * size.width).toInt();
                    int y = (_cropRect.top * size.height).toInt();
                    int w = (_cropRect.width * size.width).toInt();
                    int h = (_cropRect.height * size.height).toInt();

                    setState(() => _isCropping = false);
                    await cropVideo(x: x, y: y, w: w, h: h);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Done"),
                ),
              ],
            ),
          ),

        if (_isSpeeding) _buildSpeedControlBar(),

        if (_isFiltering) _buildFilterBottomSheet(),

        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _actionIcon(
                  Icons.crop_free_rounded,
                  "Canvas",
                  onTap: () => _showRatioSelector(),
                ),
                _actionIcon(
                  Icons.rotate_right_rounded,
                  "Rotate",
                  onTap: () => _rotateCurrentClip(),
                ),
                _actionIcon(
                  Icons.layers_clear_rounded,
                  "BG",
                  onTap: () => removeBackground(),
                ),
                _actionIcon(
                  Icons.content_cut_rounded,
                  "Trim",
                  onTap: () => _deleteSelectedClip(),
                ),
                _actionCustomIcon(
                  "assets/images/split_icon.png",
                  "Split",
                  onTap: () async {
                    if (initialized) {
                      await splitVideoAt(
                        currentVideoIndex,
                        _controller.value.position,
                      );
                    }
                  },
                ),
                _actionIcon(
                  Icons.crop_rounded,
                  "Crop",
                  onTap: () {
                    setState(() {
                      _isCropping = !_isCropping;
                      if (_isCropping) {
                        _isFiltering = false;
                        _isSpeeding = false;
                        _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
                      }
                    });
                  },
                  isActive: _isCropping,
                ),
                _actionIcon(
                  Icons.speed_rounded,
                  "Speed",
                  onTap: () {
                    setState(() {
                      _isSpeeding = !_isSpeeding;
                      if (_isSpeeding) {
                        _isFiltering = false;
                        _isCropping = false;
                        int idx = selectedClipIndex ?? currentVideoIndex;
                        if (idx >= 0 && idx < videoSegments.length) {
                          _tempSpeed = videoSegments[idx].speed;
                        } else {
                          _tempSpeed = 1.0;
                        }
                      }
                    });
                  },
                  isActive: _isSpeeding,
                ),
                _actionIcon(
                  Icons.auto_awesome_motion_rounded,
                  "Filter",
                  onTap: () {
                    setState(() {
                      _isFiltering = !_isFiltering;
                      if (_isFiltering) {
                        _isCropping = false;
                        _isSpeeding = false;
                        _initialFilterIndex = _selectedFilterIndex;
                        _initialFilterIntensity = _filterIntensity;
                      }
                    });
                  },
                  isActive: _isFiltering,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedControlBar() {
    final int idx = selectedClipIndex ?? currentVideoIndex;
    final double originalDuration = (idx >= 0 && idx < videoSegments.length)
        ? videoSegments[idx].duration.inMilliseconds / 1000.0
        : 0.0;
    final double curSpeed = (idx >= 0 && idx < videoSegments.length)
        ? videoSegments[idx].speed
        : 1.0;
    final double newDuration = originalDuration / (_tempSpeed / curSpeed);

    final backgroundColor = const Color(
      0xFFE5DAFB,
    ); // Matched with Filter Sheet
    final headerColor = const Color(0xFFF0D6B1); // Matched with Filter Header
    final accentColor = Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Matched with Filter Header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black54, size: 24.r),
                  onPressed: () {
                    setState(() => _isSpeeding = false);
                    if (initialized) _controller.setPlaybackSpeed(1.0);
                  },
                ),
                Text(
                  "Speed",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check, color: Colors.black54, size: 24.r),
                  onPressed: () async {
                    int idx = selectedClipIndex ?? currentVideoIndex;
                    setState(() => _isSpeeding = false);
                    if (initialized) _controller.setPlaybackSpeed(1.0);
                    await changeSpeed(_tempSpeed, index: idx);
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Duration ${originalDuration.toStringAsFixed(1)}s",
                      style: TextStyle(
                        color: accentColor.withOpacity(0.7),
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.sp,
                      color: accentColor.withOpacity(0.7),
                    ),
                    Text(
                      " ${newDuration.toStringAsFixed(1)}s",
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: CustomPaint(
                          painter: SpeedRulerPainter(color: accentColor),
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 0,
                        thumbColor: Colors.transparent,
                        overlayColor: Colors.black12,
                        thumbShape: _CustomSliderThumbShape(color: accentColor),
                      ),
                      child: Slider(
                        min: 0.1,
                        max: 10.0,
                        value: _tempSpeed,
                        onChanged: (v) {
                          setState(() {
                            _tempSpeed = v;
                          });
                          if (initialized) {
                            _controller
                                .setPlaybackSpeed(v)
                                .catchError(
                                  (e) => debugPrint("Player speed error: $e"),
                                );
                            if (!_controller.value.isPlaying)
                              _controller.play();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _markerLabel("0.1x"),
                      _markerLabel("1x"),
                      _markerLabel("2x"),
                      _markerLabel("5x"),
                      _markerLabel("10x"),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Make it smoother",
                    style: TextStyle(
                      color: accentColor.withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5DAFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterHeader(),
          SizedBox(height: 12.h), // Reduced from 20
          _buildFilterCategories(),
          SizedBox(height: 12.h), // Reduced from 20
          _buildFilterPreviews(),
          SizedBox(height: 16.h), // Reduced from 30
          _buildFilterIntensitySlider(),
          SizedBox(height: 16.h), // Reduced from 30
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0D6B1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black54, size: 24.r),
            onPressed: () {
              // Restore initial state (Cancel)
              setState(() {
                _selectedFilterIndex = _initialFilterIndex;
                _filterIntensity = _initialFilterIntensity;
                _isFiltering = false;
              });
            },
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Colors.black54,
                  size: 24.r,
                ),
                onPressed: () {
                  setState(() {
                    _filterIntensity = 0.5;
                    _selectedFilterIndex = 0;
                  });
                },
              ),
              SizedBox(width: 8.w),
              Text(
                "Filter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.check, color: Colors.black54, size: 24.r),
            onPressed: () {
              applyFilter(_selectedFilterIndex, _filterIntensity);
              setState(() => _isFiltering = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: _filterCategories.keys.map((cat) {
          bool isSelected = _selectedFilterCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterCategory = cat),
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Column(
                children: [
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF2D78)
                          : Colors.black54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      width: 24.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D78),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterPreviews() {
    final filters = _filterCategories[_selectedFilterCategory] ?? [];

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final String filterName = filter["name"];
          bool isSelected =
              _getFilterNameOfIndex(_selectedFilterIndex) == filterName;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = _getIndexOfFilterName(filterName);
              });
            },
            child: Container(
              width: 80.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: isSelected
                    ? Border.all(
                        color: const ui.Color(0xFF007AFF),
                        width: 2.w,
                      ) // Blue selection as in image
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(filter["image"], fit: BoxFit.cover),
                    ),
                    // Apply preview filter to the image icon if possible, but the asset itself represents the filter.
                    // For better UX, we'll put a semi-transparent label at the bottom.
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          filterName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to map names to a global index for the simple matrix logic
  int _getIndexOfFilterName(String name) {
    const allFilters = [
      "NONE",
      "DUAL",
      "POP",
      "NEON",
      "FILM",
      "GLOW",
      "VIBE",
      "MOOD",
      "VINTAGE",
      "SOFT",
      "GLITCH",
      "RGB",
      "SHIFT",
      "ERROR",
      "PIXEL",
      "NOISE",
      "WARP",
      "SUN",
      "WARM",
      "COOL",
      "FOG",
      "RAIN",
      "SNOW",
      "DUST",
      "VINT",
      "SEPIA",
      "RETRO",
      "FADE",
      "OLD",
      "FILM2",
      "BROWN",
      "POP2",
      "BRIGHT",
      "SAT",
      "PASTEL",
      "FRESH",
      "BOOST",
      "JUICY",
      "DARK",
      "SHADOW",
      "NIGHT",
      "BLUE",
      "LOW",
      "DEEP",
      "SAD",
    ];
    return allFilters.indexOf(name).clamp(0, allFilters.length - 1);
  }

  String _getFilterNameOfIndex(int index) {
    const allFilters = [
      "NONE",
      "DUAL",
      "POP",
      "NEON",
      "FILM",
      "GLOW",
      "VIBE",
      "MOOD",
      "VINTAGE",
      "SOFT",
      "GLITCH",
      "RGB",
      "SHIFT",
      "ERROR",
      "PIXEL",
      "NOISE",
      "WARP",
      "SUN",
      "WARM",
      "COOL",
      "FOG",
      "RAIN",
      "SNOW",
      "DUST",
      "VINT",
      "SEPIA",
      "RETRO",
      "FADE",
      "OLD",
      "FILM2",
      "BROWN",
      "POP2",
      "BRIGHT",
      "SAT",
      "PASTEL",
      "FRESH",
      "BOOST",
      "JUICY",
      "DARK",
      "SHADOW",
      "NIGHT",
      "BLUE",
      "LOW",
      "DEEP",
      "SAD",
    ];
    if (index >= 0 && index < allFilters.length) return allFilters[index];
    return "NONE";
  }

  Widget _buildFilterIntensitySlider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.h,
                activeTrackColor: const Color(0xFFFF2D78),
                inactiveTrackColor: Colors.white,
                thumbColor: const Color(0xFFFF2D78),
                overlayColor: const Color(0xFFFF2D78).withOpacity(0.2),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: Slider(
                value: _filterIntensity,
                onChanged: (v) => setState(() => _filterIntensity = v),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            "${(_filterIntensity * 100).toInt()}%",
            style: TextStyle(
              color: const Color(0xFFFF2D78),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _markerLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.black,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _speedTab(String label, {required bool isActive}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
            fontSize: 14.sp,
          ),
        ),
        if (isActive)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            width: 20.w,
            height: 2.h,
            color: Colors.black,
          ),
      ],
    );
  }

  Widget _actionCustomIcon(
    String assetPath,
    String label, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            Image.asset(
              assetPath,
              width: 24.r,
              height: 24.r,
              color: isActive ? Colors.black : Colors.black54,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: isActive ? Colors.black : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.black : Colors.black54,
              size: 24.r,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: isActive ? Colors.black : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, val),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<List<int>?> _cropDialog() async {
    int x = 0,
        y = 0,
        w = (_controller.value.size.width ~/ 1).toInt(),
        h = (_controller.value.size.height ~/ 1).toInt();
    return showDialog<List<int>>(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (c2, setS) {
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
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(c, [x, y, w, h]),
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<double?> _speedDialog() async {
    double val = 1.0;
    return showDialog<double>(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (c2, setS) {
            return AlertDialog(
              title: const Text("Speed"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    min: 0.25,
                    max: 4.0,
                    value: val,
                    onChanged: (v) => setS(() => val = v),
                  ),
                  Text("x ${val.toStringAsFixed(2)}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(c, val),
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
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
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, "grayscale"),
              child: const Text("Grayscale"),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, "sepia"),
              child: const Text("Sepia"),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, "negate"),
              child: const Text("Negate"),
            ),
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

class SpeedRulerPainter extends CustomPainter {
  final Color color;
  SpeedRulerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final double startX = 0;
    final double endX = size.width;
    final int tickCount = 40;
    final double step = (endX - startX) / tickCount;

    for (int i = 0; i <= tickCount; i++) {
      double x = startX + i * step;
      double height = 6.0;

      // Longer ticks for major intervals
      if (i % 8 == 0) {
        height = 12.0;
        paint.color = color.withOpacity(0.6);
      } else {
        height = 6.0;
        paint.color = color.withOpacity(0.3);
      }

      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final Color color;
  _CustomSliderThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

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
    final canvas = context.canvas;

    final outerPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a cyan-style hollow circle from the image
    canvas.drawCircle(center, 8, outerPaint);
    // Add small inner shadow or dot if needed, but the image shows a ring
  }
}

class CropPainter extends CustomPainter {
  final Rect rect;
  CropPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final hole = rect;

    // Draw 4 rectangles around the hole to darken the non-cropped area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, hole.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        hole.bottom,
        size.width,
        (size.height - hole.bottom).clamp(0, size.height),
      ),
      paint,
    );
    canvas.drawRect(Rect.fromLTWH(0, hole.top, hole.left, hole.height), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        hole.right,
        hole.top,
        (size.width - hole.right).clamp(0, size.width),
        hole.height,
      ),
      paint,
    );

    // Draw white border for the crop area
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(hole, borderPaint);

    // Draw corner accents
    final accentPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const double L = 15;
    // Top-left
    canvas.drawLine(
      hole.topLeft,
      hole.topLeft + const Offset(L, 0),
      accentPaint,
    );
    canvas.drawLine(
      hole.topLeft,
      hole.topLeft + const Offset(0, L),
      accentPaint,
    );
    // Top-right
    canvas.drawLine(
      hole.topRight,
      hole.topRight + const Offset(-L, 0),
      accentPaint,
    );
    canvas.drawLine(
      hole.topRight,
      hole.topRight + const Offset(0, L),
      accentPaint,
    );
    // Bottom-left
    canvas.drawLine(
      hole.bottomLeft,
      hole.bottomLeft + const Offset(L, 0),
      accentPaint,
    );
    canvas.drawLine(
      hole.bottomLeft,
      hole.bottomLeft + const Offset(0, -L),
      accentPaint,
    );
    // Bottom-right
    canvas.drawLine(
      hole.bottomRight,
      hole.bottomRight + const Offset(-L, 0),
      accentPaint,
    );
    canvas.drawLine(
      hole.bottomRight,
      hole.bottomRight + const Offset(0, -L),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(CropPainter old) => old.rect != rect;
}
