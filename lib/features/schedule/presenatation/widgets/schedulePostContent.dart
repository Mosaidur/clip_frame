import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/model.dart';

class SchedulePostContentWidget extends StatelessWidget {
  final SchedulePost post;
  const SchedulePostContentWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            post.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: const Color(0xFF334155),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5.h),

          // Hashtags as plain text
          if (post.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 5.h),
              child: Text(
                post.tags.map((tag) => "#$tag").join(" "),
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Date & Time
          Text(
            post.scheduleTime,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
