// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get searchHint => 'ابحث عن مادة...';

  @override
  String get noResultsFound => 'لا توجد نتائج مطابقة';

  @override
  String errorMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get addButtonLabel => 'إضافة';
}
