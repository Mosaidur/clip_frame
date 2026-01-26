import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum StoryEditTool { bg, adjust, crop, filter }

class StoryEditPage extends StatefulWidget {
  final List<File> files;
  const StoryEditPage({super.key, this.files = const []});

  @override
  State<StoryEditPage> createState() => _StoryEditPageState();
}

class _StoryEditPageState extends State<StoryEditPage> {
  StoryEditTool? _activeTool;
  // Carousel state
  late PageController _pageController;
  int _currentPage = 0;

  // Adjust states
  double _brightness = 0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _highlights = 0.0;
  double _shadows = 0.0;
  double _temperature = 0.0;
  
  String _selectedAdjustTool = "Brightness";

  // Filter states
  int _selectedFilterIndex = 0;
  double _filterIntensity = 1.0;
  String _selectedFilterCategory = "Trending";

  // Crop states
  Rect _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
  int _rotation = 0;
  String _cropMode = "Format"; // "Format" or "Rotate"
  String _selectedAspectRatio = "Original"; // "Original", "1:1", "4:5", "16:9", "9:16", "3:2"
  bool _flipHorizontal = false;
  bool _flipVertical = false;

  // Snapshot states for cancel logic
  double? _snapBrightness;
  double? _snapContrast;
  double? _snapSaturation;
  double? _snapHighlights;
  double? _snapShadows;
  double? _snapTemperature;
  int? _snapFilterIndex;
  double? _snapFilterIntensity;
  String? _snapFilterCategory;
  Rect? _snapCropRect;
  int? _snapRotation;
  String? _snapCropMode;
  String? _snapAspectRatio;
  bool? _snapFlipHorizontal;
  bool? _snapFlipVertical;

  void _takeSnapshot() {
    _snapBrightness = _brightness;
    _snapContrast = _contrast;
    _snapSaturation = _saturation;
    _snapHighlights = _highlights;
    _snapShadows = _shadows;
    _snapTemperature = _temperature;
    _snapFilterIndex = _selectedFilterIndex;
    _snapFilterIntensity = _filterIntensity;
    _snapFilterCategory = _selectedFilterCategory;
    _snapCropRect = _cropRect;
    _snapRotation = _rotation;
    _snapCropMode = _cropMode;
    _snapAspectRatio = _selectedAspectRatio;
    _snapFlipHorizontal = _flipHorizontal;
    _snapFlipVertical = _flipVertical;
  }

  void _revertToSnapshot() {
    if (_snapBrightness != null) _brightness = _snapBrightness!;
    if (_snapContrast != null) _contrast = _snapContrast!;
    if (_snapSaturation != null) _saturation = _snapSaturation!;
    if (_snapHighlights != null) _highlights = _snapHighlights!;
    if (_snapShadows != null) _shadows = _snapShadows!;
    if (_snapTemperature != null) _temperature = _snapTemperature!;
    if (_snapFilterIndex != null) _selectedFilterIndex = _snapFilterIndex!;
    if (_snapFilterIntensity != null) _filterIntensity = _snapFilterIntensity!;
    if (_snapFilterCategory != null) _selectedFilterCategory = _snapFilterCategory!;
    if (_snapCropRect != null) _cropRect = _snapCropRect!;
    if (_snapRotation != null) _rotation = _snapRotation!;
    if (_snapCropMode != null) _cropMode = _snapCropMode!;
    if (_snapAspectRatio != null) _selectedAspectRatio = _snapAspectRatio!;
    if (_snapFlipHorizontal != null) _flipHorizontal = _snapFlipHorizontal!;
    if (_snapFlipVertical != null) _flipVertical = _snapFlipVertical!;
  }

