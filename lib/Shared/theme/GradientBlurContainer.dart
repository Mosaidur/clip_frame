import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBlurBackground extends StatelessWidget {
  final Widget? child;

  const GradientBlurBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEBC894),
            Color(0xFFB49EF4),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 368.29, sigmaY: 368.29),
        child: Container(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}