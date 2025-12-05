import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 20),

                // Horizontal list of videos (thumbnails) with remove X
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: videoList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final f = videoList[i];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _setCurrentFile(f),
                            child: Container(
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  "Video ${i + 1}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => removeVideoAt(i),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Main video player area and controls
                if (currentFile != null && initialized)
                  Expanded(
                    child: Column(
                      children: [
                        // Video player
                        Container(
                          height: 100,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Controls row: undo redo play/pause Done
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.undo),
                                  onPressed: _history.isNotEmpty ? () => undo() : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.redo),
                                  onPressed: _redoStack.isNotEmpty ? () => redo() : null,
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                                  onPressed: () {
                                    setState(() {
                                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // Done button behaviour: could finalize or move to next step
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Done pressed")));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBC894),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text("Done", style: TextStyle(color: Colors.black87)),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Timeline scale UI: shows video duration & zoom slider
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("00:00", style: const TextStyle(fontSize: 12)),
                                Text(_controller.value.duration != null ? _formatDuration(_controller.value.duration) : "00:00", style: const TextStyle(fontSize: 12)),
                              ],
                            ),

                            Row(
                              children: [
                                const Text("Zoom:"),
                                Expanded(
                                  child: Slider(
                                    min: 0.5,
                                    max: 3.0,
                                    value: timelineScale,
                                    onChanged: (v) => setState(() => timelineScale = v),
                                  ),
                                )
                              ],
                            ),

                            // Simple "one by one" video list (thumbnails scaled by timelineScale)
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 1, // for now only current file; extend for timeline layers
                                itemBuilder: (c, idx) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    width: 120 * timelineScale,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(child: Text("Clip")),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Add Video / Add Audio Layer Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final XFile? x = await _picker.pickVideo(source: ImageSource.gallery);
                                    if (x != null) {
                                      final f = File(x.path);
                                      // For simplicity, we will append/merge new video to current using concat (requires same codec)
                                      // A real editor would create a timeline entry. Here we push a merged output.
                                      if (currentFile == null) return;
                                      final out = await _tempFilePath("_merged.mp4");
                                      final listFile = await _tempFilePath("_concat.txt");
                                      // create a concat list
                                      final concatList = "file '${currentFile!.path}'\nfile '${f.path}'\n";
                                      await File(listFile).writeAsString(concatList);
                                      final cmd = '-f concat -safe 0 -i "$listFile" -c copy "$out"';
                                      setState(() => isExporting = true);
                                      final res = await _runFFmpeg(cmd, out);
                                      setState(() => isExporting = false);
                                      if (res != null) {
                                        final afterFile = File(res);
                                        _pushHistory(EditAction(type: EditType.merged, description: "Merged with another video", beforePath: currentFile!.path, afterPath: afterFile.path));
                                        await _setCurrentFile(afterFile);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.video_library),
                                  label: const Text("Add Video"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final XFile? x = await _picker.pickVideo(source: ImageSource.gallery);
                                    // We accept audio as video for demo; for real app use audio picker
                                    if (x != null) {
                                      await addAudioLayer(File(x.path));
                                    }
                                  },
                                  icon: const Icon(Icons.audiotrack),
                                  label: const Text("Add Audio"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Cover selection and Save
                        Row(
                          children: [
                            // cover image change (for demo, choose a frame time)
                            ElevatedButton(
                              onPressed: () async {
                                if (currentFile == null) return;
                                final frameTime = Duration(seconds: (_controller.value.duration.inSeconds ~/ 2));
                                final out = await _tempFilePath("_cover.jpg");
                                final cmd = '-ss ${frameTime.inSeconds} -i "${currentFile!.path}" -frames:v 1 "$out"';
                                setState(() => isExporting = true);
                                final res = await _runFFmpeg(cmd, out);
                                setState(() => isExporting = false);
                                if (res != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cover saved: $res")));
                                }
                              },
                              child: const Text("Change Cover"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: saveCurrentToGallery,
                              child: const Text("Save"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Tools container (horizontal scroll of tool items)
                        Container(
                          height: 92,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _toolTile(Icons.brush, "Canvas", onTap: () async {
                                // simple overlay text prompt
                                final txt = await _inputDialog("Canvas text", "Enter overlay text");
                                if (txt != null && txt.trim().isNotEmpty) overlayText(txt.trim());
                              }),
                              _toolTile(Icons.image_not_supported, "BG_remove", onTap: () {
                                // use default green key
                                removeBackground(keyColor: "0x00FF00");
                              }),
                              _toolTile(Icons.cut, "Trim", onTap: () => quickTrimUI()),
                              _toolTile(Icons.content_cut, "Split", onTap: () async {
                                // simple split at half
                                final dur = _controller.value.duration;
                                final at = Duration(seconds: dur.inSeconds ~/ 2);
                                await splitVideoAt(at);
                              }),
                              _toolTile(Icons.crop, "Crop", onTap: () async {
                                // show dialog to enter crop values
                                final crop = await _cropDialog();
                                if (crop != null) await cropVideo(x: crop[0], y: crop[1], w: crop[2], h: crop[3]);
                              }),
                              _toolTile(Icons.speed, "Speed", onTap: () async {
                                // speed selection dialog
                                final v = await _speedDialog();
                                if (v != null) await changeSpeed(v);
                              }),
                              _toolTile(Icons.filter, "Filter", onTap: () async {
                                final choice = await _filterChoiceDialog();
                                if (choice != null) await applyFilter(choice);
                              }),
                            ],
                          ),
                        ),

                        // History list preview with remove/undo per-item
                        const SizedBox(height: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Edit History", style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _history.length,
                                  itemBuilder: (c, idx) {
                                    final h = _history[idx];
                                    return ListTile(
                                      title: Text(h.description),
                                      subtitle: Text(DateFormat('HH:mm:ss').format(h.timestamp)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.restore_from_trash),
                                            onPressed: () => removeHistoryAt(idx),
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        // tap history to revert to that point (set current file to that afterPath)
                                        final f = File(h.afterPath);
                                        if (await f.exists()) {
                                          await _setCurrentFile(f);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File missing")));
                                        }
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                // no video loaded placeholder
                  Expanded(
                    child: Center(
                      child: Text(videoList.isEmpty ? "No videos. Add one." : "Loading..."),
                    ),
                  ),

                // status & spinner
                if (isExporting) ...[
                  const SizedBox(height: 8),
                  Center(child: Column(children: const [CircularProgressIndicator(), SizedBox(height: 6)])),
                ],
                if (statusText.isNotEmpty) Text(statusText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----- small UI helpers -----
  Widget _toolTile(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
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

