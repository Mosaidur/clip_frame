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
  Rect _cropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
  int _rotation = 0;

  final Map<String, List<Map<String, dynamic>>> _filterCategories = {
    "Trending": [
      {"name": "NONE"},
      {"name": "DUAL"},
      {"name": "POP"},
      {"name": "NEON"},
      {"name": "FILM"},
    ],
    "Glitch": [
      {"name": "GLITCH"},
      {"name": "RGB"},
      {"name": "SHIFT"},
      {"name": "ERROR"},
      {"name": "PIXEL"},
    ],
    "Weather": [
      {"name": "SUN"},
      {"name": "WARM"},
      {"name": "COOL"},
      {"name": "FOG"},
    ],
    "Vintage": [
      {"name": "VINT"},
      {"name": "SEPIA"},
      {"name": "RETRO"},
      {"name": "FADE"},
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
                      ),
                      if (_activeTool == StoryEditTool.crop)
                        IgnorePointer(
                          child: CustomPaint(
                            painter: CropPainter(Rect.fromLTWH(
                              _cropRect.left * (constraints.maxWidth - 40.w),
                              _cropRect.top * constraints.maxHeight,
                              _cropRect.width * (constraints.maxWidth - 40.w),
                              _cropRect.height * constraints.maxHeight,
                            )),
                            child: Container(),
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
    bool isCustomMode = _activeTool != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCustomMode ? const Color(0xFFE5DAFB) : Colors.white,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    );
  }

  Widget _toolIcon(IconData icon, String label, StoryEditTool? tool) {
    bool isActive = _activeTool == tool && tool != null;
    return GestureDetector(
      onTap: () {
        if (tool != null) {
          setState(() => _activeTool = (_activeTool == tool ? null : tool));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22.r, color: isActive ? Colors.black : Colors.black45),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.black : Colors.black45,
            ),
          ),
        ],
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
              _cropToggleItem("Format", true),
              _cropToggleItem("Rotate", false),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        // Aspect Ratios
        SizedBox(
          height: 80.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              _ratioItem(Icons.crop_free_rounded, "Original", false),
              _ratioItem(Icons.crop_square_rounded, "1:1", true),
              _ratioItem(Icons.crop_portrait_rounded, "4:5", false),
              _ratioItem(Icons.crop_16_9_rounded, "16:9", false),
              _ratioItem(Icons.smartphone_rounded, "9:16", false),
              _ratioItem(Icons.crop_3_2, "3:2", false),
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _cropToggleItem(String label, bool active) {
    return Expanded(
      child: Container(
        height: 24.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(label, style: TextStyle(fontSize: 10.sp, color: active ? Colors.white : Colors.black38, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _ratioItem(IconData icon, String label, bool active) {
    return Container(
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
    );
  }

  Widget _buildToolHeader() {
    String title = "";
    switch (_activeTool) {
      case StoryEditTool.bg: title = "Background"; break;
      case StoryEditTool.adjust: title = "Adjust"; break;
      case StoryEditTool.crop: title = "Crop"; break;
      case StoryEditTool.filter: title = "Filter"; break;
      default: break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0D6B1), // Tan background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.black54, size: 24.r),
            onPressed: () => setState(() => _activeTool = null),
          ),
          Container(
            height: 24.h,
            width: 1.w,
            color: Colors.black12,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.black54, size: 24.r),
            onPressed: () {
              setState(() {
                if (_activeTool == StoryEditTool.adjust) {
                   switch (_selectedAdjustTool) {
                     case "Brightness": _brightness = 0; break;
                     case "Contrast": _contrast = 1.0; break;
                     case "Saturation": _saturation = 1.0; break;
                     case "Highlights": _highlights = 0; break;
                     case "Shadows": _shadows = 0; break;
                     case "Temperature": _temperature = 0; break;
                   }
                }
              });
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_rounded, color: Colors.black54, size: 24.r),
            onPressed: () => setState(() => _activeTool = null),
          ),
        ],
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
    return Column(
      children: [
         // Category Tabs
         Padding(
           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: ["Movies", "Trending", "Glitch", "Weather", "Vintage"].map((cat) {
               bool active = cat == "Trending";
               return Text(
                 cat,
                 style: TextStyle(
                   color: active ? const Color(0xFFE91E63) : Colors.black38,
                   fontWeight: active ? FontWeight.bold : FontWeight.normal,
                   fontSize: 12.sp,
                 ),
               );
             }).toList(),
           ),
         ),
         // Filter Thumbnails
         SizedBox(
           height: 80.h,
           child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: 8,
              itemBuilder: (context, index) {
                bool selected = index == 1; // "VINTAGE"
                return Container(
                  width: 65.w,
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: selected ? Border.all(color: Colors.blue, width: 2.w) : null,
                    image: const DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1540189549336-e6e99c3679fe"),
                      fit: BoxFit.cover,
                    ),
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
                   child: Slider(value: 0.5, onChanged: (v){}),
                 ),
               ),
               Text("50%", style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
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
       case "DUAL": return [1.2, 0.1, 0.1, 0.0, 0.0, 0.1, 1.1, 0.1, 0.0, 0.0, 0.1, 0.1, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
       case "POP": return [1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
       case "NEON": return [1.0, 0.0, 0.2, 0.0, 0.0, 0.2, 1.0, 0.0, 0.0, 0.0, 0.0, 0.2, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
       case "GLITCH": return [-1.0, 0.0, 0.0, 0.0, 255.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 255.0, 0.0, 0.0, 0.0, 1.0, 0.0];
       case "SEPIA": case "VINT": return [0.393, 0.769, 0.189, 0.0, 0.0, 0.349, 0.686, 0.168, 0.0, 0.0, 0.272, 0.534, 0.131, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
       case "RAIN": return [0.7, 0.0, 0.0, 0.0, 10.0, 0.0, 0.7, 0.0, 0.0, 10.0, 0.0, 0.0, 0.9, 0.0, 30.0, 0.0, 0.0, 0.0, 1.0, 0.0];
       // ... simplified port of other matrices
       default: return [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0];
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

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, hole.top), paint);
    canvas.drawRect(Rect.fromLTWH(0, hole.bottom, size.width, (size.height - hole.bottom)), paint);
    canvas.drawRect(Rect.fromLTWH(0, hole.top, hole.left, hole.height), paint);
    canvas.drawRect(Rect.fromLTWH(hole.right, hole.top, (size.width - hole.right), hole.height), paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(hole, borderPaint);
    
    final accentPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    const double L = 15;
    canvas.drawLine(hole.topLeft, hole.topLeft + const Offset(L, 0), accentPaint);
    canvas.drawLine(hole.topLeft, hole.topLeft + const Offset(0, L), accentPaint);
    canvas.drawLine(hole.topRight, hole.topRight + const Offset(-L, 0), accentPaint);
    canvas.drawLine(hole.topRight, hole.topRight + const Offset(0, L), accentPaint);
    canvas.drawLine(hole.bottomLeft, hole.bottomLeft + const Offset(L, 0), accentPaint);
    canvas.drawLine(hole.bottomLeft, hole.bottomLeft + const Offset(0, -L), accentPaint);
    canvas.drawLine(hole.bottomRight, hole.bottomRight + const Offset(-L, 0), accentPaint);
    canvas.drawLine(hole.bottomRight, hole.bottomRight + const Offset(0, -L), accentPaint);
  }

  @override
  bool shouldRepaint(CropPainter old) => old.rect != rect;
}
