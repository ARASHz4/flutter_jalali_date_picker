class SolarDate {
  final _yearFourDigits = 'yyyy'; // 4 عدد سال
  final _yearTwoDigits = 'yy'; // 2 عدد سال
  final _monthTwoDigits =
      'mm'; // 2 عدد ماه اگر ماه تک رقمی باشد 0 در اول ان قرار میدهد
  final _monthOneOrTwoDigits =
      'm'; // 1 عدد ماه اگر ماه تک رقمی باشد 0 قرار نمیدهد
  final _monthFullWord = 'MM'; // ماه به صورت حروفی کامل
  final _monthShortWord = 'M'; // ماه به صورت حروفی کوتاه
  final _dayTwoDigits = 'dd'; // روز به صورت 2 عددی
  final _dayOneOrTwoDigits = 'd'; // روز به صورت تک رقمی برای روز های زیر 10
  final _weekDigit = 'w'; // عدد هفته از ماه را بر می‌گرداند
  final _dayName = 'DD'; // نام روز
  final _dayFullName = 'D'; // نام روز
  final _hour12TwoDigits =
      'hh'; // ساعت با دو رقم اگر ساعت تک رقمی باشد 0 ابتدای عدد قرار میدهد فرمت 12 ساعته
  final _hour12OneOrTwoDigits = 'h'; // ساعت با تک رقم فرمت 12 ساعته
  final _hour24TwoDigits = 'HH'; // ساعت با 2 رقم فرمت 24 ساعته
  final _hour24OneOrTwoDigits = 'H'; // ساعت با تک رقم فرمت 24 ساعته
  final _minutesTwoDigits = 'nn'; // نمایشه دقیقه به صورت دو رقمی
  final _minutesOneOrTwoDigits = 'n'; // نمایشه دقیقه به صورت تک رقمی
  final _secondsTwoDigits = 'ss'; // نمایش ثانیه دو رقمی
  final _secondsOneOrTwoDigits = 's'; // نمایش ثانیه تک رقمی
  final _millisecondsThreeDigits = 'SSS'; // نمایش میلی ثانیه
  final _millisecondsOneToThreeDigits = 'S'; // نمایش میلی ثانیه
  final _microsecondsThreeDigits = 'uuu'; // نمایش میکرو ثانیه
  final _microsecondsOneToThreeDigits = 'u'; // نمایش میکرو ثانیه
  final _timeShort = 'am'; // نمایش وقت به صورت کوتاه
  final _timeFull = 'AM'; // نمایش وقت به صورت کامل

  int? _year;
  int? _month;
  int? _day;
  int? _weekday;
  int? _hour;
  int? _minute;
  int? _second;
  int? _millisecond;
  int? _microsecond;
  String _getDate = '';
  String _getNow = '';

  String _defaultFormat = "yyyy-mm-dd hh:nn:ss SSS";

  SolarDate({String? format}) {
    if (format != null) {
      _defaultFormat = format;
    }

    _getNow = _now();
    _getDate = _now();
  }

  SolarDate.date({String? defaultFormat, String? gregorian}) {
    if (defaultFormat != null) {
      _defaultFormat = defaultFormat;
    }

    if (gregorian != null) {
      final now = DateTime.parse(gregorian);
      List list =
          gregorianToJalali(year: now.year, month: now.month, day: now.day);
      setWeekday = now.weekday;
      setYear = list[0];
      setMonth = list[1];
      setDay = list[2];
      setHour = now.hour;
      setMinute = now.minute;
      setSecond = now.second;
      setMicrosecond = now.microsecond;
      setMillisecond = now.millisecond;
      _getDate = _toFormat(_defaultFormat);
    } else {
      _getDate = _now();
    }
  }

  String get getDate => _getDate;

  String get getNow => _getNow;

  String _now() {
    final now = DateTime.now();

    List list =
        gregorianToJalali(year: now.year, month: now.month, day: now.day);
    setWeekday = now.weekday;
    setYear = list[0];
    setMonth = list[1];
    setDay = list[2];
    setHour = now.hour;
    setMinute = now.minute;
    setSecond = now.second;
    setMicrosecond = now.microsecond;
    setMillisecond = now.millisecond;

    return _toFormat(_defaultFormat);
  }

  final List<String> monthShort = const <String>[
    'فرو',
    'ارد',
    'خرد',
    'تیر',
    'امر',
    'شهر',
    'مهر',
    'آبا',
    'آذر',
    'دی',
    'بهم',
    'اسف',
  ];

  final List<String> monthLong = const <String>[
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

  final List<String> weekNameShort = const [
    'د',
    'س',
    'چ',
    'پ',
    'آ',
    'ش',
    'ی',
  ];

  ///should be same in date picker 'weekName'
  final List<String> weekNameLong = const [
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'آدینه',
    'شنبه',
    'یکشنبه',
  ];

  final List<String> solarHolidays = [
    "0101",
    "0102",
    "0103",
    "0104",
    "0112",
    "0113",
    "1229",
  ];

  gregorianToJalali(
      {required int year,
      required int month,
      required int day,
      String? separator}) {
    final sumMonthDay = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

    int jalaliYear = 0;
    if (year > 1600) {
      jalaliYear = 979;
      year -= 1600;
    } else {
      jalaliYear = 0;
      year -= 621;
    }

    int gregorianYear = (month > 2) ? year + 1 : year;
    int tempDay = (365 * year) +
        ((gregorianYear + 3) ~/ 4) -
        ((gregorianYear + 99) ~/ 100) +
        ((gregorianYear + 399) ~/ 400) -
        80 +
        day +
        sumMonthDay[month - 1];
    jalaliYear += 33 * (tempDay.round() / 12053).floor();
    tempDay %= 12053;
    jalaliYear += 4 * (tempDay.round() / 1461).floor();
    tempDay %= 1461;
    jalaliYear += ((tempDay.round() - 1) / 365).floor();

    if (tempDay > 365) {
      tempDay = ((tempDay - 1).round() % 365);
    }

    int jalaliMonth;
    int jalaliDay;
    int days = tempDay;

    if (days < 186) {
      jalaliMonth = 1 + (days ~/ 31);
      jalaliDay = 1 + (days % 31);
    } else {
      jalaliMonth = 7 + ((days - 186) ~/ 30);
      jalaliDay = 1 + (days - 186) % 30;
    }

    dynamic persianDate;
    if (separator == null) {
      persianDate = [jalaliYear, jalaliMonth, jalaliDay];
    } else {
      persianDate = "$jalaliYear$separator$jalaliMonth$separator$jalaliDay";
    }

    return persianDate;
  }

  jalaliToGregorian(
      {required int year,
      required int month,
      required int day,
      String? separator}) {
    int gregorianYear;

    if (year > 979) {
      gregorianYear = 1600;
      year -= 979;
    } else {
      gregorianYear = 621;
    }

    double days = (365 * year) +
        ((year / 33).floor() * 8) +
        (((year % 33) + 3) / 4) +
        78 +
        day +
        (((month < 7) ? (month - 1) * 31 : (((month - 7) * 30) + 186)));
    gregorianYear += 400 * (days ~/ 146097);
    days %= 146097;

    if (days.floor() > 36524) {
      gregorianYear += 100 * (--days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }

    gregorianYear += 4 * (days ~/ 1461);
    days %= 1461;
    gregorianYear += (days - 1) ~/ 365;

    if (days > 365) {
      days = (days - 1) % 365;
    }

    int gregorianDay = (days + 1).floor();
    List<int> montDays = [
      0,
      31,
      (((gregorianYear % 4 == 0) && (gregorianYear % 100 != 0)) ||
              (gregorianYear % 400 == 0))
          ? 29
          : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    int i = 0;
    for (; i <= 12; i++) {
      if (gregorianDay <= montDays[i]) {
        break;
      }

      gregorianDay -= montDays[i];
    }

    dynamic gregorianDate;
    if (separator == null) {
      gregorianDate = [gregorianYear, i, gregorianDay];
    } else {
      gregorianDate = "$gregorianYear$separator$i$separator$gregorianDay";
    }

    return gregorianDate;
  }

  parse(String formattedString, [String? separator]) {
    final parse = DateTime.parse(formattedString);
    if (separator == null) {
      List parseList = gregorianToJalali(
          year: parse.year, month: parse.month, day: parse.day);
      parseList.add(parse.hour);
      parseList.add(parse.minute);
      parseList.add(parse.second);
      return parseList;
    } else {
      return "${gregorianToJalali(year: parse.year, month: parse.month, day: parse.day, separator: separator)} ${parse.hour}:${parse.minute}:${parse.second}";
    }
  }

  String get weekDayName => weekNameLong[weekday! - 1];

  String get monthName => monthLong[month! - 1];

  int? get year => _year;

  set setYear(int value) {
    _year = value;
  }

  int? get month => _month;

  set setMonth(int value) {
    _month = value;
  }

  int? get day => _day;

  set setDay(int value) {
    _day = value;
  }

  int? get weekday => _weekday;

  set setWeekday(int? value) {
    _weekday = value;
  }

  int? get hour => _hour;

  set setHour(int? value) {
    _hour = value;
  }

  int? get minute => _minute;

  bool get isHoliday {
    if (weekday == 5) {
      return true;
    } else if (solarHolidays
        .contains("${_digits(month, 2)}${_digits(day, 2)}")) {
      return true;
    } else {
      return false;
    }
  }

  set setMinute(int? value) {
    _minute = value;
  }

  int? get second => _second;

  set setSecond(int? value) {
    _second = value;
  }

  int? get microsecond => _microsecond;

  set setMicrosecond(int? value) {
    _microsecond = value;
  }

  int? get millisecond => _millisecond;

  set setMillisecond(int? value) {
    _millisecond = value;
  }

  _toFormat(String format) {
    String newFormat = format;
    if (newFormat.contains(_yearFourDigits)) {
      newFormat = newFormat.replaceFirst(_yearFourDigits, _digits(year, 4));
    }

    if (newFormat.contains(_yearTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_yearTwoDigits, _digits(year! % 100, 2));
    }

    if (newFormat.contains(_monthTwoDigits)) {
      newFormat = newFormat.replaceFirst(_monthTwoDigits, _digits(month, 2));
    }

    if (newFormat.contains(_monthOneOrTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_monthOneOrTwoDigits, month.toString());
    }

    if (newFormat.contains(_monthFullWord)) {
      newFormat = newFormat.replaceFirst(_monthFullWord, monthLong[month! - 1]);
    }

    if (newFormat.contains(_monthShortWord)) {
      newFormat =
          newFormat.replaceFirst(_monthShortWord, monthShort[month! - 1]);
    }

    if (newFormat.contains(_dayTwoDigits)) {
      newFormat = newFormat.replaceFirst(_dayTwoDigits, _digits(day, 2));
    }

    if (newFormat.contains(_dayOneOrTwoDigits)) {
      newFormat = newFormat.replaceFirst(_dayOneOrTwoDigits, day.toString());
    }

    if (newFormat.contains(_weekDigit)) {
      newFormat =
          newFormat.replaceFirst(_weekDigit, ((day! + 7) ~/ 7).toString());
    }

    if (newFormat.contains(_dayName)) {
      newFormat = newFormat.replaceFirst(_dayName, weekNameLong[weekday! - 1]);
    }

    if (newFormat.contains(_dayFullName)) {
      newFormat =
          newFormat.replaceFirst(_dayFullName, weekNameShort[weekday! - 1]);
    }

    if (newFormat.contains(_hour24TwoDigits)) {
      newFormat = newFormat.replaceFirst(_hour24TwoDigits, _digits(hour, 2));
    }

    if (newFormat.contains(_hour24OneOrTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_hour24OneOrTwoDigits, hour.toString());
    }

    if (newFormat.contains(_hour12TwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_hour12TwoDigits, _digits(hour! % 12, 2));
    }

    if (newFormat.contains(_hour12OneOrTwoDigits)) {
      newFormat = newFormat.replaceFirst(
          _hour12OneOrTwoDigits, (hour! % 12).toString());
    }

    if (newFormat.contains(_timeFull)) {
      newFormat = newFormat.replaceFirst(
          _timeFull, hour! < 12 ? 'قبل از ظهر' : 'بعد از ظهر');
    }

    if (newFormat.contains(_timeShort)) {
      newFormat =
          newFormat.replaceFirst(_timeShort, hour! < 12 ? 'ق.ظ' : 'ب.ظ');
    }

    if (newFormat.contains(_minutesTwoDigits)) {
      newFormat = newFormat.replaceFirst(_minutesTwoDigits, _digits(minute, 2));
    }

    if (newFormat.contains(_minutesOneOrTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_minutesOneOrTwoDigits, minute.toString());
    }

    if (newFormat.contains(_secondsTwoDigits)) {
      newFormat = newFormat.replaceFirst(_secondsTwoDigits, _digits(second, 2));
    }

    if (newFormat.contains(_secondsOneOrTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_secondsOneOrTwoDigits, second.toString());
    }

    if (newFormat.contains(_millisecondsThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _millisecondsThreeDigits, _digits(millisecond, 3));
    }

    if (newFormat.contains(_millisecondsOneToThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _millisecondsOneToThreeDigits, millisecond.toString());
    }

    if (newFormat.contains(_microsecondsThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _microsecondsThreeDigits, _digits(microsecond, 2));
    }

    if (newFormat.contains(_microsecondsOneToThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _microsecondsOneToThreeDigits, microsecond.toString());
    }

    return newFormat;
  }

  String parseToFormat({required String dateString, String? format}) {
    final date = DateTime.parse(dateString);
    final jalaliDate =
        gregorianToJalali(year: date.year, month: date.month, day: date.day);
    format ??= _defaultFormat;

    String newFormat = format;

    if (newFormat.contains(_yearFourDigits)) {
      newFormat =
          newFormat.replaceFirst(_yearFourDigits, _digits(jalaliDate[0], 4));
    }

    if (newFormat.contains(_yearTwoDigits)) {
      newFormat = newFormat.replaceFirst(
          _yearTwoDigits, _digits(jalaliDate[0] % 100, 2));
    }

    if (newFormat.contains(_monthTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_monthTwoDigits, _digits(jalaliDate[1], 2));
    }

    if (newFormat.contains(_monthOneOrTwoDigits)) {
      newFormat = newFormat.replaceFirst(
          _monthOneOrTwoDigits, jalaliDate[1].toString());
    }

    if (newFormat.contains(_monthFullWord)) {
      newFormat =
          newFormat.replaceFirst(_monthFullWord, monthLong[jalaliDate[1] - 1]);
    }

    if (newFormat.contains(_monthShortWord)) {
      newFormat = newFormat.replaceFirst(
          _monthShortWord, monthShort[jalaliDate[1] - 1]);
    }

    if (newFormat.contains(_dayTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_dayTwoDigits, jalaliDate[2].toString());
    }

    if (newFormat.contains(_dayOneOrTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_dayOneOrTwoDigits, _digits(jalaliDate[2], 2));
    }

    if (newFormat.contains(_weekDigit)) {
      newFormat = newFormat.replaceFirst(
          _weekDigit, ((jalaliDate[2] + 7) ~/ 7).toString());
    }

    if (newFormat.contains(_dayName)) {
      newFormat =
          newFormat.replaceFirst(_dayName, weekNameLong[date.weekday - 1]);
    }

    if (newFormat.contains(_dayFullName)) {
      newFormat =
          newFormat.replaceFirst(_dayFullName, weekNameShort[date.weekday - 1]);
    }

    if (newFormat.contains(_hour24TwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_hour24TwoDigits, _digits(date.hour, 2));
    }

    if (newFormat.contains(_hour24OneOrTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_hour24OneOrTwoDigits, date.hour.toString());
    }

    if (newFormat.contains(_hour12TwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_hour12TwoDigits, _digits(date.hour % 12, 2));
    }

    if (newFormat.contains(_hour12OneOrTwoDigits)) {
      newFormat = newFormat.replaceFirst(
          _hour12OneOrTwoDigits, (date.hour % 12).toString());
    }

    if (newFormat.contains(_timeFull)) {
      newFormat = newFormat.replaceFirst(
          _timeFull, date.hour < 12 ? 'قبل از ظهر' : 'بعد از ظهر');
    }

    if (newFormat.contains(_timeShort)) {
      newFormat =
          newFormat.replaceFirst(_timeShort, date.hour < 12 ? 'ق.ظ' : 'ب.ظ');
    }

    if (newFormat.contains(_minutesTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_minutesTwoDigits, _digits(date.minute, 2));
    }

    if (newFormat.contains(_minutesOneOrTwoDigits)) {
      newFormat = newFormat.replaceFirst(
          _minutesOneOrTwoDigits, date.minute.toString());
    }

    if (newFormat.contains(_secondsTwoDigits)) {
      newFormat =
          newFormat.replaceFirst(_secondsTwoDigits, _digits(date.second, 2));
    }

    if (newFormat.contains(_secondsOneOrTwoDigits)) {
      newFormat = newFormat.replaceFirst(
          _secondsOneOrTwoDigits, date.second.toString());
    }

    if (newFormat.contains(_millisecondsThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _millisecondsThreeDigits, _digits(date.millisecond, 3));
    }

    if (newFormat.contains(_millisecondsOneToThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _millisecondsOneToThreeDigits, date.millisecond.toString());
    }

    if (newFormat.contains(_microsecondsThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _microsecondsThreeDigits, _digits(date.microsecond, 2));
    }

    if (newFormat.contains(_microsecondsOneToThreeDigits)) {
      newFormat = newFormat.replaceFirst(
          _microsecondsOneToThreeDigits, date.microsecond.toString());
    }

    return newFormat;
  }

  String _digits(int? value, int length) {
    String ret = '$value';
    if (ret.length < length) {
      ret = '0' * (length - ret.length) + ret;
    }

    return ret;
  }
}
