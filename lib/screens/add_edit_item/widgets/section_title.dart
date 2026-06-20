// lib/screens/add_edit_item/widgets/section_title.dart

import 'package:flutter/material.dart';

/// عنوان قسم مع أيقونة + نص بخط عريض.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        // Expanded + ellipsis يمنعان تجاوز النص لحدود الشاشة (overflow) عند
        // استخدام عنوان طويل أو على شاشات ضيقة.
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // اذا النص طويل جدًا، يظهر "..." بدل تجاوز الشاشة
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
