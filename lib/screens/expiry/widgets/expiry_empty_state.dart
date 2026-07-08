// lib/screens/expiry/widgets/expiry_empty_state.dart

import 'package:flutter/material.dart';

/// حالة الشاشة الفارغة عندما لا توجد أي عناصر تحتاج انتباه حالياً.
class ExpiryEmptyState extends StatelessWidget {
  const ExpiryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Colors.green.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ممتاز! مخزونك في حالة آمنة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد عناصر تحتاج إلى انتباه حالياً',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
