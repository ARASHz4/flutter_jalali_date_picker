import 'package:flutter/cupertino.dart';
import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';

class StringsText {
  static String datePickerYear(int yearIndex) => intl.NumberFormat('', 'fa').format(yearIndex);

  static String datePickerMonth(int monthIndex) =>
      JalaliDate.months[monthIndex - 1];

  static String datePickerDayOfMonth(int dayIndex) =>
      intl.NumberFormat('', 'fa').format(dayIndex);

  static String datePickerHour(int hour) =>
      intl.NumberFormat('', 'fa').format(hour);

  static String datePickerHourSemanticsLabel(int hour) => "$hour o'clock";

  static String datePickerMinute(int minute) =>
      intl.NumberFormat('', 'fa').format(minute).padLeft(2, '۰');

  static String datePickerMinuteSemanticsLabel(int minute) {
    if (minute == 1) return '1 minute';
    return '$minute minutes';
  }

  static String datePickerMediumDate(Jalali date) {
    return '${date.formatter.wN} '
        '${date.formatter.mN} '
        '${intl.NumberFormat('', 'fa').format(date.day).padRight(2)}';
  }

  static DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.mdy;

  static DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.date_time_dayPeriod;

  static String get anteMeridiemAbbreviation => 'ق.ظ';

  static String get postMeridiemAbbreviation => 'ب.ظ';

  static String get todayLabel => 'امروز';

  static String get alertDialogLabel => 'هشدار';

  static String tabSemanticsLabel(
      {required int tabIndex, required int tabCount}) {
    assert(tabIndex >= 1);
    assert(tabCount >= 1);
    return 'زبانه $tabIndex از $tabCount';
  }

  static String timerPickerHour(int hour) => hour.toString();

  static String timerPickerMinute(int minute) => minute.toString();

  static String timerPickerSecond(int second) => second.toString();

  static String timerPickerHourLabel(int? hour) => hour == 1 ? 'ساعت' : 'ساعت';

  static String timerPickerMinuteLabel(int minute) => 'دقیقه';

  static String timerPickerSecondLabel(int second) => 'ثانیه';

  static String get cutButtonLabel => 'برش';

  static String get copyButtonLabel => 'کپی';

  static String get pasteButtonLabel => 'چسباندن';

  static String get selectAllButtonLabel => 'انتخاب همه';

  static String get modalBarrierDismissLabel => 'بستن';
}
