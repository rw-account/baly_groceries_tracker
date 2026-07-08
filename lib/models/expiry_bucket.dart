// lib/models/expiry_bucket.dart

import 'package:flutter/material.dart';

/// فئات تجميع العناصر حسب عدد الأيام المتبقية على انتهائها، مع بيانات
/// العرض (العنوان، الأيقونة، اللون) الخاصة بكل فئة.
///
/// ملاحظة: ترتيب القيم في التعريف أدناه هو نفسه ترتيب عرضها في الواجهة
/// (من الأكثر إلحاحاً إلى الأقل)، لذا يمكن الاعتماد مباشرة على
/// `ExpiryBucket.values` عند بناء الأقسام في الشاشة دون الحاجة لأي
/// ترتيب إضافي.
enum ExpiryBucket {
  expired,
  threeDays,
  week,
  twoWeeks,
  month,
  moreThanMonth;

  /// يحدد الفئة الزمنية المناسبة بناءً على عدد الأيام المتبقية.
  /// (قيمة سالبة تعني أن العنصر قد نفد بالفعل).
  static ExpiryBucket fromRemainingDays(int days) {
    if (days < 0) return ExpiryBucket.expired;
    if (days <= 3) return ExpiryBucket.threeDays;
    if (days <= 7) return ExpiryBucket.week;
    if (days <= 14) return ExpiryBucket.twoWeeks;
    if (days <= 30) return ExpiryBucket.month;
    return ExpiryBucket.moreThanMonth;
  }

  String get label {
    switch (this) {
      case ExpiryBucket.expired:
        return '❌ نفدت';
      case ExpiryBucket.threeDays:
        return 'ينتهي خلال 3 أيام';
      case ExpiryBucket.week:
        return 'ينتهي خلال أسبوع';
      case ExpiryBucket.twoWeeks:
        return 'ينتهي خلال أسبوعين';
      case ExpiryBucket.month:
        return 'ينتهي خلال شهر';
      case ExpiryBucket.moreThanMonth:
        return 'ينتهي بعد أكثر من شهر';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpiryBucket.expired:
        return Icons.warning_amber_rounded;
      case ExpiryBucket.threeDays:
        return Icons.access_time_rounded;
      case ExpiryBucket.week:
        return Icons.calendar_today_rounded;
      case ExpiryBucket.twoWeeks:
        return Icons.date_range_rounded;
      case ExpiryBucket.month:
        return Icons.calendar_month_rounded;
      case ExpiryBucket.moreThanMonth:
        return Icons.event_available_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpiryBucket.expired:
        return const Color(0xFFE53935); // أحمر
      case ExpiryBucket.threeDays:
        return const Color(0xFFFB8C00); // برتقالي
      case ExpiryBucket.week:
        return const Color(0xFFF9A825); // أصفر
      case ExpiryBucket.twoWeeks:
        return const Color(0xFF7CB342); // أخضر فاتح
      case ExpiryBucket.month:
        return const Color(0xFF42A5F5); // أزرق فاتح
      case ExpiryBucket.moreThanMonth:
        return const Color(0xFF78909C); // رمادي مزرق
    }
  }
}
