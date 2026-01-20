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
import 'package:permission_handler/permission_handler.dart';

class PhotoEditorPage extends StatefulWidget {
  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  img_picker.XFile? _pickedImage;
  String? _editedImagePath;
  bool _isProcessing = false;
  String? _appliedFilter; // Track the last applied filter
  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  final MediaStore _mediaStore = MediaStore();
  Timer? _debounce; // For debouncing slider changes

  // Slider values for adjustments
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _highlights = 0;
  double _shadows = 0;
  double _temperature = 0;

  @override
  void initState() {
    super.initState();
    _initializeMediaStore();
  }

  Future<void> _initializeMediaStore() async {
    try {
      if (Platform.isAndroid) {
        await MediaStore.ensureInitialized();
        MediaStore.appFolder = "MediaEditorApp";
        final permissions = [
          Permission.storage,
          if ((await _mediaStore.getPlatformSDKInt()) >= 33)
            ...[Permission.photos, Permission.videos]
        ];
        final status = await permissions.request();
        if (status.values.any((s) => !s.isGranted)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required permissions denied. Please grant permissions in settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo library permission denied. Please grant permissions in settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize permissions: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(source: img_picker.ImageSource.gallery);
      if (file != null) {
        setState(() {
          _pickedImage = file;
          _editedImagePath = null;
          _appliedFilter = null;
          // Reset sliders
          _brightness = 0;
          _contrast = 0;
          _saturation = 0;
          _highlights = 0;
          _shadows = 0;
          _temperature = 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
      print("$e");
    }
  }

  Future<String> _tmpFilePath(String filename) async {
    final dir = await getTemporaryDirectory();
    return p.join(dir.path, filename);
  }

  Future<void> _runFFmpeg(String command, String filterName, String outputPath) async {
    setState(() => _isProcessing = true);
    final completer = Completer<FFmpegSession?>();
    FFmpegKit.executeAsync(command, (session) async {
      completer.complete(session);
    });
    final session = await completer.future;
    final returnCode = await session?.getReturnCode();
    setState(() => _isProcessing = false);

    if (ReturnCode.isSuccess(returnCode)) {
      setState(() {
        _editedImagePath = outputPath;
        _appliedFilter = filterName;
      });
    } else {
      final rc = returnCode?.getValue();
      final logs = await session?.getAllLogsAsString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FFmpeg failed — rc=$rc\nLogs: $logs')),
      );
      print('FFmpeg failed — rc=$rc\nLogs: $logs');
    }
  }

  Future<void> _applyFilter(String filterType) async {
    if (_pickedImage == null) return;
    // Use the edited image as input if it exists; otherwise, use the original image
    final inputPath = _editedImagePath ?? _pickedImage!.path;
    final outputPath = await _tmpFilePath('${filterType}_${p.basename(inputPath)}');
    String cmd;

    switch (filterType) {
      case 'grayscale':
        cmd = "-y -i '$inputPath' -vf format=gray '$outputPath'";
        break;
      case 'sepia':
        cmd = "-y -i '$inputPath' -vf colorchannelmixer=.3:.4:.3:0:.3:.4:.3:0:.3:.4:.3 '$outputPath'";
        break;
      case 'blur':
        cmd = "-y -i '$inputPath' -vf boxblur=5:1 '$outputPath'";
        break;
      case 'brightness':
        final value = (_brightness / 100).clamp(-1.0, 1.0); // Scale -100 to 100 -> -1 to 1
        cmd = "-y -i '$inputPath' -vf eq=brightness=$value '$outputPath'";
        break;
      case 'contrast':
        final value = (_contrast / 100 * 2).clamp(0.0, 2.0); // Scale -100 to 100 -> 0 to 2
        cmd = "-y -i '$inputPath' -vf eq=contrast=$value '$outputPath'";
        break;
      case 'saturation':
        final value = (_saturation / 100 * 2).clamp(0.0, 2.0); // Scale -100 to 100 -> 0 to 2
        cmd = "-y -i '$inputPath' -vf eq=saturation=$value '$outputPath'";
        break;
      case 'highlights':
        final value = (_highlights / 100).clamp(-1.0, 1.0); // Scale -100 to 100 -> -1 to 1
        cmd = "-y -i '$inputPath' -vf eq=gamma=$value '$outputPath'";
        print("$outputPath");
        break;
      case 'shadows':
        final value = (_shadows / 100).clamp(-1.0, 1.0); // Scale -100 to 100 -> -1 to 1
        cmd = "-y -i '$inputPath' -vf curves=psfile='0/0 ${value.abs()}/1' '$outputPath'";
        print("$outputPath");
        break;
      case 'temperature':
        final value = 2000 + (_temperature / 100 * 8000).clamp(-8000, 8000); // Scale -100 to 100 -> 2000 to 10000K
        cmd = "-y -i '$inputPath' -vf colortemperature=$value '$outputPath'";
        print("$outputPath");
        break;
      default:
        return;
    }

    await _runFFmpeg(cmd, filterType, outputPath);
  }

  Future<void> _applyFilterWithDebounce(String filterType) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _applyFilter(filterType));
  }

  Future<void> _saveToGallery() async {
    if (_editedImagePath == null) return;
    setState(() => _isProcessing = true);
    try {
      final tempFilePath = await _tmpFilePath('saved_${p.basename(_editedImagePath!)}');
      await File(_editedImagePath!).copy(tempFilePath);

      if (Platform.isAndroid) {
        await _mediaStore.saveFile(
          tempFilePath: tempFilePath,
          dirType: DirType.photo,
          dirName: DirName.dcim,
        );
      } else if (Platform.isIOS) {
        // For iOS, use gallery_saver or native integration
        // await GallerySaver.saveImage(tempFilePath);
      }

      await File(tempFilePath).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _undoEdit() {
    setState(() {
      _editedImagePath = null;
      _appliedFilter = null;
      // Reset sliders
      _brightness = 0;
      _contrast = 0;
      _saturation = 0;
      _highlights = 0;
      _shadows = 0;
      _temperature = 0;
    });
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value,
          min: -100,
          max: 100,
          divisions: 200,
          onChanged: _isProcessing ? null : onChanged,
          label: value.toStringAsFixed(0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Editor')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick Image'),
                  onPressed: _isProcessing ? null : _pickImage,
                ),
                const SizedBox(height: 20),
                if (_pickedImage != null) ...[
                  const Text('Original Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Image.file(File(_pickedImage!.path), height: 200, fit: BoxFit.contain),
                  const SizedBox(height: 20),
                  const Text('Basic Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _applyFilter('grayscale'),
                        child: _isProcessing && _appliedFilter == 'grayscale'
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Grayscale'),
                      ),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _applyFilter('sepia'),
                        child: _isProcessing && _appliedFilter == 'sepia'
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sepia'),
                      ),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _applyFilter('blur'),
                        child: _isProcessing && _appliedFilter == 'blur'
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Blur'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Adjustments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildSlider('Brightness', _brightness, (value) {
                    setState(() => _brightness = value);
                    _applyFilterWithDebounce('brightness');
                  }),
                  _buildSlider('Contrast', _contrast, (value) {
                    setState(() => _contrast = value);
                    _applyFilterWithDebounce('contrast');
                  }),
                  _buildSlider('Saturation', _saturation, (value) {
                    setState(() => _saturation = value);
                    _applyFilterWithDebounce('saturation');
                  }),
                  _buildSlider('Highlights', _highlights, (value) {
                    setState(() => _highlights = value);
                    _applyFilterWithDebounce('highlights');
                  }),
                  _buildSlider('Shadows', _shadows, (value) {
                    setState(() => _shadows = value);
                    _applyFilterWithDebounce('shadows');
                  }),
                  _buildSlider('Temperature', _temperature, (value) {
                    setState(() => _temperature = value);
                    _applyFilterWithDebounce('temperature');
                  }),
                ],
                if (_editedImagePath != null) ...[
                  const SizedBox(height: 20),
                  const Text('Edited Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Image.file(File(_editedImagePath!), height: 200, fit: BoxFit.contain),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _saveToGallery,
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save to Gallery'),
                      ),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _undoEdit,
                        child: const Text('Undo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Applied Filter: ${_appliedFilter ?? "None"}'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}