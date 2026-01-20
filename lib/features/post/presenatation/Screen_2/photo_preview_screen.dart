import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'caption_generator_screen.dart';

class TextItem {
  final String id;
  String text;
  Color color;
  double fontSize;
  Offset position;
  TextAlign align;
  double rotation; // In radians
  String fontFamily;
  String backgroundStyle; // 'none', 'box', 'highlight'
  double opacity;

  TextItem({
    required this.id,
    required this.text,
    this.color = Colors.white,
    this.fontSize = 28.0,
    this.position = const Offset(0.5, 0.5),
    this.align = TextAlign.center,
    this.rotation = 0.0,
    this.fontFamily = 'Inter',
    this.backgroundStyle = 'none',
    this.opacity = 1.0,
  });
}

class PhotoPreviewScreen extends StatefulWidget {
  final String imagePath;

  const PhotoPreviewScreen({super.key, required this.imagePath});

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final GlobalKey _renderKey = GlobalKey();
  String? activeTool; // 'Filter', 'Adjust', 'Crop', 'BG', 'Split', 'Trim'
  
  // Scroll Controller for Adjust Ruler
  late ScrollController _adjustScrollController;
  bool _isChangingTool = false;
  
  // Filter States
  int selectedFilterIndex = 0;
  double filterIntensity = 0.5;
  String selectedFilterCategory = "Trending";

  // Adjust States
  String selectedAdjustTool = "Brightness";
  Map<String, double> adjustValues = {
    "Brightness": 0.0, // -0.5 to 0.5
    "Contrast": 1.0, // 0.5 to 1.5
    "Saturation": 1.0, // 0.0 to 2.0
    "Highlights": 0.0, // -0.5 to 0.5
    "Shadows": 0.0, // -0.5 to 0.5
    "Temperature": 0.0, // -0.5 to 0.5
  };

  // Crop States
  Rect cropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
  String selectedCropRatio = "Free";
  int _rotation = 0; // 0, 1, 2, 3 (0, 90, 180, 270 degrees)
  
  // Text States
  List<TextItem> textItems = [];
  String? selectedTextId;
  
