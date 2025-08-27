import 'package:flutter/material.dart';

class LanguageToggleButton extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageToggleButton({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton> {
  late bool isEn;

  @override
  void initState() {
    super.initState();
    isEn = widget.currentLanguage == 'En';
  }

  void toggleLanguage() {
    setState(() {
      isEn = !isEn;
    });
    widget.onLanguageChanged(isEn ? 'En' : 'Es');
  }

  @override
  Widget build(BuildContext context) {
    // Make the toggle size relative to screen width for responsiveness
    final width = MediaQuery.of(context).size.width * 0.13; // ~52px on standard screens
    final height = width * 0.63; // ~33px
    final handleSize = width * 0.52; // ~27px
    final borderRadius = height / 2;

    return GestureDetector(
      onTap: toggleLanguage,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFF277F), // always pink
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isEn ? 4 : width - handleSize - 4,
              top: (height - handleSize) / 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: handleSize,
                height: handleSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  isEn ? 'En' : 'Es',
                  style: TextStyle(
                    color: const Color(0xFFFF277F), // selected text color
                    fontWeight: FontWeight.bold,
                    fontSize: handleSize * 0.44, // scalable font
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
