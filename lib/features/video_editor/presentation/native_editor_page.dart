import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:clip_frame/core/services/native_video_service.dart';
import 'package:clip_frame/features/video_editor/domain/timeline_model.dart';
import 'package:clip_frame/features/video_editor/presentation/widgets/timeline_strip.dart';
import 'package:image_picker/image_picker.dart';

class NativeEditorPage extends StatefulWidget {
  const NativeEditorPage({Key? key}) : super(key: key);

  @override
  _NativeEditorPageState createState() => _NativeEditorPageState();
}

class _NativeEditorPageState extends State<NativeEditorPage> {
  final NativeVideoService _videoService = NativeVideoService();
  final ScrollController _scrollController = ScrollController();
  
  List<TimelineClip> _clips = [];
  bool _isReady = false;
  double _pixelsPerSecond = 50.0; // Zoom level

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    await _videoService.initialize();
    setState(() => _isReady = true);
  }

  Future<void> _pickAndAddVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    
    if (file != null) {
      final int durationMs = await _videoService.loadVideo(file.path);
      
      final newClip = TimelineClip(
        id: const Uuid().v4(),
        videoPath: file.path,
        sourceStartTime: Duration.zero,
        sourceEndTime: Duration(milliseconds: durationMs),
      );

      setState(() {
        _clips.add(newClip);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("NaviCut Pro"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: _pickAndAddVideo, icon: const Icon(Icons.add_circle)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.save_alt)),
        ],
      ),
      body: Column(
        children: [
          // 1. Preview Area (Placeholder for Native SurfaceView if we get there, using Flutter Image for now)
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text("Preview Player (Native Surface)", style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
          
          // 2. Toolbar
          Container(
            height: 50,
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.cut, color: Colors.white), onPressed: () {}),
                IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),

          // 3. Timeline Area
          SizedBox(
            height: 150,
            child: GestureDetector(
              onScaleUpdate: (details) {
                 // Zoom logic: modify _pixelsPerSecond
                 setState(() {
                   _pixelsPerSecond = (_pixelsPerSecond * details.scale).clamp(10.0, 200.0);
                 });
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Padding start
                     SizedBox(width: MediaQuery.of(context).size.width / 2),
                    
                    ..._clips.map((clip) => TimelineStrip(
                      clip: clip, 
                      pixelsPerSecond: _pixelsPerSecond,
                      videoService: _videoService,
                    )).toList(),

                    // Padding end
                    SizedBox(width: MediaQuery.of(context).size.width / 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
