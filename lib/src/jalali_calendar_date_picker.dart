import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';
import 'package:intl/intl.dart' as intl;

/// Initial display mode of the date picker dialog.
///
/// Date picker UI mode for either showing a list of available years or a
/// monthly calendar initially in the dialog shown by calling [showDatePicker].
///
/// Also see:
///
///  * <https://material.io/guidelines/components/pickers.html#pickers-date-pickers>
enum DatePickerMode {
  /// Show a date picker UI for choosing a month and day.
  day,

  /// Show a date picker UI for choosing a year.
  year,
}

const double _kDatePickerHeaderPortraitHeight = 100.0;
const double _kDatePickerHeaderLandscapeWidth = 168.0;

const Duration _kMonthScrollDuration = Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

const double _kMonthPickerPortraitWidth = 330.0;
const double _kMonthPickerLandscapeWidth = 344.0;

const double _kDialogActionBarHeight = 52.0;
const double _kDatePickerLandscapeHeight =
    _kMaxDayPickerHeight + _kDialogActionBarHeight;

// Shows the selected date in large font and toggles between year and day mode
class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    required this.selectedDate,
    required this.mode,
    required this.onModeChanged,
    required this.orientation,
  });

  final DateTime selectedDate;
  final DatePickerMode mode;
  final ValueChanged<DatePickerMode> onModeChanged;
  final Orientation orientation;

  void _handleChangeMode(DatePickerMode value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme headerTextTheme = themeData.primaryTextTheme;
    SolarDate solarDate = SolarDate.date(gregorian: selectedDate.toString());

    Color? dayColor;
    Color? yearColor;
    switch (themeData.brightness) {
      case Brightness.light:
        dayColor = mode == DatePickerMode.day ? Colors.black87 : Colors.black54;
        yearColor =
            mode == DatePickerMode.year ? Colors.black87 : Colors.black54;
        break;
      case Brightness.dark:
        dayColor = mode == DatePickerMode.day ? Colors.white : Colors.white70;
        yearColor = mode == DatePickerMode.year ? Colors.white : Colors.white70;
        break;
    }

    final TextStyle dayStyle = headerTextTheme.bodyLarge!
        .copyWith(color: dayColor, height: 1.4, fontSize: 23.0);
    final TextStyle yearStyle =
        headerTextTheme.titleSmall!.copyWith(color: yearColor, height: 1.4);

    Color backgroundColor = themeData.colorScheme.secondary;

    double? width;
    double? height;
    EdgeInsets? padding;
    late MainAxisAlignment mainAxisAlignment;
    switch (orientation) {
      case Orientation.portrait:
        height = _kDatePickerHeaderPortraitHeight;
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Orientation.landscape:
        width = _kDatePickerHeaderLandscapeWidth;
        padding = const EdgeInsets.all(8.0);
        mainAxisAlignment = MainAxisAlignment.start;
        break;
    }

    final Widget yearButton = IgnorePointer(
      ignoring: mode != DatePickerMode.day,
      child: _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.year), context),
        child: Semantics(
          selected: mode == DatePickerMode.year,
          child: Text(intl.NumberFormat("", "fa").format(solarDate.year),
              style: yearStyle),
        ),
      ),
    );

    final Widget dayButton = IgnorePointer(
      ignoring: mode == DatePickerMode.day,
      child: _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.day), context),
        child: Semantics(
          selected: mode == DatePickerMode.day,
          child: Text(
              "${solarDate.weekDayName}, ${intl.NumberFormat("", "fa").format(solarDate.day)} ${solarDate.monthName}",
              style: dayStyle),
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[yearButton, dayButton],
        ),
      ),
    );
  }
}

class _DateHeaderButton extends StatelessWidget {
  const _DateHeaderButton({
    this.onTap,
    this.color,
    this.child,
  });