  final Map<String, List<Map<String, dynamic>>> _filterCategories = {
    "Trending": [
      {"name": "NONE", "image": "assets/images/edit_photo.png"},
      {"name": "DUAL", "image": "assets/images/1.jpg"},
      {"name": "POP", "image": "assets/images/2.jpg"},
      {"name": "NEON", "image": "assets/images/filter_img1.png"},
      {"name": "FILM", "image": "assets/images/5.jpg"},
      {"name": "GLOW", "image": "assets/images/filter_img2.png"},
      {"name": "VIBE", "image": "assets/images/7.jpg"},
      {"name": "MOOD", "image": "assets/images/8.jpg"},
      {"name": "VINTAGE", "image": "assets/images/9.png"},
      {"name": "SOFT", "image": "assets/images/1.jpg"},
    ],
    "Glitch": [
      {"name": "GLITCH", "image": "assets/images/2.jpg"},
      {"name": "RGB", "image": "assets/images/filter_img3.png"},
      {"name": "SHIFT", "image": "assets/images/5.jpg"},
      {"name": "ERROR", "image": "assets/images/filter_img4.png"},
      {"name": "PIXEL", "image": "assets/images/7.jpg"},
      {"name": "NOISE", "image": "assets/images/8.jpg"},
      {"name": "WARP", "image": "assets/images/9.png"},
    ],
    "Weather": [
      {"name": "SUN", "image": "assets/images/1.jpg"},
      {"name": "WARM", "image": "assets/images/2.jpg"},
      {"name": "COOL", "image": "assets/images/3.jpg"},
      {"name": "FOG", "image": "assets/images/5.jpg"},
      {"name": "RAIN", "image": "assets/images/6.jpg"},
      {"name": "SNOW", "image": "assets/images/7.jpg"},
      {"name": "DUST", "image": "assets/images/8.jpg"},
    ],
    "Vintage": [
      {"name": "VINT", "image": "assets/images/9.png"},
      {"name": "SEPIA", "image": "assets/images/1.jpg"},
      {"name": "RETRO", "image": "assets/images/2.jpg"},
      {"name": "FADE", "image": "assets/images/3.jpg"},
      {"name": "OLD", "image": "assets/images/5.jpg"},
      {"name": "FILM2", "image": "assets/images/6.jpg"},
      {"name": "BROWN", "image": "assets/images/7.jpg"},
    ],
    "Color / Pop": [
      {"name": "POP2", "image": "assets/images/8.jpg"},
      {"name": "BRIGHT", "image": "assets/images/9.png"},
      {"name": "SAT", "image": "assets/images/1.jpg"},
      {"name": "PASTEL", "image": "assets/images/filter_img5.png"},
      {"name": "FRESH", "image": "assets/images/3.jpg"},
      {"name": "BOOST", "image": "assets/images/5.jpg"},
      {"name": "JUICY", "image": "assets/images/6.jpg"},
    ],
    "Moody": [
      {"name": "DARK", "image": "assets/images/7.jpg"},
      {"name": "SHADOW", "image": "assets/images/8.jpg"},
      {"name": "NIGHT", "image": "assets/images/9.png"},
      {"name": "BLUE", "image": "assets/images/1.jpg"},
      {"name": "LOW", "image": "assets/images/2.jpg"},
      {"name": "DEEP", "image": "assets/images/3.jpg"},
      {"name": "SAD", "image": "assets/images/5.jpg"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            colors: [
              Color(0xFFF7EBD8), // Beige/Cream top
              Color(0xFFFFFFFF), // White middle
              Color(0xFFE8E1FF), // Soft Purple bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Header
              _buildHeader(),

              // 2. Main Preview Section
              Expanded(
                child: _buildPreviewArea(),
              ),

              // 3. Bottom Tool Section
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: const Color(0xFFC4B69E).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.r, color: Colors.black87),
            ),
          ),
          // Title
          Text(
            "Preview",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          // Done Button
          TextButton(
            onPressed: () {},
            child: Text(
              "DONE",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE91E63), // Pinkish/Red from image
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Column(
      children: [
        SizedBox(height: 10.h),
        // Progress Bars
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: Row(
            children: List.generate(
              widget.files.length > 0 ? widget.files.length : 3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: _buildProgressBar(index == _currentPage),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        // Image Container
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, innerConstraints) {
                            final w = innerConstraints.maxWidth;
                            final h = innerConstraints.maxHeight;
                            
                            Widget content = Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateZ(_rotation * 3.14159 / 180)
                                ..scale(_flipHorizontal ? -1.0 : 1.0, _flipVertical ? -1.0 : 1.0),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: widget.files.isNotEmpty ? widget.files.length : 1,
                                onPageChanged: (index) {
                                  setState(() => _currentPage = index);
                                },
                                itemBuilder: (context, index) {
                                  return ColorFiltered(
                                    colorFilter: ColorFilter.matrix(_getCombinedMatrix()),
                                    child: widget.files.isNotEmpty
                                        ? Image.file(
                                            widget.files[index],
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
                                            fit: BoxFit.cover,
                                          ),
                                  );
                                },
                              ),
                            );

                            if (_activeTool != StoryEditTool.crop) {
                              content = Transform(
                                alignment: Alignment.topLeft,
                                transform: Matrix4.identity()
                                  ..scale(1.0 / _cropRect.width, 1.0 / _cropRect.height)
                                  ..translate(-_cropRect.left * w, -_cropRect.top * h),
                                child: content,
                              );
                            }
                            return content;
                          },
                        ),
                      ),
                      if (_activeTool == StoryEditTool.crop)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, cropConstraints) {
                              final w = cropConstraints.maxWidth;
                              final h = cropConstraints.maxHeight;
                              
                              final rect = Rect.fromLTWH(
                                _cropRect.left * w,
                                _cropRect.top * h,
                                _cropRect.width * w,
                                _cropRect.height * h,
                              );

                              return Stack(
                                children: [
                                  GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        double dx = details.delta.dx / w;
                                        double dy = details.delta.dy / h;
                                        
                                        _cropRect = Rect.fromLTWH(
                                          (_cropRect.left + dx).clamp(0.0, 1.0 - _cropRect.width),
                                          (_cropRect.top + dy).clamp(0.0, 1.0 - _cropRect.height),
                                          _cropRect.width,
                                          _cropRect.height,
                                        );
                                      });
                                    },
                                    child: CustomPaint(
                                      size: Size(w, h),
                                      painter: CropPainter(rect),
                                      child: Container(),
                                    ),
                                  ),
                                  // Handles
                                  _buildCropHandle(rect.topLeft, (d) => _updateCropRect(d, w, h, isTop: true, isLeft: true)),
                                  _buildCropHandle(rect.topRight, (d) => _updateCropRect(d, w, h, isTop: true, isLeft: false)),
                                  _buildCropHandle(rect.bottomLeft, (d) => _updateCropRect(d, w, h, isTop: false, isLeft: true)),
                                  _buildCropHandle(rect.bottomRight, (d) => _updateCropRect(d, w, h, isTop: false, isLeft: false)),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }

  Widget _buildProgressBar(bool active) {
    return Container(
      height: 4.h,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE91E63) : const Color(0xFFE91E63).withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_activeTool != null) _buildToolOverlay(),
          _buildToolBar(),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _toolIcon(Icons.layers_clear_rounded, "BG", StoryEditTool.bg),
            _toolIcon(Icons.wb_sunny_outlined, "Adjust", StoryEditTool.adjust),
            _toolIcon(Icons.crop_rounded, "Crop", StoryEditTool.crop),
            _toolIcon(Icons.auto_awesome_motion_rounded, "Filter", StoryEditTool.filter),
            _toolIcon(Icons.compare_arrows_rounded, "Split", null), 
            _toolIcon(Icons.content_cut_rounded, "Trim", null),
            _toolIcon(Icons.delete_outline_rounded, "Delete", null),
          ],
        ),
      ),
    );
  }

  Widget _toolIcon(IconData icon, String label, StoryEditTool? tool) {
    bool isActive = _activeTool == tool && tool != null;
    return GestureDetector(
      onTap: () {
        if (tool != null) {
          setState(() {
            if (_activeTool == tool) {
              _activeTool = null;
            } else {
              _takeSnapshot(); // Take snapshot when opening a tool
              _activeTool = tool;
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.r, color: isActive ? Colors.black : Colors.black54),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolOverlay() {
    // This will switch based on _activeTool
    return Column(
      children: [
        _buildToolHeader(),
        if (_activeTool == StoryEditTool.adjust) _buildAdjustPanel(),
        if (_activeTool == StoryEditTool.filter) _buildFilterPanel(),
        if (_activeTool == StoryEditTool.bg) _buildBGPanel(),
        if (_activeTool == StoryEditTool.crop) _buildCropPanel(),
      ],
    );
  }

  Widget _buildBGPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        // Sections: Blur, Pattern, Gradient
        _buildBGSection("Blur", _buildBlurList()),
        _buildBGSection("Pattern", _buildPatternGrid()),
        _buildBGSection("Gradient", _buildGradientGrid()),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildBGSection(String title, Widget content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(title, style: TextStyle(fontSize: 11.sp, color: Colors.black38, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8.h),
          content,
        ],
      ),
    );
  }

  Widget _buildBlurList() {
    return SizedBox(
      height: 45.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 45.r,
            height: 45.r,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: index == 0 ? Border.all(color: Colors.blue, width: 2.w) : null,
              image: const DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1540189549336-e6e99c3679fe"),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatternGrid() {
    return SizedBox(
      height: 32.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            width: 32.r,
            height: 32.r,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientGrid() {
    return SizedBox(
      height: 32.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            width: 32.r,
            height: 32.r,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.primaries[index % Colors.primaries.length], Colors.white.withOpacity(0.5)],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCropPanel() {
    return Column(
      children: [
        SizedBox(height: 15.h),
        // Toggle: Format / Rotate
        Container(
          width: 140.w,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              _cropToggleItem("Format", _cropMode == "Format"),
              _cropToggleItem("Rotate", _cropMode == "Rotate"),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        // Show different controls based on mode
        if (_cropMode == "Format") _buildFormatControls(),
        if (_cropMode == "Rotate") _buildRotateControls(),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildFormatControls() {
    return SizedBox(
      height: 80.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _ratioItem(Icons.crop_free_rounded, "Original", _selectedAspectRatio == "Original", () {
            setState(() {
              _selectedAspectRatio = "Original";
              _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
            });
          }),
          _ratioItem(Icons.crop_square_rounded, "1:1", _selectedAspectRatio == "1:1", () {
            setState(() {
              _selectedAspectRatio = "1:1";
              _applyCropAspectRatio(1.0);
            });
          }),
          _ratioItem(Icons.crop_portrait_rounded, "4:5", _selectedAspectRatio == "4:5", () {
            setState(() {
              _selectedAspectRatio = "4:5";
              _applyCropAspectRatio(4.0 / 5.0);
            });
          }),
          _ratioItem(Icons.crop_16_9_rounded, "16:9", _selectedAspectRatio == "16:9", () {
            setState(() {
              _selectedAspectRatio = "16:9";
              _applyCropAspectRatio(16.0 / 9.0);
            });
          }),
          _ratioItem(Icons.smartphone_rounded, "9:16", _selectedAspectRatio == "9:16", () {
            setState(() {
              _selectedAspectRatio = "9:16";
              _applyCropAspectRatio(9.0 / 16.0);
            });
          }),
          _ratioItem(Icons.crop_3_2, "3:2", _selectedAspectRatio == "3:2", () {
            setState(() {
              _selectedAspectRatio = "3:2";
              _applyCropAspectRatio(3.0 / 2.0);
            });
          }),
        ],
      ),
    );
  }

  Widget _buildRotateControls() {
    return Column(
      children: [
        // Rotation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _rotateButton(Icons.rotate_left_rounded, "90° Left", () {
              setState(() => _rotation = (_rotation - 90) % 360);
            }),
            SizedBox(width: 20.w),
            _rotateButton(Icons.rotate_right_rounded, "90° Right", () {
              setState(() => _rotation = (_rotation + 90) % 360);
            }),
          ],
        ),
        SizedBox(height: 20.h),
        // Flip buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _flipButton(Icons.flip_rounded, "Flip H", _flipHorizontal, () {
              setState(() => _flipHorizontal = !_flipHorizontal);
            }),
            SizedBox(width: 20.w),
            _flipButton(Icons.flip_camera_android_rounded, "Flip V", _flipVertical, () {
              setState(() => _flipVertical = !_flipVertical);
            }),
          ],
        ),
      ],
    );
  }

  void _applyCropAspectRatio(double aspectRatio) {
    // Calculate new crop rect maintaining aspect ratio
    double centerX = _cropRect.left + _cropRect.width / 2;
    double centerY = _cropRect.top + _cropRect.height / 2;
    
    double newWidth = 0.8;
    double newHeight = newWidth / aspectRatio;
    
    if (newHeight > 0.8) {
      newHeight = 0.8;
      newWidth = newHeight * aspectRatio;
    }
    
    double newLeft = (centerX - newWidth / 2).clamp(0.0, 1.0 - newWidth);
    double newTop = (centerY - newHeight / 2).clamp(0.0, 1.0 - newHeight);
    
    _cropRect = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
  }

  Widget _rotateButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF2196F3), width: 1.5.w),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2196F3), size: 20.r),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF2196F3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flipButton(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE91E63) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? const Color(0xFFE91E63) : Colors.black26,
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.black45, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: isActive ? Colors.white : Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cropToggleItem(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _cropMode = label),
        child: Container(
          height: 24.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.pink : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(label, style: TextStyle(fontSize: 10.sp, color: active ? Colors.white : Colors.black38, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _ratioItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55.w,
        margin: EdgeInsets.only(right: 15.w),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.black45, size: 20.r),
            SizedBox(height: 6.h),
            Text(label, style: TextStyle(fontSize: 9.sp, color: active ? Colors.white : Colors.black45, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolHeader() {
    String title = "";
    switch (_activeTool) {
      case StoryEditTool.bg: title = "Background"; break;
      case StoryEditTool.adjust: title = "Adjust"; break;
      case StoryEditTool.crop: title = "Crop Photos"; break;
      case StoryEditTool.filter: title = "Filter"; break;
      default: break;
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => setState(() {
              _revertToSnapshot(); // Revert changes on Cancel
              _activeTool = null;
            }),
            child: Text("Cancel", style: TextStyle(color: Colors.black54, fontSize: 16.sp)),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp, 
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(() {
              _activeTool = null; // Keep changes on Apply
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, 
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  void _updateCropRect(Offset delta, double w, double h, {required bool isTop, required bool isLeft}) {
    setState(() {
      double dx = delta.dx / w;
      double dy = delta.dy / h;
      
      double left = _cropRect.left;
      double top = _cropRect.top;
      double width = _cropRect.width;
      double height = _cropRect.height;

      if (isLeft) {
        double newLeft = (left + dx).clamp(0.0, left + width - 0.1);
        width += (left - newLeft);
        left = newLeft;
      } else {
        width = (width + dx).clamp(0.1, 1.0 - left);
      }

      if (isTop) {
        double newTop = (top + dy).clamp(0.0, top + height - 0.1);
        height += (top - newTop);
        top = newTop;
      } else {
        height = (height + dy).clamp(0.1, 1.0 - top);
      }

      _cropRect = Rect.fromLTWH(left, top, width, height);
    });
  }

  Widget _buildCropHandle(Offset pos, Function(Offset) onDrag) {
    return Positioned(
      left: pos.dx - 15.r,
      top: pos.dy - 15.r,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          width: 30.r,
          height: 30.r,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustPanel() {
    return Column(
      children: [
         SizedBox(height: 10.h),
         _buildRuler(),
         _buildAdjustToolList(),
         SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildAdjustToolList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          _adjustSubTool(Icons.wb_sunny_rounded, "Brightness"),
          _adjustSubTool(Icons.contrast_rounded, "Contrast"),
          _adjustSubTool(Icons.water_drop_rounded, "Saturation"),
          _adjustSubTool(Icons.highlight_rounded, "Highlights"),
          _adjustSubTool(Icons.wb_twilight_rounded, "Shadows"),
          _adjustSubTool(Icons.device_thermostat_rounded, "Temperature"),
        ],
      ),
    );
  }

  double _getAdjustValue() {
    switch (_selectedAdjustTool) {
      case "Brightness": return _brightness * 100;
      case "Contrast": return (_contrast - 1.0) * 100;
      case "Saturation": return (_saturation - 1.0) * 100;
      case "Highlights": return _highlights * 100;
      case "Shadows": return _shadows * 100;
      case "Temperature": return _temperature * 100;
      default: return 0;
    }
  }

  void _updateAdjustValue(double val) {
    setState(() {
      switch (_selectedAdjustTool) {
        case "Brightness": _brightness = val / 100; break;
        case "Contrast": _contrast = 1.0 + val / 100; break;
        case "Saturation": _saturation = 1.0 + val / 100; break;
        case "Highlights": _highlights = val / 100; break;
        case "Shadows": _shadows = val / 100; break;
        case "Temperature": _temperature = val / 100; break;
      }
    });
  }

  Widget _adjustSubTool(IconData icon, String label) {
    bool active = _selectedAdjustTool == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedAdjustTool = label),
      child: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2196F3) : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: active ? Colors.white : Colors.black45, size: 20.r),
            ),
            SizedBox(height: 5.h),
            Text(label, style: TextStyle(fontSize: 9.sp, color: active ? Colors.black87 : Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildRuler() {
    return Column(
      children: [
        Text(
          _getAdjustValue().toStringAsFixed(0), 
          style: TextStyle(
            color: const Color(0xFFFF2D78), 
            fontWeight: FontWeight.bold, 
            fontSize: 14.sp
          )
        ),
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                   // Drag LEFT (dx is negative) -> value INCREASES
                   double delta = details.delta.dx / 2.w;
                   _updateAdjustValue((_getAdjustValue() - delta).clamp(-100, 100));
                },
                child: CustomPaint(
                  size: Size(double.infinity, 50.h),
                  painter: RulerPainter(offset: _getAdjustValue()),
                ),
              ),
              Container(
                width: 2.w,
                height: 30.h,
                color: const Color(0xFFFF2D78),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel() {
    final List<Map<String, dynamic>> filters = _filterCategories[_selectedFilterCategory]!;
    return Column(
      children: [
         // Category Tabs
         Padding(
           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
           child: SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: Row(
               children: _filterCategories.keys.map((cat) {
                 bool active = cat == _selectedFilterCategory;
                 return Padding(
                   padding: EdgeInsets.only(right: 20.w),
                   child: GestureDetector(
                     onTap: () => setState(() {
                       _selectedFilterCategory = cat;
                       _selectedFilterIndex = 0; // Reset to NONE when switching categories
                     }),
                     child: Text(
                       cat,
                       style: TextStyle(
                         color: active ? const Color(0xFFE91E63) : Colors.black38,
                         fontWeight: active ? FontWeight.bold : FontWeight.normal,
                         fontSize: 12.sp,
                       ),
                     ),
                   ),
                 );
               }).toList(),
             ),
           ),
         ),
         // Filter Thumbnails
         SizedBox(
           height: 80.h,
           child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                bool selected = index == _selectedFilterIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: Column(
                    children: [
                      Container(
                        width: 65.w,
                        height: 65.w,
                        margin: EdgeInsets.only(right: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: selected ? Border.all(color: const Color(0xFFE91E63), width: 2.w) : null,
                          image: DecorationImage(
                            image: AssetImage(filters[index]["image"] ?? "assets/images/edit_photo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        filters[index]["name"],
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: selected ? Colors.black : Colors.black45,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
           ),
         ),
         // Intensity Slider
         Padding(
           padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
           child: Row(
             children: [
               Expanded(
                 child: SliderTheme(
                   data: SliderTheme.of(context).copyWith(
                     trackHeight: 2.h,
                     thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                     activeTrackColor: const Color(0xFFE91E63),
                     inactiveTrackColor: Colors.black12,
                     thumbColor: const Color(0xFFE91E63),
                   ),
                   child: Slider(
                     value: _filterIntensity,
                     onChanged: (v) => setState(() => _filterIntensity = v),
                   ),
                 ),
               ),
               Text("${(_filterIntensity * 100).toInt()}%", style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
             ],
           ),
         ),
      ],
    );
  }

  List<double> _getCombinedMatrix() {
    List<double> matrix = _getInterpolatedFilterMatrix();
    
    // Apply Brightness
    matrix[4] += _brightness * 255;
    matrix[9] += _brightness * 255;
    matrix[14] += _brightness * 255;
    
    // Apply Contrast
    for (int i in [0, 6, 12]) {
      matrix[i] *= _contrast;
    }
    
    // Apply Saturation
    double invSat = 1.0 - _saturation;
    double R = 0.213 * invSat;
    double G = 0.715 * invSat;
    double B = 0.072 * invSat;

    List<double> satMatrix = [
      R + _saturation, G, B, 0, 0,
      R, G + _saturation, B, 0, 0,
      R, G, B + _saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];
    matrix = _multiplyMatrices(matrix, satMatrix);

    // Apply Temperature (Warmth)
    List<double> tempMatrix = [
      1.0 + _temperature * 0.1, 0, 0, 0, 0,
      0, 1.0 + _temperature * 0.05, 0, 0, 0,
      0, 0, 1.0 - _temperature * 0.1, 0, 0,
      0, 0, 0, 1, 0,
    ];
    matrix = _multiplyMatrices(matrix, tempMatrix);

    // Apply Highlights & Shadows
    if (_highlights != 0 || _shadows != 0) {
      double hGain = 1.0 + _highlights * 0.2;
      double sOffset = _shadows * 30;
      List<double> lightMatrix = [
        hGain, 0, 0, 0, sOffset,
        0, hGain, 0, 0, sOffset,
        0, 0, hGain, 0, sOffset,
        0, 0, 0, 1, 0,
      ];
      matrix = _multiplyMatrices(matrix, lightMatrix);
    }
    
    return matrix;
  }

  List<double> _multiplyMatrices(List<double> m1, List<double> m2) {
    List<double> result = List.filled(20, 0.0);
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 5; j++) {
            double sum = 0;
            for (int k = 0; k < 4; k++) {
                sum += m1[i * 5 + k] * m2[k * 5 + j];
            }
            if (j == 4) sum += m1[i * 5 + 4];
            result[i * 5 + j] = sum;
        }
    }
    return result;
  }

  List<double> _getInterpolatedFilterMatrix() {
    final List<double> identity = [
      1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0
    ];
    if (_selectedFilterIndex == 0) return identity;
    
    final target = _getFilterMatrix(_selectedFilterIndex);
    final result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      result[i] = identity[i] + (target[i] - identity[i]) * _filterIntensity;
    }
    return result;
  }

  List<double> _getFilterMatrix(int index) {
     final String name = _filterCategories[_selectedFilterCategory]![index]["name"];
     switch (name) {
       // --- Trending ---
       case "DUAL":
         return [
           1.2, 0.1, 0.1, 0.0, 0.0,
           1.2, 0.1, 0.1, 0.0, 0.0,
           0.1, 1.1, 0.1, 0.0, 0.0,
           0.1, 0.1, 1.5, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ].sublist(0, 20); // Ensuring it's exactly 20 elements
       case "POP":
         return [
           1.5, 0.0, 0.0, 0.0, 0.0,
           0.0, 1.3, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.2, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "NEON":
         return [
           1.5, 0.0, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.5, 0.0, 0.0,
           0.0, 1.5, 0.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "FILM":
         return [
           0.9, 0.2, 0.0, 0.0, 0.0,
           0.1, 0.9, 0.1, 0.0, 0.0,
           0.0, 0.2, 0.8, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "GLOW":
         return [
           1.0, 0.0, 0.0, 0.0, 40.0,
           0.0, 1.0, 0.0, 0.0, 40.0,
           0.0, 0.0, 1.0, 0.0, 40.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "VIBE":
         return [
           1.1, 0.0, 0.0, 0.0, 10.0,
           0.0, 1.0, 0.0, 0.0, 0.0,
           0.0, 0.0, 0.9, 0.0, -10.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "MOOD":
         return [
           0.9, 0.0, 0.0, 0.0, -10.0,
           0.0, 1.0, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.1, 0.0, 10.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "VINTAGE":
       case "VINT":
         return [
           0.393, 0.769, 0.189, 0.0, 0.0,
           0.349, 0.686, 0.168, 0.0, 0.0,
           0.272, 0.534, 0.131, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "SOFT":
         return [
           1.0, 0.4, 0.4, 0.0, 0.0,
           0.4, 1.0, 0.4, 0.0, 0.0,
           0.4, 0.4, 1.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       // --- Glitch ---
       case "GLITCH":
         return [
           -1.0, 0.0, 0.0, 0.0, 255.0,
           0.0, 1.0, 0.0, 0.0, 0.0,
           0.0, 0.0, -1.0, 0.0, 255.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "RGB":
         return [
           1.0, 0.5, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.5, 0.0, 0.0,
           0.5, 0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "SHIFT":
         return [
           1.0, 0.0, 0.2, 0.0, 0.0,
           0.2, 1.0, 0.0, 0.0, 0.0,
           0.0, 0.2, 1.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "ERROR":
         return [
           -1.0, -1.0, -1.0, 0.0, 255.0,
           -1.0, -1.0, -1.0, 0.0, 255.0,
           -1.0, -1.0, -1.0, 0.0, 255.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "PIXEL":
         return [
           1.0, 0.2, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.2, 0.0, 0.0,
           0.2, 0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "NOISE":
         return [
           1.0, 0.0, 0.0, 0.0, 20.0,
           0.0, 1.0, 0.0, 0.0, 20.0,
           0.0, 0.0, 1.0, 0.0, 20.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "WARP":
         return [
           1.5, -0.5, 0.0, 0.0, 0.0,
           0.0, 1.5, -0.5, 0.0, 0.0,
           -0.5, 0.0, 1.5, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       // --- Weather ---
       case "SUN":
         return [
           1.1, 0.0, 0.0, 0.0, 30.0,
           0.0, 1.0, 0.0, 0.0, 20.0,
           0.0, 0.0, 0.9, 0.0, -10.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "WARM":
         return [
           1.2, 0.0, 0.0, 0.0, 20.0,
           0.0, 1.1, 0.0, 0.0, 10.0,
           0.0, 0.0, 0.9, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "COOL":
         return [
           0.9, 0.0, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.0, 0.0, 10.0,
           0.0, 0.0, 1.2, 0.0, 20.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "FOG":
         return [
           0.8, 0.0, 0.0, 0.0, 50.0,
           0.0, 0.8, 0.0, 0.0, 50.0,
           0.0, 0.0, 0.8, 0.0, 50.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "RAIN":
         return [
           0.7, 0.0, 0.0, 0.0, 10.0,
           0.0, 0.7, 0.0, 0.0, 10.0,
           0.0, 0.0, 0.9, 0.0, 30.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "SNOW":
         return [
           1.2, 0.0, 0.0, 0.0, 40.0,
           0.0, 1.2, 0.0, 0.0, 40.0,
           0.0, 0.0, 1.3, 0.0, 50.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "DUST":
         return [
           1.0, 0.2, 0.2, 0.0, 10.0,
           0.2, 1.0, 0.2, 0.0, 10.0,
           0.2, 0.2, 0.8, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       // --- Vintage ---
       case "SEPIA":
         return [
           0.393, 0.769, 0.189, 0.0, 0.0,
           0.349, 0.686, 0.168, 0.0, 0.0,
           0.272, 0.534, 0.131, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "RETRO":
         return [
           1.0, 0.0, 0.0, 0.0, 30.0,
           0.0, 0.8, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.2, 0.0, -20.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "FADE":
         return [
           0.9, 0.1, 0.1, 0.0, 20.0,
           0.1, 0.9, 0.1, 0.0, 20.0,
           0.1, 0.1, 0.9, 0.0, 20.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "OLD":
         return [
           0.7, 0.2, 0.1, 0.0, 30.0,
           0.2, 0.7, 0.1, 0.0, 30.0,
           0.1, 0.1, 0.7, 0.0, 30.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "FILM2":
         return [
           1.1, 0.1, -0.1, 0.0, 0.0,
           0.0, 1.0, 0.0, 0.0, 0.0,
           -0.1, 0.1, 1.1, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "BROWN":
         return [
           1.0, 0.0, 0.0, 0.0, 30.0,
           0.0, 0.9, 0.0, 0.0, 15.0,
           0.0, 0.0, 0.8, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       // --- Color / Pop ---
       case "POP2":
         return [
           1.6, -0.1, -0.1, 0.0, 0.0,
           -0.1, 1.6, -0.1, 0.0, 0.0,
           -0.1, -0.1, 1.6, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "BRIGHT":
         return [
           1.0, 0.0, 0.0, 0.0, 50.0,
           0.0, 1.0, 0.0, 0.0, 50.0,
           0.0, 0.0, 1.0, 0.0, 50.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "SAT":
         return [
           1.3, -0.15, -0.15, 0.0, 0.0,
           -0.15, 1.3, -0.15, 0.0, 0.0,
           -0.15, -0.15, 1.3, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "PASTEL":
         return [
           0.8, 0.1, 0.1, 0.0, 60.0,
           0.1, 0.8, 0.1, 0.0, 60.0,
           0.1, 0.1, 0.8, 0.0, 60.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "FRESH":
         return [
           1.0, 0.0, 0.0, 0.0, 0.0,
           0.0, 1.2, 0.0, 0.0, 10.0,
           0.0, 0.0, 1.2, 0.0, 10.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "BOOST":
         return [
           1.4, 0.0, 0.0, 0.0, -20.0,
           0.0, 1.4, 0.0, 0.0, -20.0,
           0.0, 0.0, 1.4, 0.0, -20.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "JUICY":
         return [
           1.5, 0.0, 0.0, 0.0, 20.0,
           0.0, 1.2, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       // --- Moody ---
       case "DARK":
         return [
           0.6, 0.0, 0.0, 0.0, 0.0,
           0.0, 0.6, 0.0, 0.0, 0.0,
           0.0, 0.0, 0.6, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "SHADOW":
         return [
           1.2, 0.0, 0.0, 0.0, -50.0,
           0.0, 1.2, 0.0, 0.0, -50.0,
           0.0, 0.0, 1.2, 0.0, -50.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "NIGHT":
         return [
           0.5, 0.0, 0.0, 0.0, -20.0,
           0.0, 0.5, 0.0, 0.0, -20.0,
           0.0, 0.0, 0.8, 0.0, 10.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "BLUE":
         return [
           0.7, 0.0, 0.0, 0.0, 0.0,
           0.0, 0.7, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.1, 0.0, 30.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "LOW":
         return [
           0.4, 0.0, 0.0, 0.0, 0.0,
           0.0, 0.4, 0.0, 0.0, 0.0,
           0.0, 0.0, 0.4, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "DEEP":
         return [
           1.5, 0.0, 0.0, 0.0, -40.0,
           0.0, 1.5, 0.0, 0.0, -40.0,
           0.0, 0.0, 1.5, 0.0, -40.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
       case "SAD":
         return [
           0.5, 0.2, 0.1, 0.0, -10.0,
           0.1, 0.5, 0.1, 0.0, -10.0,
           0.1, 0.2, 0.5, 0.0, -10.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];

       default:
         return [
           1.0, 0.0, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.0, 0.0, 0.0,
           0.0, 0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 0.0, 1.0, 0.0,
         ];
     }
  }
}

class RulerPainter extends CustomPainter {
  final double offset;
  RulerPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;

    final double mid = size.width / 2;
    for (int i = -40; i <= 40; i++) {
        // Dragging LEFT (offset increases) -> Ruler visuals move LEFT
        double x = mid + (i * 10.w) - (offset * 1.w);
        if (x < 0 || x > size.width) continue;
        
        double h = i % 5 == 0 ? 20.h : 10.h;
        canvas.drawLine(Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) => oldDelegate.offset != offset;
}

class CropPainter extends CustomPainter {
  final Rect rect;
  CropPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final hole = rect;

    // Draw darkened areas outside crop
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, hole.top), paint);
    canvas.drawRect(Rect.fromLTWH(0, hole.bottom, size.width, (size.height - hole.bottom)), paint);
    canvas.drawRect(Rect.fromLTWH(0, hole.top, hole.left, hole.height), paint);
    canvas.drawRect(Rect.fromLTWH(hole.right, hole.top, (size.width - hole.right), hole.height), paint);

    // Draw white border around crop area
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(hole, borderPaint);
    
    // Draw grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Vertical grid lines
    double gridX1 = hole.left + hole.width / 3;
    double gridX2 = hole.left + (hole.width * 2) / 3;
    canvas.drawLine(Offset(gridX1, hole.top), Offset(gridX1, hole.bottom), gridPaint);
    canvas.drawLine(Offset(gridX2, hole.top), Offset(gridX2, hole.bottom), gridPaint);
    
    // Horizontal grid lines
    double gridY1 = hole.top + hole.height / 3;
    double gridY2 = hole.top + (hole.height * 2) / 3;
    canvas.drawLine(Offset(hole.left, gridY1), Offset(hole.right, gridY1), gridPaint);
    canvas.drawLine(Offset(hole.left, gridY2), Offset(hole.right, gridY2), gridPaint);
    
    // Draw corner handles
    final accentPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    const double L = 20; // Longer handles for better visibility
    
    // Top-left corner
    canvas.drawLine(hole.topLeft, hole.topLeft + const Offset(L, 0), accentPaint);
    canvas.drawLine(hole.topLeft, hole.topLeft + const Offset(0, L), accentPaint);
    
    // Top-right corner
    canvas.drawLine(hole.topRight, hole.topRight + const Offset(-L, 0), accentPaint);
    canvas.drawLine(hole.topRight, hole.topRight + const Offset(0, L), accentPaint);
    
    // Bottom-left corner
    canvas.drawLine(hole.bottomLeft, hole.bottomLeft + const Offset(L, 0), accentPaint);
    canvas.drawLine(hole.bottomLeft, hole.bottomLeft + const Offset(0, -L), accentPaint);
    
    // Bottom-right corner
    canvas.drawLine(hole.bottomRight, hole.bottomRight + const Offset(-L, 0), accentPaint);
    canvas.drawLine(hole.bottomRight, hole.bottomRight + const Offset(0, -L), accentPaint);
  }

  @override
  bool shouldRepaint(CropPainter old) => old.rect != rect;
}
