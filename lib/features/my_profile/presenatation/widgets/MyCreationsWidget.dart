import 'package:flutter/material.dart';


class MyCreationsWidget extends StatelessWidget {
  const MyCreationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      "https://picsum.photos/200/300?1",
      "https://picsum.photos/200/300?2",
      "https://picsum.photos/200/300?3",
      "https://picsum.photos/200/300?4",
      "https://picsum.photos/200/300?5",
    ];
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: images
            .map((img) => SizedBox(
          width: (width / 3.2) - 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(img, fit: BoxFit.cover),
          ),
        ))
            .toList(),
      ),
    );
  }
}