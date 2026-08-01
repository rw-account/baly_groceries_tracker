// lib/models/log_retention_option.dart

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

DateTime? calculateLogRetentionCutoffDate({
  required LogRetentionOption option,
  int? customDays,
  DateTime? referenceDate,
}) {

  final effectiveReferenceDate = referenceDate ?? DateTime.now();

  switch (option) {
    case LogRetentionOption.off:
      return null;
    case LogRetentionOption.threeMonths:
      return DateTime(
        effectiveReferenceDate.year,
        effectiveReferenceDate.month - 3,
        effectiveReferenceDate.day,
      );
    case LogRetentionOption.sixMonths:
      return DateTime(
        effectiveReferenceDate.year,
        effectiveReferenceDate.month - 6,
        effectiveReferenceDate.day,
      );
    case LogRetentionOption.oneYear:
      return DateTime(
        effectiveReferenceDate.year - 1,
        effectiveReferenceDate.month,
        effectiveReferenceDate.day,
      );
    case LogRetentionOption.custom:
      if (customDays == null || customDays <= 0) {
        return null;
      }
      return DateTime(
        effectiveReferenceDate.year,
        effectiveReferenceDate.month,
        effectiveReferenceDate.day - customDays,
      );
  }
}
