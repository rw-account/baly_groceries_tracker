import 'package:home_orders_tracker/providers/locale_provider.dart';

String formatRelativeDate(
  DateTime date, {
  DateTime? now,
}) {
  final locale = LocaleNotifier.currentLanguage;
  now ??= DateTime.now();

  final isFuture = date.isAfter(now);
  final start = isFuture ? now : date;
  final end = isFuture ? date : now;

  final startDate = DateTime(start.year, start.month, start.day);
  final endDate = DateTime(end.year, end.month, end.day);

  final diff = _calendarDifference(startDate, endDate);

  if (diff.years == 0 && diff.months == 0 && diff.days == 0) {
    return locale == 'en' ? 'today' : 'اليوم';
  }

  final parts = <String>[];

  if (diff.years > 0) {
    parts.add(_formatUnit(
      diff.years,
      locale: locale,
      singularEn: 'year',
      pluralEn: 'years',
      singularAr: 'سنة',
      dualAr: 'سنتين',
      pluralAr: 'سنوات',
      oneAr: 'واحدة',
      accusativeAr: 'سنة',
  ));
}

  if (diff.months > 0) {
    parts.add(_formatUnit(
      diff.months,
      locale: locale,
      singularEn: 'month',
      pluralEn: 'months',
      singularAr: 'شهر',
      dualAr: 'شهرين',
      pluralAr: 'أشهر',
      oneAr: 'واحد',
      accusativeAr: 'شهر',
    ));
  }

  if (diff.days > 0) {
    parts.add(_formatUnit(
      diff.days,
      locale: locale,
      singularEn: 'day',
      pluralEn: 'days',
      singularAr: 'يوم',
      dualAr: 'يومين',
      pluralAr: 'أيام',
      oneAr: 'واحد',
      accusativeAr: 'يوم',
    ));
  }

  final text = _joinParts(parts, locale);

  return isFuture
      ? (locale == 'en' ? 'in $text' : 'بعد $text')
      : (locale == 'en' ? '$text ago' : 'منذ $text');
}

class _DateDiff {
  final int years;
  final int months;
  final int days;

  const _DateDiff({
    required this.years,
    required this.months,
    required this.days,
  });
}

_DateDiff _calendarDifference(DateTime start, DateTime end) {
  var years = end.year - start.year;
  var cursor = _addYears(start, years);

  if (cursor.isAfter(end)) {
    years--;
    cursor = _addYears(start, years);
  }

  var months = (end.year - cursor.year) * 12 + (end.month - cursor.month);
  var cursor2 = _addMonths(cursor, months);

  if (cursor2.isAfter(end)) {
    months--;
    cursor2 = _addMonths(cursor, months);
  }

  final days = end.difference(cursor2).inDays;

  return _DateDiff(years: years, months: months, days: days);
}

DateTime _addYears(DateTime date, int years) {
  final year = date.year + years;
  final month = date.month;
  final day = _clampDay(year, month, date.day);

  return DateTime(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = (date.year * 12) + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = (totalMonths % 12) + 1;
  final day = _clampDay(year, month, date.day);

  return DateTime(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

int _clampDay(int year, int month, int day) {
  final maxDay = _daysInMonth(year, month);
  return day > maxDay ? maxDay : day;
}

int _daysInMonth(int year, int month) {
  final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
  final thisMonth = DateTime(year, month, 1);
  return nextMonth.difference(thisMonth).inDays;
}

String _formatUnit(
  int value, {
  required String locale,
  required String singularEn,
  required String pluralEn,
  required String singularAr,
  required String dualAr,
  required String pluralAr,
  required String oneAr,
  String? accusativeAr,
}) {
  if (locale == 'en') {
    return '$value ${value == 1 ? singularEn : pluralEn}';
  }

  // -------- العربية --------
  if (value == 1) return '$singularAr $oneAr';
  if (value == 2) return dualAr;
  if (value <= 10) return '$value $pluralAr';
  
  // 11 فأكثر: تمييز مفرد منصوب
  final word = accusativeAr ?? singularAr;
  return '$value $word';
}

String _joinParts(List<String> parts, String locale) {
  if (parts.isEmpty) {
    return locale == 'en' ? '0 days' : '0 أيام';
  }

  if (parts.length == 1) return parts.first;
  if (parts.length == 2) {
    return locale == 'en'
        ? '${parts[0]} and ${parts[1]}'
        : '${parts[0]} و ${parts[1]}';
  }

  final head = parts.sublist(0, parts.length - 1).join(locale == 'en' ? ', ' : ' و ');
  final last = parts.last;

  return locale == 'en' ? '$head and $last' : '$head و $last';
}