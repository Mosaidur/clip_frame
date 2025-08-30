import 'package:flutter/material.dart';

// Custom selectable container
class SelectableItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool removable;
  final VoidCallback? onRemove;

  const SelectableItem({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.removable = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (removable && onRemove != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 18, color: Colors.black54),
              )
            ]
          ],
        ),
      ),
    );
  }
}