// lib/screens/home/widgets/empty_state.dart

import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';

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
            context.loc.emptyStateTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.emptyStateSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}