  final VoidCallback? onTap;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      type: MaterialType.button,
      color: color,
      child: InkWell(
        borderRadius: kMaterialEdges[MaterialType.button],
        highlightColor: theme.highlightColor,
        splashColor: theme.splashColor,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(_kDayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _kDayPickerGridDelegate = _DayPickerGridDelegate();

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
///
/// The day picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker].
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
class DayPicker extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  DayPicker({
    super.key,
    required this.selectedDate,
    required this.currentDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate) ||
            selectedDate.isAtSameMomentAs(firstDate));

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  ///
  ///
  static List<String> weekName = const [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'آدینه',
  ];

  static List<String> dayH = const [
    'ش',
    'ی',
    'د',
    'س',
    'چ',
    'پ',
    'آ',
  ];

  List<Widget> _getDayHeaders() {
    final List<Widget> result = <Widget>[];
    for (String dayHeader in dayH) {
      result.add(ExcludeSemantics(
        child: Center(child: Text(dayHeader)),
      ));
    }
    return result;
  }

  static const List<int> _daysInMonth = <int>[
    31,
    31,
    31,
    31,
    31,
    31,
    30,
    30,
    30,
    30,
    30,
    -1
  ];

// if mode year on 33 equal one of kabise array year is kabise
  static const List<int> _kabise = <int>[1, 5, 9, 13, 17, 22, 26, 30];

  static int getDaysInMonth(int year, int? month) {
    final modeYear = year % 33;
    if (month == 12) {
      return _kabise.contains(modeYear) ? 30 : 29;
    }

    return _daysInMonth[month! - 1];
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [DateTime.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  final SolarDate date = SolarDate.date();

  String _digits(int? value, int length) {
    String ret = '$value';

    if (ret.length < length) {
      ret = '0' * (length - ret.length) + ret;
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int mDay = displayedMonth.day;

    final SolarDate getPearData =
        SolarDate.date(gregorian: displayedMonth.toString());
    final SolarDate selectedSolarDate =
        SolarDate.date(gregorian: selectedDate.toString());

    final SolarDate currentPDate =
        SolarDate.date(gregorian: currentDate.toString());

    final List<Widget> labels = <Widget>[];

    final pDay = _digits(mDay, 2);
    final gMonth = _digits(month, 2);

    final parseP = date.parse("$year-$gMonth-$pDay");

    final jalaliToGregorianData =
        date.jalaliToGregorian(year: parseP[0], month: parseP[1], day: 01);

    final pMonth = _digits(jalaliToGregorianData[1], 2);

    SolarDate solarDate = SolarDate.date(
        gregorian:
            "${jalaliToGregorianData[0]}-$pMonth-${jalaliToGregorianData[2]}");
    final daysInMonth = getDaysInMonth(solarDate.year!, solarDate.month);
    final startDay = weekName.indexOf(solarDate.weekDayName);

    labels.addAll(_getDayHeaders());

    for (int i = 0; true; i += 1) {
      final int day = i - startDay + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(Container());
      } else {
        final pDay = _digits(day, 2);
        final jtgData = date.jalaliToGregorian(
            year: getPearData.year!,
            month: getPearData.month!,
            day: int.parse(pDay));
        final DateTime dayToBuild =
            DateTime(jtgData[0], jtgData[1], jtgData[2]);
        final SolarDate getHoliday =
            SolarDate.date(gregorian: dayToBuild.toString());

        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate!(dayToBuild));

        BoxDecoration? decoration;
        TextStyle? itemStyle = themeData.textTheme.bodyLarge;

        final bool isSelectedDay = selectedSolarDate.year == getPearData.year &&
            selectedSolarDate.month == getPearData.month &&
            selectedSolarDate.day == day;

        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.textTheme.bodyMedium;
          decoration = BoxDecoration(
              color: themeData.colorScheme.secondary, shape: BoxShape.circle);
        } else if (disabled) {
          itemStyle = themeData.textTheme.bodyLarge!
              .copyWith(color: themeData.disabledColor);
        } else if (currentPDate.year == getPearData.year &&
            currentPDate.month == getPearData.month &&
            currentPDate.day == day) {
          // The current day gets a different text color.
          itemStyle = themeData.textTheme.bodyMedium!
              .copyWith(color: themeData.colorScheme.secondary);
        } else if (getHoliday.isHoliday) {
          // The current day gets a different text color.
          itemStyle =
              themeData.textTheme.bodyMedium!.copyWith(color: Colors.red);
        }

        Widget dayWidget = Container(
          decoration: decoration,
          child: Center(
            child: Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              child: ExcludeSemantics(
                child: Text(intl.NumberFormat("", "fa").format(day),
                    style: itemStyle),
              ),
            ),
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onChanged(dayToBuild);
            },
            child: dayWidget,
          );
        }

        labels.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            SizedBox(
              height: _kDayPickerRowHeight,
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    "${solarDate.monthName} ${intl.NumberFormat("", "fa").format(parseP[0])}",
                    style: themeData.textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            Flexible(
              child: GridView.custom(
                gridDelegate: _kDayPickerGridDelegate,
                childrenDelegate: SliverChildListDelegate(labels,
                    addRepaintBoundaries: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrollable list of months to allow picking a month.
///
/// Shows the days of each month in a rectangular grid with one column for each
/// day of the week.
///
/// The month picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker]
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
class MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  MonthPicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate) ||
            selectedDate.isAtSameMomentAs(firstDate));

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a month.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _chevronOpacityTween =
      Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();

    // Setup the fade animation for chevrons
    _chevronOpacityController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _chevronOpacityAnimation =
        _chevronOpacityController.drive(_chevronOpacityTween);
  }

  @override
  void didUpdateWidget(MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  late MaterialLocalizations localizations;
  late TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
  }

  late DateTime _todayDate;
  late DateTime _currentDisplayedMonthDate;
  Timer? _timer;
  PageController? _dayPickerController;
  late AnimationController _chevronOpacityController;
  late Animation<double> _chevronOpacityAnimation;

  void _updateCurrentDate() {
    _todayDate = DateTime.now();
    final DateTime tomorrow =
        DateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding

    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  static int _monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// Add months to a month truncated date.
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  Widget _buildItems(BuildContext context, int index) {
    DateTime month = _addMonthsToMonthDate(widget.firstDate, index);
    final SolarDate selectedPersianDate = SolarDate.date(
        gregorian: widget.selectedDate.toString()); // To Edit Month Display

    if (selectedPersianDate.day! >= 1 && selectedPersianDate.day! < 12) {
      month = _addMonthsToMonthDate(widget.firstDate, index + 1);
    }

    return DayPicker(
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_nextMonthDate), textDirection);
      _dayPickerController!
          .nextPage(duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_previousMonthDate), textDirection);
      _dayPickerController!
          .previousPage(duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate
        .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  late DateTime _previousMonthDate;
  late DateTime _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kMonthPickerPortraitWidth,
      height: _kMaxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: _MonthPickerSortKey.calendar,
            child: NotificationListener<ScrollStartNotification>(
              onNotification: (_) {
                _chevronOpacityController.forward();
                return false;
              },
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _chevronOpacityController.reverse();
                  return false;
                },
                child: PageView.builder(
                  controller: _dayPickerController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
                  itemBuilder: _buildItems,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.previousMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.nextMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

// Defines semantic traversal order of the top-level widgets inside the month
// picker.
class _MonthPickerSortKey extends OrdinalSortKey {
  const _MonthPickerSortKey(super.order);

  static const _MonthPickerSortKey previousMonth = _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = _MonthPickerSortKey(3.0);
}

/// A scrollable list of years to allow picking a year.
///
/// The year picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [showDatePicker]
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
class YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [selectedDate] and [onChanged] arguments must not be null. The
  /// [lastDate] must be after the [firstDate].
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  YearPicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
  }) : assert(!firstDate.isAfter(lastDate));

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  @override
  State<YearPicker> createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  static const double _itemExtent = 50.0;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      // Move the initial scroll position to the currently selected date's year.
      initialScrollOffset:
          (widget.selectedDate.year - widget.firstDate.year) * _itemExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle? style = themeData.textTheme.bodyLarge;

    return ListView.builder(
      controller: scrollController,
      itemExtent: _itemExtent,
      itemCount: widget.lastDate.year - widget.firstDate.year + 1,
      itemBuilder: (BuildContext context, int index) {
        final int year = widget.firstDate.year + index;
        final bool isSelected = year == widget.selectedDate.year;
        var date =
            DateTime(year, widget.selectedDate.month, widget.selectedDate.day);
        var pYear = SolarDate.date(gregorian: date.toString());
        final TextStyle? itemStyle = isSelected
            ? themeData.textTheme.bodyLarge!
                .copyWith(color: themeData.colorScheme.secondary)
            : style;

        return InkWell(
          key: ValueKey<int>(year),
          onTap: () {
            widget.onChanged(DateTime(
                year, widget.selectedDate.month, widget.selectedDate.day));
          },
          child: Center(
            child: Semantics(
              selected: isSelected,
              child: Text(intl.NumberFormat("", "fa").format(pYear.year),
                  style: itemStyle),
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.initialDatePickerMode,
    required this.popOnSelectDate,
  });

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final DatePickerMode? initialDatePickerMode;
  final bool popOnSelectDate;

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  bool _announcedInitialDate = false;

  late MaterialLocalizations localizations;
  late TextDirection textDirection;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _mode = widget.initialDatePickerMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        localizations.formatFullDate(_selectedDate!),
        textDirection,
      );
    }
  }

  DateTime? _selectedDate;
  DatePickerMode? _mode;
  final GlobalKey _pickerKey = GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
      default:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();

    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(
            localizations.formatMonthYear(_selectedDate!), textDirection);
      } else {
        SemanticsService.announce(
            localizations.formatYear(_selectedDate!), textDirection);
      }
    });
  }

