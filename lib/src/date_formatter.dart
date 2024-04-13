import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';

extension AppDate on DateTime {
  String dateToYMMMdPersian() {
    final Map<int, String> months = {
      1: "فروردین",
      2: "اردیبهشت",
      3: "خرداد",
      4: "تیر",
      5: "امرداد",
      6: "شهریور",
      7: "مهر",
      8: "آبان",
      9: "آذر",
      10: "دی",
      11: "بهمن",
      12: "اسفند",
    };

    final jalaliDate = toJalali();

    final year = intl.NumberFormat("", "fa").format(jalaliDate.year);
    final month = intl.NumberFormat("", "fa").format(jalaliDate.month);
    final monthName = months[jalaliDate.month];
    final day = intl.NumberFormat("", "fa").format(jalaliDate.day);

    return "$day ${monthName ?? month} $year";
  }

  String dateToMMMdPersian() {
    final Map<int, String> months = {
      1: "فروردین",
      2: "اردیبهشت",
      3: "خرداد",
      4: "تیر",
      5: "امرداد",
      6: "شهریور",
      7: "مهر",
      8: "آبان",
      9: "آذر",
      10: "دی",
      11: "بهمن",
      12: "اسفند",
    };

    final jalaliDate = toJalali();

    final month = intl.NumberFormat("", "fa").format(jalaliDate.month);
    final monthName = months[jalaliDate.month];
    final day = intl.NumberFormat("", "fa").format(jalaliDate.day);

    return "$day ${monthName ?? month}";
  }

  String timeToStringPersian() {
    return intl.DateFormat('hh:mm a', 'fa').format(this);
  }

  String dateTimeToStringPersian() {
    return "${dateToMMMdPersian()} ${timeToStringPersian()}";
  }

  String dateToStringWithDayPersian() {
    initializeDateFormatting();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    String dateString;

    final dateToCheck = DateTime(year, month, day);
    if (dateToCheck == today) {
      dateString = "امروز";
    } else if (dateToCheck == yesterday) {
      dateString = "دیروز";
    } else {
      dateString = intl.DateFormat('EEEE', "fa").format(this);

      if (dateString == 'جمعه') {
        dateString = 'آدینه';
      }
    }

    return dateString;
  }
}
