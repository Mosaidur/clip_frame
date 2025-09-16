

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaDisplayWidget extends StatefulWidget {
  final String videoUrl;
  const MediaDisplayWidget({super.key, required this.videoUrl});

  @override
  State<MediaDisplayWidget> createState() => _MediaDisplayWidgetState();
}

class _MediaDisplayWidgetState extends State<MediaDisplayWidget> {
  late VideoPlayerController _controller;
  bool _isControlsVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _skipForward() {
    final newPosition = _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(newPosition);
  }

  void _skipBackward() {
    final newPosition = _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _isControlsVisible = !_isControlsVisible;
      }),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Video
          _controller.value.isInitialized
              ? SizedBox.expand(
                child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
                            ),
                          ),
              )
              : const Center(child: CircularProgressIndicator()),

          /// Controls Overlay
          if (_isControlsVisible && _controller.value.isInitialized)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Play / Pause / Skip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                          onPressed: _skipBackward,
                        ),
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 60,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                          onPressed: _skipForward,
                        ),
                      ],
                    ),

                    /// Slider
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        final position = value.position;
                        final duration = value.duration;

                        return Column(
                          children: [
                            Slider(
                              activeColor: Colors.pink,
                              inactiveColor: Colors.white54,
                              min: 0,
                              max: duration.inMilliseconds.toDouble(),
                              value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                              onChanged: (v) {
                                _controller.seekTo(Duration(milliseconds: v.toInt()));
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
