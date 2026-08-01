// lib/models/log_retention_option.dart

import 'package:jiffy/jiffy.dart';

enum LogRetentionOption {
  off,
  threeMonths,
  sixMonths,
  oneYear,
  custom,
}

extension LogRetentionOptionX on LogRetentionOption {
  String get storageValue {
    switch (this) {
      case LogRetentionOption.off:
        return 'off';
      case LogRetentionOption.threeMonths:
        return 'threeMonths';
      case LogRetentionOption.sixMonths:
        return 'sixMonths';
      case LogRetentionOption.oneYear:
        return 'oneYear';
      case LogRetentionOption.custom:
        return 'custom';
    }
  }

  static LogRetentionOption fromStorageValue(String? value) {
    switch (value) {
      case 'off':
        return LogRetentionOption.off;
      case 'threeMonths':
        return LogRetentionOption.threeMonths;
      case 'sixMonths':
        return LogRetentionOption.sixMonths;
      case 'oneYear':
        return LogRetentionOption.oneYear;
      case 'custom':
        return LogRetentionOption.custom;
      default:
        return LogRetentionOption.sixMonths;
    }
  }
}

/// Calculates the minimum retention date/time for logs.
/// The logic relies on actual elapsed time using the Jiffy library:
/// - Months/years/days are subtracted while preserving hours, minutes, and seconds.
/// - Variations in month lengths are handled automatically by Jiffy
///   (e.g., March 31 - 1 month = February 28/29).
DateTime? calculateLogRetentionCutoffDate({
  required LogRetentionOption option,
  int? customDays,
  DateTime? referenceDate,
}) {
  final effectiveReferenceDate = referenceDate ?? DateTime.now();
  final jiffy = Jiffy.parseFromDateTime(effectiveReferenceDate);

  switch (option) {
    case LogRetentionOption.off:
      return null;

    case LogRetentionOption.threeMonths:
      return jiffy.subtract(months: 3).dateTime;

    case LogRetentionOption.sixMonths:
      return jiffy.subtract(months: 6).dateTime;

    case LogRetentionOption.oneYear:
      return jiffy.subtract(years: 1).dateTime;

    case LogRetentionOption.custom:
      if (customDays == null || customDays <= 0) {
        return null;
      }
      return jiffy.subtract(days: customDays).dateTime;
  }
}
