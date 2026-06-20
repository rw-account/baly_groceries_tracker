// lib/screens/home/widgets/summary_badge.dart
import 'package:flutter/material.dart';

class SummaryBadge extends StatelessWidget {
  final int urgentCount;
  final int warningCount;

  const SummaryBadge({
    super.key,
    required this.urgentCount,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (urgentCount > 0) parts.add('🔴 $urgentCount');
    if (warningCount > 0) parts.add('🟡 $warningCount');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: urgentCount > 0
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: urgentCount > 0
              ? const Color(0xFFC62828).withValues(alpha: 0.3)
              : const Color(0xFFF57F17).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        parts.join('  '),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: urgentCount > 0
              ? const Color(0xFFC62828)
              : const Color(0xFFF57F17),
        ),
      ),
    );
  }
}