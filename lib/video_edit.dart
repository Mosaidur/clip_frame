
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';



final mediaStorePlugin = MediaStore();

class VideoEditorPage extends StatefulWidget {
  @override
  _VideoEditorPageState createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  img_picker.XFile? _pickedVideo;
  String? _lastOutputPath;
  bool _isProcessing = false;
  final img_picker.ImagePicker _picker = img_picker.ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeMediaStore();
  }

  Future<void> _initializeMediaStore() async {
    if (Platform.isAndroid) {
      await MediaStore.ensureInitialized();
      MediaStore.appFolder = "MediaStorePlugin";
    }
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: img_picker.ImageSource.gallery);
    if (file != null) setState(() => _pickedVideo = file);
  }

  Future<String> _persistentFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, filename);
  }

  Future<void> _runFFmpeg(
      String command, BuildContext context, String outputPath) async {
    setState(() => _isProcessing = true);
    final completer = Completer<FFmpegSession?>();

    FFmpegKit.executeAsync(command, (session) {
      completer.complete(session);
    });

    final session = await completer.future;
    final returnCode = await session?.getReturnCode();
    setState(() => _isProcessing = false);

    if (ReturnCode.isSuccess(returnCode)) {
      try {
        // Save video using media_store_plus
        await mediaStorePlugin.saveFile(
          tempFilePath: outputPath,
          dirType: DirType.video,
          dirName: DirName.movies,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Video saved to gallery')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save video: $e')));
      }
    } else {
      final rc = returnCode?.getValue();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('FFmpeg failed — rc=$rc')));
    }
  }

  Future<void> _trimFirst10Seconds() async {
    if (_pickedVideo == null) return;
    final inputPath = _pickedVideo!.path;
    final outputPath = await _persistentFilePath('trimmed_${p.basename(inputPath)}');
    final cmd = "-y -i '$inputPath' -ss 0 -t 10 -c copy '$outputPath'";
    await _runFFmpeg(cmd, context, outputPath);
    setState(() => _lastOutputPath = outputPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Editor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Pick Video'),
              onPressed: _isProcessing ? null : _pickVideo,
            ),
            const SizedBox(height: 20),
            if (_pickedVideo != null)
              ElevatedButton(
                onPressed: _isProcessing ? null : _trimFirst10Seconds,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Trim first 10s'),
              ),
            if (_lastOutputPath != null) ...[
              const SizedBox(height: 20),
              Text('Last output: $_lastOutputPath'),
            ]
          ],
        ),
      ),
    );
  }
}


