import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'Content_Steps.dart';
import 'photo_preview_screen.dart';
import 'package:get/get.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';
import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';

/// Screen that shows a horizontal carousel of selected images with a confirm button.
class MultiImagePreviewScreen extends StatefulWidget {
  final List<String> imagePaths;
  final ContentTemplateModel? template;

  const MultiImagePreviewScreen({
    super.key,
    required this.imagePaths,
    this.template,
  });

  @override
  State<MultiImagePreviewScreen> createState() =>
      _MultiImagePreviewScreenState();
}

class _MultiImagePreviewScreenState extends State<MultiImagePreviewScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  late List<String> _currentPaths;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPaths = List.from(widget.imagePaths);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _editCurrentImage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreviewScreen(
          imagePaths: _currentPaths,
          initialIndex: _currentIndex,
          isCarouselEdit: true,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentPaths[_currentIndex] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const CustomBackButton(iconColor: Colors.white),
        title: Text(
          "${_currentIndex + 1} / ${widget.imagePaths.length}",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _editCurrentImage,
            icon: Icon(Icons.brush_rounded,
                color: const Color(0xFFFF4D8D), size: 22.sp),
            tooltip: "Edit this photo",
          ),
          TextButton(
            onPressed: () {
              if (Get.isRegistered<ContentCreationController>()) {
                final controller = Get.find<ContentCreationController>();
                controller.selectedFiles.assignAll(
                  _currentPaths.map((e) => File(e)).toList(),
                );
                controller.selectedContentType.value = 'post';
                controller.templateId.value = widget.template?.id ?? "";
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoPreviewScreen(
                    imagePaths: _currentPaths,
                  ),
                ),
              );
            },
            child: Text(
              "NEXT",
              style: TextStyle(
                  color: const Color(0xFFFF4D8D),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _currentPaths.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return Image.file(
                  File(_currentPaths[index]),
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          // Dot indicator
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_currentPaths.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: i == _currentIndex ? 14.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: i == _currentIndex
                        ? const Color(0xFFFF4D8D)
                        : Colors.white38,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                );
              }),
            ),
          ),
          // Thumbnail strip
          SizedBox(
            height: 70.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: _currentPaths.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    width: 60.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF4D8D)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.r),
                      child: Image.file(
                        File(_currentPaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class PostHighlight extends StatelessWidget {
  final String url;
  final String contentType;
  final ContentTemplateModel? template;

  const PostHighlight({
    super.key,
    required this.url,
    required this.contentType,
    this.template,
  });

  @override
  Widget build(BuildContext context) {
    print(contentType);
    String title = "Post Highlight";
    String subTitle =
        "Take a photo with clear lightning showcasing your idea clearly ";
    // String url = "assets/images/highlight.png"; // Replace with your image path
    String tips =
        "Why this idea? Trending #Food #Cooking content gets high engagement and saves on Instagram and TikTok. Idea product-first brands.";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEBC894), Color(0xFFFFFFFF), Color(0xFFB49EF4)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const CustomBackButton(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Image section with border
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // Blurred background
                        Positioned.fill(
                          child: _MediaWidget(
                            url: url,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(color: Colors.black.withOpacity(0.3)),
                          ),
                        ),
                        // Main image
                        Center(
                          child: _MediaWidget(
                            url: url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tips,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if ((contentType ?? '').toLowerCase() == 'story') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StepByStepPage(
                                contentType: contentType,
                                template: template?.toJson(),
                              ),
                            ),
                          );
                        } else {
                          _showImageSourceSheet(context);
                        }
                      },
                      child: const Text(
                        "Start Creating",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              "Select Image Source",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  context, // Root context
                  sheetContext: sheetContext,
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  color: const Color(0xFF007AFF),
                  source: ImageSource.camera,
                ),
                _buildSourceOption(
                  context, // Root context
                  sheetContext: sheetContext,
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  color: const Color(0xFFFF2D78),
                  source: ImageSource.gallery,
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext rootContext, {
    required BuildContext sheetContext,
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(sheetContext);
        final ImagePicker picker = ImagePicker();
        
        if (source == ImageSource.gallery) {
          // Multi-image pick for carousel posts
          final List<XFile> images = await picker.pickMultiImage();
          if (images.isNotEmpty && rootContext.mounted) {
            Navigator.push(
              rootContext,
              MaterialPageRoute(
                builder: (context) => MultiImagePreviewScreen(
                  imagePaths: images.map((e) => e.path).toList(),
                  template: template,
                ),
              ),
            );
          }
        } else {
          // Camera: single image → existing photo editor
          final XFile? image = await picker.pickImage(source: source);
          if (image != null && rootContext.mounted) {
            if (Get.isRegistered<ContentCreationController>()) {
              final controller = Get.find<ContentCreationController>();
              controller.selectedFiles.assignAll([File(image.path)]);
              controller.selectedContentType.value =
                  (contentType ?? 'post').toLowerCase();
              controller.templateId.value = template?.id ?? "";
            }
            Navigator.push(
              rootContext,
              MaterialPageRoute(
                builder: (context) => PhotoPreviewScreen(imagePaths: [image.path]),
              ),
            );
          }
        }
      },
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 32.r),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaWidget extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const _MediaWidget({required this.url, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/1.jpg', // Fallback local image
          fit: fit,
        ),
      );
    } else {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    }
  }
}
