// lib/core/widgets/delete_background.dart

import 'package:flutter/material.dart';

class DeleteBackground extends StatelessWidget {
  final AlignmentDirectional alignment;

  const DeleteBackground({
    super.key,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.delete_outline,
        color: cs.onErrorContainer,
        size: 28,
      ),
    );
  }
}
