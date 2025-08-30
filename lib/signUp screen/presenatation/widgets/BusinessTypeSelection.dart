import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/BusinessTypeSelectionController.dart';

class BusinessTypeSelectionPage extends StatelessWidget {
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
              "Business Type Selection",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Tell us what makes your business unique.",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            // Business Types (Containers)
            Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.businessTypes.map((type) {
                final isSelected = controller.selectedBusinessTypes.contains(type);
                return GestureDetector(
                  onTap: () {
                    controller.selectBusinessType(type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isSelected ? 0.5 : 0.3),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 10),
            // Selection Count Indicator
            Obx(() => Text(
              "Selected: ${controller.selectedBusinessTypes.length}/3",
              style: TextStyle(
                fontSize: 16,
                color: controller.selectedBusinessTypes.isEmpty ? Colors.red : Colors.black54,
              ),
            )),
            const SizedBox(height: 15),
            // Custom Add Field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customTypeController,
                        decoration: InputDecoration(
                          hintText: "Add custom",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.white.withOpacity(0.0),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onPressed: () {
                        final newType = customTypeController.text.trim();
                        if (newType.isNotEmpty) {
                          controller.addBusinessType(newType);
                          customTypeController.clear();
                        }
                      },
                      child: const Text("+ Add", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}