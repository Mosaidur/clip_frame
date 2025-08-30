import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/BusinessTypeSelectionController.dart';

class BusinessDescriptionPage extends StatelessWidget {
  final BusinessTypeSelectionController controller = Get.put(BusinessTypeSelectionController());
  final TextEditingController customTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Business Description",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Describe your business in one sentence",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: "Tell us what makes your business unique.",
                // prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              maxLines: 6,
              maxLength: 500,
            ),
            const SizedBox(height: 10),
            // Suggestion (Containers)
            const Text(
              "Suggestions",
              style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.bold ,
                  color: Colors.black),
            ),
            const Text(
              "Describe your business in one sentence",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}