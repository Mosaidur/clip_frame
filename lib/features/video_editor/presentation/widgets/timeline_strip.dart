import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:clip_frame/core/services/native_video_service.dart';
import 'package:clip_frame/features/video_editor/domain/timeline_model.dart';

class TimelineStrip extends StatefulWidget {
  final TimelineClip clip;
  final double pixelsPerSecond;
  final double height;
  final NativeVideoService videoService;

  const TimelineStrip({
    Key? key,
    required this.clip,
    required this.pixelsPerSecond,
    this.height = 60.0,
    required this.videoService,
  }) : super(key: key);

  @override
  _TimelineStripState createState() => _TimelineStripState();
}

class _TimelineStripState extends State<TimelineStrip> {
  // Cache at widget level for reused widgets
  final Map<int, Uint8List?> _thumbnailCache = {};

  @override
  Widget build(BuildContext context) {
    // Calculate total width based on duration
    final double width = widget.clip.duration.inSeconds * widget.pixelsPerSecond;
    // How many thumbnails do we need? 
    // Assume each thumbnail is ~height wide (square-ish aspect for calculation)
    final int thumbCount = (width / widget.height).ceil();
    final double thumbWidth = width / thumbCount;

    return Container(
      height: widget.height,
      width: width,
      decoration: BoxDecoration(
        border: widget.clip.isSelected ? Border.all(color: Colors.white, width: 2) : null,
        color: Colors.black12,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Managed by parent scroll
        itemCount: thumbCount,
        itemBuilder: (context, index) {
          // Calculate time for this specific block
          // Start time + (index * duration_per_block)
          final int timeOffsetMs = ((widget.clip.sourceStartTime.inMilliseconds) + 
              (index * (widget.clip.duration.inMilliseconds / thumbCount))).toInt();

          return Container(
            width: thumbWidth,
            height: widget.height,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.black26, width: 0.5)),
            ),
            child: FutureBuilder<Uint8List?>(
              future: _getThumbnail(timeOffsetMs),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  );
                }
                return Container(color: Colors.grey[900]);
              },
            ),
          );
        },
      ),
    );
  }

  Future<Uint8List?> _getThumbnail(int timeMs) async {
    if (_thumbnailCache.containsKey(timeMs)) {
      return _thumbnailCache[timeMs];
    }
    final data = await widget.videoService.getThumbnail(widget.clip.videoPath, timeMs);
    if (mounted && data != null) {
      // Small optimization: don't setState, just cache. 
      // The FutureBuilder will handle the redraw when future completes.
      _thumbnailCache[timeMs] = data;
    }
    return data;
  }
}
