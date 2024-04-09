// Copyright 2018 - 2021, Amirreza Madani. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library jalali_formatter;

import '../date_formatter.dart';
import '../jalali/jalali_date.dart';

/// Jalali date formatter class
class JalaliFormatter extends DateFormatter {
  /// make a [JalaliFormatter] from [Jalali] date
  JalaliFormatter(Jalali super.date);

  /// Jalali month names
  static const List<String> _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'امرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

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

  /// Jalali month name
  @override
  String get mN {
    return _monthNames[date.month - 1];
  }

  /// Jalali week day name
  @override
  String get wN {
    return _weekDayNames[date.weekDay - 1];
  }
}
