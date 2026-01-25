import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'story_capture.dart';
import 'story_Edit.dart';

class StoryReviewShotsPage extends StatefulWidget {
  final List<File> initialFiles;

  const StoryReviewShotsPage({super.key, required this.initialFiles});

  @override
  State<StoryReviewShotsPage> createState() => _StoryReviewShotsPageState();
}

class _StoryReviewShotsPageState extends State<StoryReviewShotsPage> {
  late List<File> _files;

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EBD8), Color(0xFFFFFFFF), Color(0xFFE8E1FF)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header
              _buildHeader(),

              // 2. Shots List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  itemCount: _files.length + 1, // +1 for "Add photo"
                  itemBuilder: (context, index) {
                    if (index < _files.length) {
                      return _buildMediaCard(_files[index], index + 1);
                    } else {
                      return _buildAddPhotoCard();
                    }
                  },
                ),
              ),

              // 3. Confirm Button
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(color: const Color(0xFFC4B69E).withOpacity(0.3), shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18.r),
              ),
            ),
          ),
          Column(
            children: [
              Text("Review Your Shots", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.black)),
              Text("Preview and finalise your footage", style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(File file, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Image $index", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8.h),
        Container(
          height: 180.h,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
              // Corner Overlays
              Positioned(
                bottom: 15.h,
                left: 15.w,
                child: _overlayAction(Icons.edit_note_rounded, "Edit"),
              ),
              Positioned(
                bottom: 15.h,
                right: 15.w,
                child: _overlayAction(Icons.refresh_rounded, "Re-record"),
              ),
              // Remove Icon
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => setState(() => _files.remove(file)),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overlayAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 14.r),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StoryCapturePage(isAddingMore: true)),
        ).then((newFile) {
          if (newFile != null && newFile is File) {
             setState(() => _files.add(newFile));
          }
        });
      },
      child: Container(
        height: 100.h,
        margin: EdgeInsets.only(bottom: 30.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white.withOpacity(0.5),
          border: Border.all(color: Colors.black12, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: const Color(0xFFFF4081), size: 30.r),
            SizedBox(height: 5.h),
            Text("Add photo", style: TextStyle(color: Colors.black54, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryEditPage(files: _files),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0080FF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text("Confirm & Continue", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
