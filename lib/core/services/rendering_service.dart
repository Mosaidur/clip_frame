import 'dart:ui';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class RenderingService {
  static Future<File?> renderStory({
    required File mediaFile,
    required File? logoFile,
    required Offset logoOffset,
    required Size previewSize, // Size of the preview container in UI
    required double brightness, // -1.0 to 1.0
    required double contrast,   // 0.0 to 2.0
    required double saturation, // 0.0 to 2.0
    required String? audioPath,
    required double audioVolume,
    required Duration trimStart,
    required Duration trimEnd,
    required int rotation,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFileName = "rendered_${const Uuid().v4()}.mp4";
      final outputPath = path.join(tempDir.path, outputFileName);

      final bool isVideo = _isVideoFile(mediaFile);
      
      // Calculate logo position for the final video (assuming 1080x1920 or original AR)
      // For now, let's assume we want a standard 1080x1920 output for stories
      const double targetWidth = 1080.0;
      const double targetHeight = 1920.0;
      
      // Map UI offset to 1080x1920 space with sanitization
      double logoX = (logoOffset.dx / previewSize.width) * targetWidth;
      double logoY = (logoOffset.dy / previewSize.height) * targetHeight;
      
      if (logoX.isNaN || logoX.isInfinite) logoX = 0;
      if (logoY.isNaN || logoY.isInfinite) logoY = 0;
      
      // 1. Initial Processing: Rotation, Scaling, Cropping, and Color Adjustments
      String videoFilters = "[0:v]";
      
      // Handle Rotation
      if (rotation == 90) {
        videoFilters += "transpose=1,";
      } else if (rotation == 180) {
        videoFilters += "transpose=1,transpose=1,";
      } else if (rotation == 270) {
        videoFilters += "transpose=2,";
      }
      
      // Scale and Crop for Story (1080x1920)
      videoFilters += "scale=w=$targetWidth:h=$targetHeight:force_original_aspect_ratio=increase,crop=$targetWidth:$targetHeight,setsar=1";
      
      // Adjust colors
      videoFilters += ",eq=brightness=$brightness:contrast=$contrast:saturation=$saturation[v_base]";
      
      // Construct Filter Complex
      List<String> inputs = ["-i", mediaFile.path];
      String filterComplex = videoFilters;
      
      if (logoFile != null && await logoFile.exists()) {
        inputs.addAll(["-i", logoFile.path]);
        // Scale logo to 20% of width and overlay on [v_base]
        filterComplex += ";[1:v]scale=${targetWidth * 0.2}:-1[logo];[v_base][logo]overlay=$logoX:$logoY[v_out]";
      } else {
        // If no logo, just pass through
        filterComplex += ";[v_base]null[v_out]"; 
      }

      List<String> args = [];
      if (!isVideo) {
        args.addAll(["-loop", "1"]);
      }
      args.addAll(inputs);
      
      // Audio Input handling
      int audioInputIndex = (logoFile != null) ? 2 : 1;
      
      if (audioPath != null && File(audioPath).existsSync()) {
        args.addAll(["-ss", _formatDuration(trimStart), "-t", _formatDuration(trimEnd - trimStart), "-i", audioPath]);
        args.addAll([
          "-map", "[v_out]",
          "-map", "$audioInputIndex:a",
          "-shortest" 
        ]);
      } else {
        args.addAll([
          "-map", "[v_out]" 
        ]);
        if (!isVideo) {
          args.addAll(["-t", "10"]); 
        }
      }

      args.addAll([
        "-filter_complex", filterComplex,
        "-c:v", "libx264",
        "-preset", "ultrafast",
        "-crf", "28",
        "-c:a", "aac",
        "-y",
        outputPath
      ]);

      debugPrint("🎬 FFmpeg Command: ffmpeg ${args.join(' ')}");
      
      final session = await FFmpegKit.executeWithArguments(args);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("✅ Rendering successful: $outputPath");
        return File(outputPath);
      } else {
        final logs = await session.getLogs();
        debugPrint("❌ Rendering failed: ${logs.last.getMessage()}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error in RenderingService: $e");
      return null;
    }
  }

  static bool _isVideoFile(File file) {
    final ext = path.extension(file.path).toLowerCase();
    return [".mp4", ".mov", ".avi", ".mkv"].contains(ext);
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
