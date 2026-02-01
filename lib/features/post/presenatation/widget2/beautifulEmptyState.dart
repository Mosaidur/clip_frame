import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BeautifulEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final IconData icon;

  const BeautifulEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.icon = Icons.auto_awesome_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Colors.black, // Dark background for premium feel
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated or stylized icon container
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF277F).withOpacity(0.2),
                  const Color(0xFF007CFE).withOpacity(0.2),
                ],
              ),
            ),
            child: Icon(icon, size: 80, color: const Color(0xFFFF277F)),
          ),
          const SizedBox(height: 30),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // Action Button
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007CFE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: const Color(0xFF007CFE).withOpacity(0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Try Again",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Go Back",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