  void _handleYearChanged(DateTime value) {
    _vibrate();

    setState(() {
      _mode = DatePickerMode.day;
      _selectedDate = value;
    });
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();

    setState(() {
      _selectedDate = value;
    });

    if (widget.popOnSelectDate) {
      Navigator.pop(context, _selectedDate);
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() async {
    Navigator.pop(context, _selectedDate);
  }

  Widget? _buildPicker() {
    assert(_mode != null);
    switch (_mode!) {
      case DatePickerMode.day:
        return MonthPicker(
          key: _pickerKey,
          selectedDate: _selectedDate!,
          onChanged: _handleDayChanged,
          firstDate: widget.firstDate!,
          lastDate: widget.lastDate!,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return YearPicker(
          key: _pickerKey,
          selectedDate: _selectedDate!,
          onChanged: _handleYearChanged,
          firstDate: widget.firstDate!,
          lastDate: widget.lastDate!,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget picker = Flexible(
      child: SizedBox(
        height: _kMaxDayPickerHeight,
        child: _buildPicker(),
      ),
    );

    final Widget actions = ButtonBar(
      children: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text("لغو"),
        ),
        TextButton(
          onPressed: _handleOk,
          child: const Text("تایید"),
        ),
      ],
    );

    final Dialog dialog = Dialog(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final Widget header = _DatePickerHeader(
            selectedDate: _selectedDate!,
            mode: _mode!,
            onModeChanged: _handleModeChanged,
            orientation: orientation,
          );
          switch (orientation) {
            case Orientation.portrait:
              return SizedBox(
                width: _kMonthPickerPortraitWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    header,
                    Container(
                      color: theme.dialogBackgroundColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          picker,
                          if (!widget.popOnSelectDate) actions,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            case Orientation.landscape:
              return SizedBox(
                height: _kDatePickerLandscapeHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    Flexible(
                      child: Container(
                        width: _kMonthPickerLandscapeWidth,
                        color: theme.dialogBackgroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            picker,
                            if (!widget.popOnSelectDate) actions,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }
}

/// Signature for predicating dates for enabled date selections.
///
/// See [showDatePicker].
typedef SelectableDayPredicate = bool Function(DateTime day);

/// Shows a dialog containing a material design date picker.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user closes the dialog. If the user cancels the dialog, null is returned.
///
/// An optional [selectableDayPredicate] function can be passed in to customize
/// the days to enable for selection. If provided, only the days that
/// [selectableDayPredicate] returned true for will be selectable.
///
/// An optional [initialDatePickerMode] argument can be used to display the
/// date picker initially in the year or month+day picker mode. It defaults
/// to month+day, and must not be null.
///
/// An optional [locale] argument can be used to set the locale for the date
/// picker. It defaults to the ambient locale provided by [Localizations].
///
/// An optional [textDirection] argument can be used to set the text direction
/// (RTL or LTR) for the date picker. It defaults to the ambient text direction
/// provided by [Directionality]. If both [locale] and [textDirection] are not
/// null, [textDirection] overrides the direction chosen for the [locale].
///
/// The `context` argument is passed to [showDialog], the documentation for
/// which discusses how it is used.
///
/// See also:
///
///  * [showTimePicker]
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
Future<DateTime?> jalaliDatePicker(
  BuildContext context, {
  SelectableDayPredicate? selectableDayPredicate,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  TextDirection textDirection = TextDirection.rtl,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  bool popOnSelectDate = false,
}) async {
  assert(selectableDayPredicate == null || selectableDayPredicate(initialDate),
      'Provided initialDate must satisfy provided selectableDayPredicate');
  assert(debugCheckHasMaterialLocalizations(context));

  Widget child = Directionality(
    textDirection: textDirection,
    child: _DatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      initialDatePickerMode: initialDatePickerMode,
      popOnSelectDate: popOnSelectDate,
    ),
  );

  return await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) => child,
  );
}
