// lib/models/expiry_bucket.dart

import 'package:flutter/material.dart';

enum ExpiryBucket {
  expired,
  threeDays,
  week,
  twoWeeks,
  month,
  moreThanMonth;

  /// Determines the appropriate time bucket based on the number of
  /// remaining days.
  /// (A negative value means the item has already run out.)
  static ExpiryBucket fromRemainingDays(int days) {
    if (days < 0) return ExpiryBucket.expired;
    if (days <= 3) return ExpiryBucket.threeDays;
    if (days <= 7) return ExpiryBucket.week;
    if (days <= 14) return ExpiryBucket.twoWeeks;
    if (days <= 30) return ExpiryBucket.month;
    return ExpiryBucket.moreThanMonth;
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
        return const Color(0xFFFF6B6B); 
      case ExpiryBucket.threeDays:
        return const Color(0xFFFFB74D); 
      case ExpiryBucket.week:
        return const Color(0xFFFFE082); 
      case ExpiryBucket.twoWeeks:
        return const Color(0xFF81C784); 
      case ExpiryBucket.month:
        return const Color(0xFF90CAF9); 
      case ExpiryBucket.moreThanMonth:
        return const Color(0xFFB0BEC5);
    }
  }
}
