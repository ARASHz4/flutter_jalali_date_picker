import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';

/// super class for Jalali and Gregorian Date formatter
class PersianDateFormatter {
  /// stored date
  final Date date;

  /// make a [DateFormatter] for a [Date] object
  PersianDateFormatter(this.date);

  /// year number string whatever length it has
  ///
  /// [date.year] should be greater or equal 0 or exception will be thrown
  String get y {
    final int year = date.year;

    if (year < 0) {
      throw StateError('date.year = $year < 0');
    }

    return intl.NumberFormat('', 'fa').format(year);
  }

  /// year number string ensured to have length of 4
  ///
  /// [date.year] should be between 0 and 9999 or exception will be thrown
  String get yyyy {
    final int year = date.year;

    if (year < 0) {
      throw StateError('date.year = $year < 0');
    }

    if (year > 9999) {
      throw StateError('date.year = $year > 9999');
    }

    final String str = intl.NumberFormat('', 'fa').format(year);

    switch (str.length) {
      case 4:
        return str;
      case 3:
        return '۰$str';
      case 2:
        return '۰۰$str';
      case 1:
        return '۰۰۰$str';
      default: // case: 0
        return '۰۰۰۰';
    }
  }

  /// year number string ensured to have length of 2
  ///
  /// [date.year] should be between 1000 and 9999 or exception is thrown
  String get yy {
    final int year = date.year;

    if (year < 1000) {
      throw StateError('date.year = $year < 1000');
    }

    if (year > 9999) {
      throw StateError('date.year = $year > 9999');
    }

    final String str = intl.NumberFormat('', 'fa').format(year % 100);
    return str.length == 1 ? '۰$str' : str;
  }

  /// month number string whatever length it has
  String get m {
    return intl.NumberFormat('', 'fa').format(date.month);
  }

  /// month number string ensured to have length of 2
  String get mm {
    final String str = m;
    return str.length == 1 ? '۰$str' : str;
  }

  static const List<String> _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'اَمرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  /// Jalali month name
  String get mN {
    return _monthNames[date.month - 1];
  }

  /// day number string whatever length it has
  String get d {
    return intl.NumberFormat('', 'fa').format(date.day);
  }

  /// day number string ensured to have length of 2
  String get dd {
    final String str = d;
    return str.length == 1 ? '۰$str' : str;
  }

  /// Jalali week day names
  static const List<String> _weekDayNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'آدینه',
  ];

  /// Jalali week day name
  String get wN {
    return _weekDayNames[date.weekDay - 1];
  }
}
