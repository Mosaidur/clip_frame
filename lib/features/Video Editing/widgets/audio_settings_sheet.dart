import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/video_music_controller.dart';

class AudioSettingsSheet extends StatefulWidget {
  const AudioSettingsSheet({super.key});

  @override
  State<AudioSettingsSheet> createState() => _AudioSettingsSheetState();
}

class _AudioSettingsSheetState extends State<AudioSettingsSheet> {
  final VideoMusicController controller = Get.find<VideoMusicController>();
  late double _volume;
  late RangeValues _trimRange;
  late bool _loop;

  @override
  void initState() {
    super.initState();
    final track = controller.currentTrack.value!;
    _volume = track.volume;
    _trimRange = RangeValues(
      track.trimStart.inMilliseconds.toDouble(),
      track.trimEnd.inMilliseconds.toDouble(),
    );
    _loop = track.loop;
  }

  @override
  Widget build(BuildContext context) {
    final track = controller.currentTrack.value!;
    final double maxDurationMs = track.totalDuration.inMilliseconds.toDouble();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  track.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  controller.removeMusic();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Divider(height: 30),

          // VOLUME SLIDER
          Text(
            "Volume",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Row(
            children: [
              const Icon(Icons.volume_mute, size: 18, color: Colors.grey),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (val) {
                    setState(() => _volume = val);
                    controller.updateVolume(val);
                  },
                ),
              ),
              const Icon(Icons.volume_up, size: 18, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 20),

          // TRIMMER
          Text(
            "Trim Music (Start - End)",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          RangeSlider(
            values: _trimRange,
            min: 0,
            max: maxDurationMs,
            divisions: maxDurationMs > 0 ? maxDurationMs ~/ 100 : 1,
            labels: RangeLabels(
              _formatMs(_trimRange.start.toInt()),
              _formatMs(_trimRange.end.toInt()),
            ),
            onChanged: (values) {
              setState(() => _trimRange = values);
              controller.updateTrim(
                Duration(milliseconds: values.start.toInt()),
                Duration(milliseconds: values.end.toInt()),
              );
            },
          ),
          Center(
            child: Text(
              "Active Duration: ${_formatMs((_trimRange.end - _trimRange.start).toInt())}",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          // LOOP TOGGLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Loop Background Music",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Switch(
                value: _loop,
                onChanged: (val) {
                  setState(() => _loop = val);
                  if (controller.currentTrack.value != null) {
                    controller.currentTrack.value!.loop = val;
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Apply Settings",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

  String _formatMs(int ms) {
    final Duration d = Duration(milliseconds: ms);
    final String minutes = d.inMinutes.toString().padLeft(2, '0');
    final String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
