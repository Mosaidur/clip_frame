import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'story_capture.dart';
import 'story_Edit.dart';
import 'story_schedule.dart';

class StoryReviewShotsPage extends StatefulWidget {
  final List<File> initialFiles;

  const StoryReviewShotsPage({super.key, required this.initialFiles});

  @override
  State<StoryReviewShotsPage> createState() => _StoryReviewShotsPageState();
}

class _StoryReviewShotsPageState extends State<StoryReviewShotsPage> {
  late List<File> _files;
  bool _hasEdited = false;

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
          color: Color(0xFFF7F3EB), // Warm beige from image
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
              Text("Review Your Shots", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
              SizedBox(height: 4.h),
              Text("Preview and finalise your footage", style: TextStyle(fontSize: 11.sp, color: Colors.black54, fontWeight: FontWeight.w500)),
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
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text("Image $index", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black)),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 190.h,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 25.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
              // Corner Overlays
              Positioned(
                top: 15.h,
                left: 15.w,
                child: _overlayAction(Icons.flash_on_rounded, "Light"),
              ),
              Positioned(
                top: 15.h,
                right: 15.w,
                child: _overlayAction(Icons.water_drop_rounded, "Logo", isRight: true),
              ),
              Positioned(
                bottom: 15.h,
                left: 15.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StoryEditPage(files: [file])),
                    ).then((editedFile) {
                      if (editedFile != null && editedFile is File) {
                        setState(() => _files[index - 1] = editedFile);
                      }
                    });
                  },
                  child: _overlayAction(Icons.edit_rounded, "Edit"),
                ),
              ),
              Positioned(
                bottom: 15.h,
                right: 15.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StoryCapturePage(isAddingMore: true)),
                    ).then((newFile) {
                      if (newFile != null && newFile is File) {
                        setState(() => _files[index - 1] = newFile);
                      }
                    });
                  },
                  child: _overlayAction(Icons.refresh_rounded, "Re-record", isRight: true),
                ),
              ),
              // Remove Icon
              Positioned(
                top: -5,
                right: -5,
                child: IconButton(
                  onPressed: () => setState(() => _files.remove(file)),
                  icon: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: Colors.white, size: 14.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overlayAction(IconData icon, String label, {bool isRight = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12.r),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
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
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.w),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: const Color(0xFFFFEBF1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.add_photo_alternate_rounded, color: const Color(0xFFE91E63), size: 24.r),
            ),
            SizedBox(height: 8.h),
            Text("Add photo", style: TextStyle(color: Colors.black87, fontSize: 11.sp, fontWeight: FontWeight.bold)),
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
            if (!_hasEdited) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoryEditPage(files: _files)),
              ).then((editedFiles) {
                if (editedFiles != null && editedFiles is List<File>) {
                  setState(() {
                    _files = editedFiles;
                    _hasEdited = true;
                  });
                }
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StorySchedulePage(files: _files)),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          ),
          child: Text(
            _hasEdited ? "Create Story" : "Continue to Edit", 
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