  //how to work this const is rect from twm 
  final Map<String, List<Map<String, dynamic>>> filterCategories = {
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

  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _adjustScrollController = ScrollController();
    _adjustScrollController.addListener(_onAdjustScroll);
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    Image.file(File(widget.imagePath))
        .image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (mounted) {
        setState(() {
          _imageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }
    }));
  }

  @override
  void dispose() {
    _adjustScrollController.removeListener(_onAdjustScroll);
    _adjustScrollController.dispose();
    super.dispose();
  }

  void _onAdjustScroll() {
    if (_isChangingTool) return;
    
    // Ruler width is 2000.w (from -100 to 100)
    // Center (0) is at 1000.w
    double offset = _adjustScrollController.offset;
    double rulerWidth = 2000.w;
    double viewportWidth = 1.sw; // Screen width
    
    // The center of the viewport corresponds to the current value
    double centerOffset = offset + (viewportWidth / 2);
    
    // Map centerOffset [0 to rulerWidth] to displayValue [-100 to 100]
    double displayValue = ((centerOffset / rulerWidth) * 200) - 100;
    displayValue = displayValue.clamp(-100, 100);
    
    // Map displayValue [-100 to 100] back to actual adjustValue [min to max]
    double min = _getMinVal(selectedAdjustTool);
    double max = _getMaxVal(selectedAdjustTool);
    double newValue = min + ((displayValue + 100) / 200) * (max - min);
    
    setState(() {
      adjustValues[selectedAdjustTool] = newValue;
    });
  }

  void _syncScrollToValue() {
    _isChangingTool = true;
    double value = adjustValues[selectedAdjustTool]!;
    double min = _getMinVal(selectedAdjustTool);
    double max = _getMaxVal(selectedAdjustTool);
    
    // Map value [min to max] to displayValue [-100 to 100]
    double displayValue = ((value - min) / (max - min) * 200) - 100;
    
    // Map displayValue [-100 to 100] to centerOffset [0 to rulerWidth]
    double rulerWidth = 2000.w;
    double centerOffset = ((displayValue + 100) / 200) * rulerWidth;
    
    double viewportWidth = 1.sw;
    double scrollOffset = centerOffset - (viewportWidth / 2);
    
    _adjustScrollController.jumpTo(scrollOffset.clamp(0, rulerWidth - viewportWidth));
    
    Future.delayed(const Duration(milliseconds: 50), () {
      _isChangingTool = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20.sp),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Preview",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "DONE",
              style: TextStyle(
                color: const Color(0xFFFF4D8D),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: RepaintBoundary(
                                key: _renderKey,
                                child: _buildPreviewImage(constraints),
                              ),
                            ),
                          ),
                          if (activeTool == 'Crop') _buildCropOverlay(constraints),
                          if (activeTool == 'BG') _buildBGOverlay(),
                          _buildTextOverlay(constraints),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildControlSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage(BoxConstraints constraints) {
    // Match logic in _buildCropOverlay
    double availW = (constraints.maxWidth - 20.w).clamp(0.1, double.infinity);
    double availH = (constraints.maxHeight - 20.h).clamp(0.1, double.infinity);
    final renderSize = _getRenderedImageSize(availW, availH);

    Widget imageWidget = ColorFiltered(
      colorFilter: ui.ColorFilter.matrix(_getCombinedMatrix()),
      child: Image.file(
        File(widget.imagePath),
        fit: BoxFit.contain,
      ),
    );

    Widget content;
    if (activeTool == 'Crop') {
      content = imageWidget;
    } else {
      // Calculate translation to center the cropped area in the preview
      double translateX = (0.5 - (cropRect.left + cropRect.width / 2)) * renderSize.width;
      double translateY = (0.5 - (cropRect.top + cropRect.height / 2)) * renderSize.height;

      content = Center(
        child: Container(
          width: cropRect.width * renderSize.width,
          height: cropRect.height * renderSize.height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: translateX + (cropRect.width * renderSize.width / 2) - (renderSize.width / 2),
                top: translateY + (cropRect.height * renderSize.height / 2) - (renderSize.height / 2),
                width: renderSize.width,
                height: renderSize.height,
                child: imageWidget,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10.r, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: RotatedBox(
        quarterTurns: _rotation,
        child: content,
      ),
    );
  }

  List<double> _getCombinedMatrix() {
    List<double> matrix = _getInterpolatedFilterMatrix();
    
    double b = adjustValues["Brightness"]!;
    double c = adjustValues["Contrast"]!;
    double s = adjustValues["Saturation"]!;
    double h = adjustValues["Highlights"]!;
    double sh = adjustValues["Shadows"]!;
    double t = adjustValues["Temperature"]!;

    // Apply Brightness
    matrix[4] += b * 255;
    matrix[9] += b * 255;
    matrix[14] += b * 255;
    
    // Apply Contrast
    for (int i in [0, 6, 12]) {
      matrix[i] *= c;
    }
    
    // Apply Saturation
    double invSat = 1.0 - s;
    double R = 0.213 * invSat;
    double G = 0.715 * invSat;
    double B = 0.072 * invSat;

    List<double> satMatrix = [
      R + s, G, B, 0, 0,
      R, G + s, B, 0, 0,
      R, G, B + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
    matrix = _multiplyMatrices(matrix, satMatrix);

    // Apply Temperature (Warmth)
    // Warm: More Red and Green, less Blue. Cold: More Blue, less Red and Green.
    List<double> tempMatrix = [
      1.0 + t * 0.1, 0, 0, 0, 0,
      0, 1.0 + t * 0.05, 0, 0, 0,
      0, 0, 1.0 - t * 0.1, 0, 0,
      0, 0, 0, 1, 0,
    ];
    matrix = _multiplyMatrices(matrix, tempMatrix);

    // Apply Highlights & Shadows (Simplified Approximation)
    // Highlights: Boost/Cut gain in higher ranges. 
    // Shadows: Boost/Cut offset in lower ranges.
    if (h != 0 || sh != 0) {
      double hGain = 1.0 + h * 0.2;
      double sOffset = sh * 30;
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
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
    if (selectedFilterIndex == 0 && selectedFilterCategory == "Trending") return identity;
    
    final target = _getFilterMatrix(selectedFilterIndex, selectedFilterCategory);
    final result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      result[i] = identity[i] + (target[i] - identity[i]) * filterIntensity;
    }
    return result;
  }

  List<double> _getFilterMatrix(int index, String category) {
    final String name = filterCategories[category]![index]["name"];
    switch (name) {
      case "DUAL": return [1.2, 0.1, 0.1, 0.0, 0.0, 0.1, 1.1, 0.1, 0.0, 0.0, 0.1, 0.1, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "POP": return [1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "NEON": return [1.0, 0.0, 0.2, 0.0, 0.0, 0.2, 1.0, 0.0, 0.0, 0.0, 0.0, 0.2, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "FILM": return [0.9, 0.2, 0.0, 0.0, 0.0, 0.1, 0.9, 0.1, 0.0, 0.0, 0.0, 0.2, 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "GLOW": return [1.0, 0.0, 0.0, 0.0, 40.0, 0.0, 1.0, 0.0, 0.0, 40.0, 0.0, 0.0, 1.0, 0.0, 40.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "VIBE": return [1.1, 0.0, 0.0, 0.0, 10.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.0, -10.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "MOOD": return [0.9, 0.0, 0.0, 0.0, -10.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.1, 0.0, 10.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "VINTAGE": case "VINT": return [0.393, 0.769, 0.189, 0.0, 0.0, 0.349, 0.686, 0.168, 0.0, 0.0, 0.272, 0.534, 0.131, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SOFT": return [1.0, 0.4, 0.4, 0.0, 0.0, 0.4, 1.0, 0.4, 0.0, 0.0, 0.4, 0.4, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "GLITCH": return [-1.0, 0.0, 0.0, 0.0, 255.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 255.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "RGB": return [1.0, 0.5, 0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0.0, 0.0, 0.5, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SHIFT": return [1.0, 0.0, 0.2, 0.0, 0.0, 0.2, 1.0, 0.0, 0.0, 0.0, 0.0, 0.2, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "ERROR": return [-1.0, -1.0, -1.0, 0.0, 255.0, -1.0, -1.0, -1.0, 0.0, 255.0, -1.0, -1.0, -1.0, 0.0, 255.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "PIXEL": return [1.0, 0.2, 0.0, 0.0, 0.0, 0.0, 1.0, 0.2, 0.0, 0.0, 0.2, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "NOISE": return [1.0, 0.0, 0.0, 0.0, 20.0, 0.0, 1.0, 0.0, 0.0, 20.0, 0.0, 0.0, 1.0, 0.0, 20.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "WARP": return [1.5, -0.5, 0.0, 0.0, 0.0, 0.0, 1.5, -0.5, 0.0, 0.0, -0.5, 0.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SUN": return [1.1, 0.0, 0.0, 0.0, 30.0, 0.0, 0.0, 1.0, 0.0, 20.0, 0.0, 0.0, 0.9, 0.0, -10.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "WARM": return [1.2, 0.0, 0.0, 0.0, 20.0, 0.0, 1.1, 0.0, 0.0, 10.0, 0.0, 0.0, 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "COOL": return [0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 10.0, 0.0, 0.0, 1.2, 0.0, 20.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "FOG": return [0.8, 0.0, 0.0, 0.0, 50.0, 0.0, 0.8, 0.0, 0.0, 50.0, 0.0, 0.0, 0.8, 0.0, 50.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "RAIN": return [0.7, 0.0, 0.0, 0.0, 10.0, 0.0, 0.7, 0.0, 0.0, 10.0, 0.0, 0.0, 0.9, 0.0, 30.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SNOW": return [1.2, 0.0, 0.0, 0.0, 40.0, 0.0, 1.2, 0.0, 0.0, 40.0, 0.0, 0.0, 1.3, 0.0, 50.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "DUST": return [1.0, 0.2, 0.2, 0.0, 10.0, 0.2, 1.0, 0.2, 0.0, 10.0, 0.2, 0.2, 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SEPIA": return [0.393, 0.769, 0.189, 0.0, 0.0, 0.349, 0.686, 0.168, 0.0, 0.0, 0.272, 0.534, 0.131, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "RETRO": return [1.0, 0.0, 0.0, 0.0, 30.0, 0.0, 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 0.0, -20.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "FADE": return [0.9, 0.1, 0.1, 0.0, 20.0, 0.1, 0.9, 0.1, 0.0, 20.0, 0.1, 0.1, 0.9, 0.0, 20.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "OLD": return [0.7, 0.2, 0.1, 0.0, 30.0, 0.2, 0.7, 0.1, 0.0, 30.0, 0.1, 0.1, 0.7, 0.0, 30.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "FILM2": return [1.1, 0.1, -0.1, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, -0.1, 0.1, 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "BROWN": return [1.0, 0.0, 0.0, 0.0, 30.0, 0.0, 0.9, 0.0, 0.0, 15.0, 0.0, 0.0, 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "POP2": return [1.6, -0.1, -0.1, 0.0, 0.0, -0.1, 1.6, -0.1, 0.0, 0.0, -0.1, -0.1, 1.6, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "BRIGHT": return [1.0, 0.0, 0.0, 0.0, 50.0, 0.0, 1.0, 0.0, 0.0, 50.0, 0.0, 0.0, 1.0, 0.0, 50.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SAT": return [1.3, -0.15, -0.15, 0.0, 0.0, -0.15, 1.3, -0.15, 0.0, 0.0, -0.15, -0.15, 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "PASTEL": return [0.8, 0.1, 0.1, 0.0, 60.0, 0.1, 0.8, 0.1, 0.0, 60.0, 0.1, 0.1, 0.8, 0.0, 60.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "FRESH": return [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 0.0, 0.0, 10.0, 0.0, 0.0, 1.2, 0.0, 10.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "BOOST": return [1.4, 0.0, 0.0, 0.0, -20.0, 0.0, 1.4, 0.0, 0.0, -20.0, 0.0, 0.0, 1.4, 0.0, -20.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "JUICY": return [1.5, 0.0, 0.0, 0.0, 20.0, 0.0, 1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "DARK": return [0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SHADOW": return [1.2, 0.0, 0.0, 0.0, -50.0, 0.0, 1.2, 0.0, 0.0, -50.0, 0.0, 0.0, 1.2, 0.0, -50.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "NIGHT": return [0.5, 0.0, 0.0, 0.0, -20.0, 0.0, 0.5, 0.0, 0.0, -20.0, 0.0, 0.0, 0.8, 0.0, 10.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "BLUE": return [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 1.1, 0.0, 30.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "LOW": return [0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "DEEP": return [1.5, 0.0, 0.0, 0.0, -40.0, 0.0, 1.5, 0.0, 0.0, -40.0, 0.0, 0.0, 1.5, 0.0, -40.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case "SAD": return [0.5, 0.2, 0.1, 0.0, -10.0, 0.1, 0.5, 0.1, 0.0, -10.0, 0.1, 0.2, 0.5, 0.0, -10.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      default: return [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0];
    }
  }

  Widget _buildControlSection() {
    bool isCustomMode = activeTool == 'Adjust' || activeTool == 'Crop' || activeTool == 'Filter' || activeTool == 'Text';
    return Container(
      padding: EdgeInsets.only(top: isCustomMode ? 0 : 10.h, bottom: isCustomMode ? 0 : 20.h),
      decoration: BoxDecoration(
        color: isCustomMode ? const Color(0xFFE5DAFB) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10.r, offset: const Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeTool != null) ...[
            _buildToolControls(),
          ],
          if (activeTool == null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, 'retake'),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4.r, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.refresh_rounded, color: const Color(0xFF007AFF), size: 24.sp),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: ElevatedButton(
                        onPressed: _continueToCaption,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          elevation: 2,
                        ),
                        child: Text("Continue", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildToolBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          _buildToolIcon(Icons.grid_on_rounded, "BG"),
          _buildToolIcon(Icons.wb_sunny_outlined, "Adjust", onTap: () {
            setState(() => activeTool = "Adjust");
            WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollToValue());
          }),
          _buildToolIcon(Icons.crop_rounded, "Crop"),
          _buildToolIcon(Icons.style_outlined, "Filter"),
          _buildToolIcon(Icons.compare_arrows_rounded, "Split"),
          _buildToolIcon(Icons.content_cut_rounded, "Trim"),
          _buildToolIcon(Icons.text_fields_rounded, "Text"),
          _buildToolIcon(Icons.delete_outline_rounded, "Delete"),
        ],
      ),
    );
  }

  Widget _buildToolControls() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 380.h), // Slightly more height but will shrink to content
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: _buildSpecificToolControls(),
        ),
      ),
    );
  }

  Widget _buildSpecificToolControls() {
    switch (activeTool) {
      case 'Filter': return _buildFilterControls();
      case 'Adjust': return _buildAdjustControls();
      case 'Crop': return _buildCropControls();
      case 'Text': return _buildTextControls();
      case 'BG': return _buildBGControls();
      case 'Split': return _buildSplitTrimControls("Split");
      case 'Trim': return _buildSplitTrimControls("Trim");
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildTextControls() {
    return Container(
      key: const ValueKey('Text'),
      child: Column(
        children: [
          _buildTextTopBar(),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _addText,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D78),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF2D78).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text("Add Text", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (selectedTextId != null) ...[
                  SizedBox(height: 20.h),
                  _buildTextEditOptions(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTopBar() {
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
            onPressed: () => setState(() {
              activeTool = null;
              selectedTextId = null;
            }),
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
                textItems.clear();
                selectedTextId = null;
              });
            },
          ),
          Expanded(
            child: Text(
              "Text",
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
            onPressed: () => setState(() {
              activeTool = null;
              selectedTextId = null;
            }),
          ),
        ],
      ),
    );
  }

  void _addText() {
    final newItem = TextItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Tap to type",
    );
    setState(() {
      textItems.add(newItem);
      selectedTextId = newItem.id;
    });
    _showTextEditModal(newItem);
  }

  void _showTextEditModal(TextItem item) {
    TextEditingController controller = TextEditingController(text: item.text);
    final List<String> fonts = ['Inter', 'Roboto', 'Playfair Display', 'Oswald', 'Montserrat'];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog.fullscreen(
              backgroundColor: Colors.black.withOpacity(0.85),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          item.text = controller.text;
                        });
                        Navigator.pop(context);
                      },
                      child: Text("DONE", style: TextStyle(color: const Color(0xFFFF2D78), fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Alignment and Style Indicators
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAlignToggle(Icons.format_align_left_rounded, TextAlign.left, item, setModalState),
                                  _buildAlignToggle(Icons.format_align_center_rounded, TextAlign.center, item, setModalState),
                                  _buildAlignToggle(Icons.format_align_right_rounded, TextAlign.right, item, setModalState),
                                  SizedBox(width: 20.w),
                                  _buildBgStyleToggle(Icons.text_fields_rounded, 'none', item, setModalState),
                                  _buildBgStyleToggle(Icons.check_box_outline_blank_rounded, 'box', item, setModalState),
                                  _buildBgStyleToggle(Icons.highlight_rounded, 'highlight', item, setModalState),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: item.backgroundStyle == 'none' ? null : BoxDecoration(
                                    color: item.backgroundStyle == 'box' ? item.color.withOpacity(0.9) : item.color.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: TextField(
                                    controller: controller,
                                    autofocus: true,
                                    textAlign: item.align,
                                    style: TextStyle(
                                      color: item.backgroundStyle == 'box' ? (item.color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : item.color,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: item.fontFamily,
                                    ),
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter text...",
                                      hintStyle: TextStyle(color: Colors.white38),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Font Picker
                          Container(
                            height: 80.h,
                            padding: EdgeInsets.only(bottom: 30.h),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              itemCount: fonts.length,
                              itemBuilder: (context, index) {
                                bool isSelected = item.fontFamily == fonts[index];
                                return GestureDetector(
                                  onTap: () => setModalState(() => item.fontFamily = fonts[index]),
                                  child: Container(
                                    margin: EdgeInsets.only(right: 15.w),
                                    alignment: Alignment.center,
                                    child: Text(
                                      fonts[index],
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFFFF2D78) : Colors.white70,
                                        fontSize: 14.sp,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontFamily: fonts[index],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildAlignToggle(IconData icon, TextAlign alignment, TextItem item, StateSetter setModalState) {
    bool isActive = item.align == alignment;
    return IconButton(
      icon: Icon(icon, color: isActive ? const Color(0xFFFF2D78) : Colors.white70, size: 22.sp),
      onPressed: () => setModalState(() => item.align = alignment),
    );
  }

  Widget _buildBgStyleToggle(IconData icon, String style, TextItem item, StateSetter setModalState) {
    bool isActive = item.backgroundStyle == style;
    return IconButton(
      icon: Icon(icon, color: isActive ? const Color(0xFFFF2D78) : Colors.white70, size: 22.sp),
      onPressed: () => setModalState(() => item.backgroundStyle = style),
    );
  }

  Widget _buildTextEditOptions() {
    final item = textItems.firstWhere((it) => it.id == selectedTextId);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 250.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Size & Rotation", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuickActionButton(Icons.flip_to_back_rounded, "Rotate", () {
                      setState(() => item.rotation += 3.14159 / 4); // 45 deg
                    }),
                    SizedBox(width: 20.w),
                    _buildQuickActionButton(Icons.delete_sweep_rounded, "Delete", () {
                      setState(() {
                        textItems.removeWhere((it) => it.id == selectedTextId);
                        selectedTextId = null;
                      });
                    }, isDelete: true),
                  ],
                ),
              ],
            ),
        SizedBox(height: 10.h),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFFF2D78),
            inactiveTrackColor: Colors.black12,
            thumbColor: const Color(0xFFFF2D78),
            trackHeight: 2.h,
          ),
          child: Column(
            children: [
              Slider(
                value: item.fontSize,
                min: 10, max: 100,
                onChanged: (v) => setState(() => item.fontSize = v),
              ),
              Slider(
                value: item.opacity,
                min: 0.1, max: 1.0,
                onChanged: (v) => setState(() => item.opacity = v),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 35.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Colors.white, Colors.black, Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange,
              const Color(0xFFFF2D78), Colors.teal, Colors.cyan, Colors.indigo, Colors.lime, Colors.brown,
            ].map((color) => GestureDetector(
              onTap: () => setState(() => item.color = color),
              child: Container(
                width: 30.w, height: 30.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.color == color ? const Color(0xFFFF2D78) : Colors.black12, 
                    width: item.color == color ? 2.w : 1.w,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showTextEditModal(item),
              icon: Icon(Icons.edit_note_rounded, color: Colors.white, size: 20.sp),
              label: Text("Edit Text", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              ),
            ),
          ],
        ),
            ],
          ),
        ),
      );
    }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDelete ? Colors.red.withOpacity(0.1) : const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: isDelete ? Colors.red : const Color(0xFF007AFF), size: 24.sp),
          ),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      key: const ValueKey('Filter'),
      child: Column(
        children: [
          _buildFilterTopBar(),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: filterCategories.keys.map((cat) => _buildCategoryTab(cat)).toList(),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 90.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: filterCategories[selectedFilterCategory]!.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedFilterIndex == index;
                      var filter = filterCategories[selectedFilterCategory]![index];
                      return GestureDetector(
                        onTap: () => setState(() => selectedFilterIndex = index),
                        child: Container(
                          width: 70.w,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: isSelected ? Border.all(color: const Color(0xFFFF2D78), width: 2.w) : null,
                            boxShadow: [
                              if (isSelected) BoxShadow(color: const Color(0xFFFF2D78).withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(filter["image"], fit: BoxFit.cover),
                                ),
                                _buildFilterOverlay(filter["name"]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                _buildStyledSlider(filterIntensity, (v) => setState(() => filterIntensity = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTopBar() {
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
            onPressed: () => setState(() => activeTool = null),
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
                selectedFilterIndex = 0;
                filterIntensity = 1.0;
              });
            },
          ),
          Expanded(
            child: Text(
              "Filter",
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
            onPressed: () => setState(() => activeTool = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    bool isActive = selectedFilterCategory == category;
    return GestureDetector(
      onTap: () => setState(() {
        selectedFilterCategory = category;
        selectedFilterIndex = 0;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        margin: EdgeInsets.only(right: 8.w),
        child: Column(
          children: [
            Text(
              category,
              style: TextStyle(
                color: isActive ? const Color(0xFFFF2D78) : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14.sp,
              ),
            ),
            if (isActive) 
              Container(
                margin: EdgeInsets.only(top: 4.h),
                height: 3.h,
                width: 25.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D78),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOverlay(String name) {
    Color bannerColor = Colors.black54; // Default
    switch (name.toUpperCase()) {
      case "DUAL": bannerColor = const Color(0xFF4CAF50); break;
      case "VINTAGE": case "VINT": bannerColor = const Color(0xFF2196F3); break;
      case "NEON": bannerColor = const Color(0xFF00BCD4); break;
      case "FILM": case "FILM2": bannerColor = const Color(0xFF9C27B0); break;
      case "GLITCH": bannerColor = const Color(0xFFFF5722); break;
    }

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        color: bannerColor,
        child: Text(
          name.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white, 
            fontSize: 7.sp, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustControls() {
    return Container(
      key: const ValueKey('Adjust'),
      decoration: BoxDecoration(
        color: const Color(0xFFE5DAFB), // Lavender background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          _buildAdjustTopBar(),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                _buildRulerSlider(),
                SizedBox(height: 20.h),
                _buildAdjustToolList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustTopBar() {
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
            onPressed: () => setState(() => activeTool = null),
          ),
          Container(
            height: 24.h,
            width: 1.w,
            color: Colors.black12, // Vertical divider
            margin: EdgeInsets.symmetric(horizontal: 4.w),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.black54, size: 24.r),
            onPressed: () {
              setState(() {
                adjustValues[selectedAdjustTool] = _getDefaultValue(selectedAdjustTool);
              });
              _syncScrollToValue();
            },
          ),
          Expanded(
            child: Text(
              "Adjust",
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
            onPressed: () => setState(() => activeTool = null),
          ),
        ],
      ),
    );
  }

  double _getDefaultValue(String tool) {
    if (tool == "Contrast" || tool == "Saturation") return 1.0;
    return 0.0;
  }

  Widget _buildRulerSlider() {
    double value = adjustValues[selectedAdjustTool]!;
    double min = _getMinVal(selectedAdjustTool);
    double max = _getMaxVal(selectedAdjustTool);
    
    // Map value to -100 to 100 range for the UI label
    int displayValue = (((value - min) / (max - min) * 200) - 100).toInt();

    return Column(
      children: [
        SizedBox(
          height: 80.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                controller: _adjustScrollController,
                scrollDirection: Axis.horizontal,
                child: _buildRulerTicks(),
              ),
              // Pink Indicator (Fixed in center)
              IgnorePointer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$displayValue",
                      style: TextStyle(
                        fontSize: 14.sp, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFFFF2D78),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      width: 2.w,
                      height: 30.h,
                      color: const Color(0xFFFF2D78),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulerTicks() {
    return Container(
      width: 2000.w,
      height: 80.h,
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(2000.w, 80.h),
        painter: RulerPainter(),
      ),
    );
  }

  Widget _buildAdjustToolList() {
    final List<Map<String, dynamic>> tools = [
      {"name": "Brightness", "icon": Icons.wb_sunny_rounded},
      {"name": "Contrast", "icon": Icons.contrast_rounded},
      {"name": "Saturation", "icon": Icons.water_drop_rounded},
      {"name": "Highlights", "icon": Icons.highlight_rounded},
      {"name": "Shadows", "icon": Icons.wb_twilight_rounded},
      {"name": "Temperature", "icon": Icons.device_thermostat_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: tools.map((tool) {
          bool isSelected = selectedAdjustTool == tool["name"];
          return GestureDetector(
            onTap: () {
              setState(() => selectedAdjustTool = tool["name"]);
              _syncScrollToValue();
            },
            child: Container(
              width: 75.w,
              height: 75.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tool["icon"], 
                    color: isSelected ? Colors.white : const Color(0xFF007AFF), 
                    size: 28.r,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    tool["name"],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected ? Colors.white : const Color(0xFF007AFF),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  double _getMinVal(String tool) {
    if (tool == "Contrast" || tool == "Saturation") return 0.5;
    return -0.5;
  }

  double _getMaxVal(String tool) {
    if (tool == "Contrast" || tool == "Saturation") return 1.5;
    return 0.5;
  }

  Widget _buildCropControls() {
    return Container(
      key: const ValueKey('Crop'),
      child: Column(
        children: [
          _buildCropTopBar(),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: _buildCropRatioList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCropTopBar() {
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
            onPressed: () => setState(() => activeTool = null),
          ),
          Container(
            height: 24.h,
            width: 1.w,
            color: Colors.black12,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.black54, size: 24.r),
            onPressed: () => _setCropRatio(null),
          ),
          Expanded(
            child: Text(
              "Crop",
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
            onPressed: () => setState(() => activeTool = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCropRatioList() {
    final List<Map<String, dynamic>> ratios = [
      {"name": "Free", "icon": Icons.crop_free_rounded, "value": null},
      {"name": "1:1", "icon": Icons.crop_square_rounded, "value": 1.0},
      {"name": "4:3", "icon": Icons.crop_7_5_rounded, "value": 4/3},
      {"name": "3:4", "icon": Icons.crop_portrait_rounded, "value": 3/4},
      {"name": "16:9", "icon": Icons.crop_16_9_rounded, "value": 16/9},
      {"name": "9:16", "icon": Icons.crop_din_rounded, "value": 9/16},
      {"name": "Rotate", "icon": Icons.rotate_right_rounded, "value": "rotate"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: ratios.map((ratio) {
          bool isRotate = ratio["value"] == "rotate";
          bool isSelected = !isRotate && selectedCropRatio == ratio["name"];
          return GestureDetector(
            onTap: () {
              if (isRotate) {
                _rotateCrop();
              } else {
                setState(() => selectedCropRatio = ratio["name"]);
                _setCropRatio(ratio["value"]);
              }
            },
            child: Container(
              width: 75.w,
              height: 75.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ratio["icon"], 
                    color: isSelected ? Colors.white : const Color(0xFF007AFF), 
                    size: 28.r,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    ratio["name"],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected ? Colors.white : const Color(0xFF007AFF),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _rotateCrop() {
    setState(() {
      _rotation = (_rotation + 1) % 4;
      // Also adjust cropRect to fit new orientation if it was not full image
      if (cropRect.width < 0.99 || cropRect.height < 0.99) {
        double newW = cropRect.height;
        double newH = cropRect.width;
        double newLeft = (1.0 - newW) / 2;
        double newTop = (1.0 - newH) / 2;
        cropRect = Rect.fromLTWH(newLeft, newTop, newW, newH);
      }
    });
  }

  void _setCropRatio(double? ratio) {
    if (ratio == null) {
      setState(() {
        selectedCropRatio = "Free";
        cropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
      });
      return;
    }
    
    setState(() {
      double w, h;
      if (ratio >= 1.0) {
        w = 0.8;
        h = 0.8 / ratio;
      } else {
        h = 0.8;
        w = 0.8 * ratio;
      }
      // Center the crop rect
      double left = (1.0 - w) / 2;
      double top = (1.0 - h) / 2;
      cropRect = Rect.fromLTWH(left, top, w, h);
    });
  }


  Widget _buildBGControls() {
    return Column(
      key: const ValueKey('BG'),
      children: [
        Text("Background Removal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBGTab("Auto", true),
            _buildBGTab("Manual", false),
          ],
        ),
      ],
    );
  }

  Widget _buildBGTab(String label, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildSplitTrimControls(String type) {
    return Column(
      key: ValueKey(type),
      children: [
        Text("$type functionality coming soon", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
        SizedBox(height: 10.h),
        ElevatedButton(onPressed: () => setState(() => activeTool = null), child: const Text("Got it")),
      ],
    );
  }

  Widget _buildStyledSlider(double value, Function(double) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFFFF2D78),
                inactiveTrackColor: Colors.black12,
                thumbColor: const Color(0xFFFF2D78),
                overlayColor: const Color(0xFFFF2D78).withOpacity(0.2),
                trackHeight: 2.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            "${(value * 100).toInt()}%",
            style: TextStyle(
              color: const Color(0xFFFF2D78),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropOverlay(BoxConstraints constraints) {
    if (_imageSize == null) return const SizedBox.shrink();

    // Available space (same as _buildPreviewImage container)
    double availW = (constraints.maxWidth - 20.w).clamp(0.1, double.infinity);
    double availH = (constraints.maxHeight - 20.h).clamp(0.1, double.infinity);
    
    final renderSize = _getRenderedImageSize(availW, availH);
    double renderW = renderSize.width;
    double renderH = renderSize.height;
    
    double offsetX = (availW - renderW) / 2 + 10.w; // + margin
    double offsetY = (availH - renderH) / 2 + 10.h; // + margin

    Rect rect = Rect.fromLTWH(
      offsetX + cropRect.left * renderW,
      offsetY + cropRect.top * renderH,
      cropRect.width * renderW,
      cropRect.height * renderH,
    );

    return Stack(
      children: [
        Positioned(
          left: offsetX, top: offsetY,
          child: GestureDetector(
            onPanUpdate: (details) {
              double dx = details.delta.dx / renderW;
              double dy = details.delta.dy / renderH;
              setState(() {
                double left = (cropRect.left + dx).clamp(0.0, 1.0 - cropRect.width);
                double top = (cropRect.top + dy).clamp(0.0, 1.0 - cropRect.height);
                cropRect = Rect.fromLTWH(left, top, cropRect.width, cropRect.height);
              });
            },
            child: CustomPaint(
              size: Size(renderW, renderH),
              painter: CropPainter(Rect.fromLTWH(
                cropRect.left * renderW,
                cropRect.top * renderH,
                cropRect.width * renderW,
                cropRect.height * renderH,
              ), selectedCropRatio),
            ),
          ),
        ),
        _buildCropHandle(rect.topLeft, (d) => _updateCropRect(d, renderW, renderH, isTop: true, isLeft: true)),
        _buildCropHandle(rect.topRight, (d) => _updateCropRect(d, renderW, renderH, isTop: true, isLeft: false)),
        _buildCropHandle(rect.bottomLeft, (d) => _updateCropRect(d, renderW, renderH, isTop: false, isLeft: true)),
        _buildCropHandle(rect.bottomRight, (d) => _updateCropRect(d, renderW, renderH, isTop: false, isLeft: false)),
      ],
    );
  }

  Size _getRenderedImageSize(double availW, double availH) {
    if (_imageSize == null) return Size.zero;
    double imgW = _imageSize!.width;
    double imgH = _imageSize!.height;
    
    // If rotated 90 or 270 degrees, swap dimensions for aspect ratio calc
    if (_rotation % 2 != 0) {
      double temp = imgW;
      imgW = imgH;
      imgH = temp;
    }
    
    double imgAspect = imgW / imgH;
    double areaAspect = availW / availH;
    
    if (imgAspect > areaAspect) {
      return Size(availW, availW / imgAspect);
    } else {
      return Size(availH * imgAspect, availH);
    }
  }

  Widget _buildTextOverlay(BoxConstraints constraints) {
    if (_imageSize == null) return const SizedBox.shrink();

    double availW = constraints.maxWidth - 20.w;
    double availH = constraints.maxHeight - 20.h;
    final renderSize = _getRenderedImageSize(availW, availH);

    double offsetX = (availW - renderSize.width) / 2 + 10.w;
    double offsetY = (availH - renderSize.height) / 2 + 10.h;

    return Stack(
      children: textItems.map((item) {
        bool isSelected = selectedTextId == item.id;
        
        double x, y;
        if (activeTool == 'Crop') {
          x = offsetX + item.position.dx * renderSize.width;
          y = offsetY + item.position.dy * renderSize.height;
        } else {
          double relX = (item.position.dx - cropRect.left) / cropRect.width;
          double relY = (item.position.dy - cropRect.top) / cropRect.height;
          
          double containerW = cropRect.width * renderSize.width;
          double containerH = cropRect.height * renderSize.height;
          
          x = (availW - containerW) / 2 + 10.w + relX * containerW;
          y = (availH - containerH) / 2 + 10.h + relY * containerH;
          
          if (relX < 0 || relX > 1 || relY < 0 || relY > 1) return const SizedBox.shrink();
        }

        return Positioned(
          left: x - 60.w,
          top: y - 40.h,
          child: GestureDetector(
            onScaleStart: (details) {
              setState(() => selectedTextId = item.id);
            },
            onScaleUpdate: (details) {
              setState(() {
                selectedTextId = item.id;
                
                // 1. Handle Drag (Translation)
                // Note: details.focalPointDelta is useful if we want to drag while scaling
                // but we have onPanUpdate for simple drag. Let's use focalPoint for drag here too.
                
                double containerW = activeTool == 'Crop' ? renderSize.width : cropRect.width * renderSize.width;
                double containerH = activeTool == 'Crop' ? renderSize.height : cropRect.height * renderSize.height;
                
                double dx = (details.focalPointDelta.dx / containerW) * (activeTool == 'Crop' ? 1.0 : cropRect.width);
                double dy = (details.focalPointDelta.dy / containerH) * (activeTool == 'Crop' ? 1.0 : cropRect.height);

                item.position = Offset(
                  (item.position.dx + dx).clamp(0.0, 1.0),
                  (item.position.dy + dy).clamp(0.0, 1.0),
                );

                // 2. Handle Rotation
                if (details.rotation != 0) {
                  item.rotation += details.rotation;
                }

                // 3. Handle Scaling (FontSize)
                if (details.scale != 1.0) {
                  item.fontSize = (item.fontSize * details.scale).clamp(10, 200);
                }
              });
            },
            onTap: () => setState(() => selectedTextId = item.id),
            child: Transform.rotate(
              angle: item.rotation,
              child: Opacity(
                opacity: item.opacity,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: item.backgroundStyle == 'none' ? Colors.transparent : (
                      item.backgroundStyle == 'box' ? item.color.withOpacity(0.9) : item.color.withOpacity(0.4)
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                    border: isSelected ? Border.all(color: const Color(0xFFFF2D78), width: 1.5.w) : null,
                  ),
                  child: Text(
                    item.text,
                    textAlign: item.align,
                    style: TextStyle(
                      color: item.backgroundStyle == 'box' ? (item.color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : item.color,
                      fontSize: item.fontSize.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: item.fontFamily,
                      shadows: item.backgroundStyle == 'none' ? [
                        Shadow(color: Colors.black26, blurRadius: 4.r, offset: const Offset(1, 1)),
                      ] : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBGOverlay() {
    return Container(
      color: Colors.black26,
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _updateCropRect(Offset delta, double w, double h, {required bool isTop, required bool isLeft}) {
    setState(() {
      selectedCropRatio = "Custom";
      double dx = delta.dx / w;
      double dy = delta.dy / h;
      
      double left = cropRect.left;
      double top = cropRect.top;
      double width = cropRect.width;
      double height = cropRect.height;

      if (isLeft) {
        double maxDx = width - 0.1; // Min width 0.1
        double clampedDx = dx.clamp(-left, maxDx);
        left += clampedDx;
        width -= clampedDx;
      } else {
        double maxDx = 1.0 - (left + width);
        double clampedDx = dx.clamp(-(width - 0.1), maxDx);
        width += clampedDx;
      }

      if (isTop) {
        double maxDy = height - 0.1; // Min height 0.1
        double clampedDy = dy.clamp(-top, maxDy);
        top += clampedDy;
        height -= clampedDy;
      } else {
        double maxDy = 1.0 - (top + height);
        double clampedDy = dy.clamp(-(height - 0.1), maxDy);
        height += clampedDy;
      }

      cropRect = Rect.fromLTWH(left.clamp(0.0, 1.0), top.clamp(0.0, 1.0), width.clamp(0.1, 1.0), height.clamp(0.1, 1.0));
    });
  }

  Widget _buildCropHandle(Offset pos, Function(Offset) onDrag) {
    return Positioned(
      left: pos.dx - 15,
      top: pos.dy - 15,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
        width: 44, height: 44,
        color: Colors.transparent,
        child: Center(child: Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF007AFF), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
      ),
      ),
    );
  }

  Future<ui.Image> _getUiImage(File file) async {
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<String?> _saveEditedImage() async {
    if (_imageSize == null) return null;
    try {
      final originalImage = await _getUiImage(File(widget.imagePath));
      final double fullW = originalImage.width.toDouble();
      final double fullH = originalImage.height.toDouble();

      // 1. Draw filtered and rotated full image
      ui.PictureRecorder recorder = ui.PictureRecorder();
      ui.Canvas canvas = ui.Canvas(recorder);
      
      double canvasW = _rotation % 2 == 0 ? fullW : fullH;
      double canvasH = _rotation % 2 == 0 ? fullH : fullW;
      
      canvas.save();
      // Center and rotate
      canvas.translate(canvasW / 2, canvasH / 2);
      canvas.rotate(_rotation * 3.14159 / 2);
      canvas.translate(-fullW / 2, -fullH / 2);
      
      ui.Paint paint = ui.Paint()..colorFilter = ui.ColorFilter.matrix(_getCombinedMatrix());
      canvas.drawImage(originalImage, Offset.zero, paint);
      canvas.restore();
      
      ui.Image filteredFull = await recorder.endRecording().toImage(canvasW.toInt(), canvasH.toInt());

      // 2. Crop the filtered image
      ui.PictureRecorder cropRecorder = ui.PictureRecorder();
      ui.Canvas cropCanvas = ui.Canvas(cropRecorder);
      
      Rect srcRect = Rect.fromLTWH(
        cropRect.left * canvasW,
        cropRect.top * canvasH,
        cropRect.width * canvasW,
        cropRect.height * canvasH,
      );
      
      Rect dstRect = Rect.fromLTWH(0, 0, srcRect.width, srcRect.height);
      cropCanvas.drawImageRect(filteredFull, srcRect, dstRect, ui.Paint());
      
      // 3. Draw text items
      for (var item in textItems) {
        final double scale = canvasW / 1.sw;
        final textStyle = ui.TextStyle(
          color: item.backgroundStyle == 'box' ? (item.color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : item.color,
          fontSize: item.fontSize * scale,
          fontWeight: ui.FontWeight.bold,
          fontFamily: item.fontFamily,
          shadows: item.backgroundStyle == 'none' ? [
            ui.Shadow(color: Colors.black26, blurRadius: 4 * scale, offset: Offset(scale, scale)),
          ] : null,
        );
        
        final paragraphStyle = ui.ParagraphStyle(
          textAlign: item.align,
          fontSize: item.fontSize * scale,
        );
        
        final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(textStyle)
          ..addText(item.text);
        
        final paragraph = paragraphBuilder.build()
          ..layout(ui.ParagraphConstraints(width: canvasW));
        
        double textX = (item.position.dx * canvasW) - srcRect.left;
        double textY = (item.position.dy * canvasH) - srcRect.top;

        cropCanvas.save();
        // Move to the text position, rotate, then draw
        cropCanvas.translate(textX, textY);
        cropCanvas.rotate(item.rotation);
        
        // Account for Opacity
        final paint = ui.Paint()..color = Colors.white.withOpacity(item.opacity);
        cropCanvas.saveLayer(null, paint);

        // Draw Background if needed
        if (item.backgroundStyle != 'none') {
          final bgPaint = ui.Paint()
            ..color = item.backgroundStyle == 'box' ? item.color.withOpacity(0.9) : item.color.withOpacity(0.4)
            ..style = ui.PaintingStyle.fill;
          
          // Estimate box size based on paragraph
          final rect = Rect.fromLTWH(
            -8 * scale, -4 * scale, 
            paragraph.minIntrinsicWidth + 16 * scale, 
            paragraph.height + 8 * scale
          );
          cropCanvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(6 * scale)), bgPaint);
        }

        cropCanvas.drawParagraph(paragraph, Offset.zero);
        
        cropCanvas.restore(); // Restore layer
        cropCanvas.restore(); // Restore rotate/translate
      }
      
      ui.Image finalImage = await cropRecorder.endRecording().toImage(
        srcRect.width.toInt().clamp(1, canvasW.toInt()), 
        srcRect.height.toInt().clamp(1, canvasH.toInt()),
      );
      
      ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/edited_photo_${DateTime.now().millisecondsSinceEpoch}.png';
      File imgFile = File(path);
      await imgFile.writeAsBytes(pngBytes);
      
      // Clean up
      originalImage.dispose();
      filteredFull.dispose();
      finalImage.dispose();

      return path;
    } catch (e) {
      debugPrint("Error saving edited image: $e");
      return null;
    }
  }

  void _continueToCaption() async {
    final editedPath = await _saveEditedImage();
    if (editedPath != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CaptionGeneratorScreen(imagePath: editedPath),
        ),
      );
    }
  }

  Widget _buildToolIcon(IconData icon, String label, {VoidCallback? onTap}) {
    bool isActive = activeTool == label;
    return GestureDetector(
      onTap: onTap ?? () => setState(() {
        if (label == 'Delete') {
          Navigator.pop(context, 'delete');
        } else {
          if (label == 'Adjust' && !isActive) {
            _syncScrollToValue(); // Call when entering Adjust tool
          }
          activeTool = isActive ? null : label;
        }
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          children: [
            Icon(icon, color: isActive ? const Color(0xFFFF2D78) : Colors.black54, size: 24.r),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp, 
                color: isActive ? const Color(0xFFFF2D78) : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropPainter extends CustomPainter {
  final Rect rect;
  final String label;
  CropPainter(this.rect, this.label);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dim background
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
      Path()
        ..addRect(Offset.zero & size)
        ..addRect(rect)
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // 2. White main border
    canvas.drawRect(rect, Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1);

    // 3. Grid lines (Rule of Thirds)
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 0.5;
    double h3 = rect.height / 3;
    double w3 = rect.width / 3;
    
    // Vertical lines
    canvas.drawLine(Offset(rect.left + w3, rect.top), Offset(rect.left + w3, rect.bottom), gridPaint);
    canvas.drawLine(Offset(rect.left + 2 * w3, rect.top), Offset(rect.left + 2 * w3, rect.bottom), gridPaint);
    
    // Horizontal lines
    canvas.drawLine(Offset(rect.left, rect.top + h3), Offset(rect.right, rect.top + h3), gridPaint);
    canvas.drawLine(Offset(rect.left, rect.top + 2 * h3), Offset(rect.right, rect.top + 2 * h3), gridPaint);

    // 4. Accent corner markers
    final accentPaint = Paint()..color = const Color(0xFF007AFF)..style = PaintingStyle.stroke..strokeWidth = 3;
    const double L = 15;
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(L, 0), accentPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, L), accentPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-L, 0), accentPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, L), accentPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(L, 0), accentPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -L), accentPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-L, 0), accentPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -L), accentPaint);

    // 5. Ratio Label
    String displayLabel = label;
    if (label == "Custom") {
      double ratio = rect.width / rect.height;
      displayLabel = "${ratio.toStringAsFixed(2)}";
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.center.dx - textPainter.width/2, rect.top - 25));
  }

  @override
  bool shouldRepaint(CropPainter oldDelegate) => oldDelegate.rect != rect || oldDelegate.label != label;
}

class _CropClipper extends CustomClipper<Rect> {
  final Rect cropRect;
  _CropClipper(this.cropRect);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      cropRect.left * size.width,
      cropRect.top * size.height,
      cropRect.width * size.width,
      cropRect.height * size.height,
    );
  }

  @override
  bool shouldReclip(_CropClipper oldClipper) => oldClipper.cropRect != cropRect;
}

class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    List<String> labels = [];
    for (int j = -100; j <= 100; j += 20) {
      labels.add(j.toString());
    }

    // Drawing 201 ticks (from -100 to 100)
    for (int i = 0; i <= 200; i++) {
      double x = (size.width / 200) * i;
      double height = (i % 20 == 0) ? 20 : (i % 10 == 0 ? 12 : 6);
      
      // Don't draw center tick in black (it will be pink)
      if (i != 100) {
        canvas.drawLine(
          Offset(x, size.height / 2 - height / 2 + 10), // Offset down more for labels
          Offset(x, size.height / 2 + height / 2 + 10),
          paint,
        );
      }

      if (i % 20 == 0 && i != 100) {
        textPainter.text = TextSpan(
          text: labels[i ~/ 20],
          style: TextStyle(
            color: Colors.black.withOpacity(0.4), 
            fontSize: 11.sp, 
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height / 2 - 20));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
