import 'dart:async';
import 'dart:io';
import 'package:clip_frame/photo_edit.dart';
import 'package:clip_frame/video_edit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFmpegKit Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Edit: Video & Photo (FFmpegKit)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.movie),
              label: Text('Video Edit'),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => VideoEditorPage())),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.photo),
              label: Text('Photo Edit'),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PhotoEditorPage())),
            ),
          ],
        ),
      ),
    );
  }
}
