// lib/screens/expiry/widgets/expiry_notice_card.dart

import 'package:flutter/material.dart';

/// بطاقة ملاحظة أعلى شاشة العناصر على وشك النفاد، توضّح للمستخدم أن
/// العناصر ذات الحالة الآمنة لا تظهر في هذه القائمة.
class ExpiryNoticeCard extends StatelessWidget {
  const ExpiryNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ملاحظة: تُعرض فقط المواد ذات الحالة (انتباه) أو (عاجل). المواد الآمنة لا تظهر هنا.',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
