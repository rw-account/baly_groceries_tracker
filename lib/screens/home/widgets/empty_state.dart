// lib/screens/home/widgets/empty_state.dart

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.textTheme.bodySmall?.color;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: secondaryColor?.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مواد بعد',
            style: theme.textTheme.titleMedium?.copyWith(
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط زر اضافة مادة جديدة',
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}