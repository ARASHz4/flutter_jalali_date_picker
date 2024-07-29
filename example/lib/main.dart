import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';
import 'package:flutter_jalali_date_picker_example/date_picker_range_screen.dart';
import 'package:flutter_jalali_date_picker_example/date_picker_screen.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jalali Date Picker Example',
      theme: ThemeData(colorScheme: const ColorScheme.light()),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? selectedDate;
  String? label;

  @override
  Widget build(BuildContext context) {
    const itemHeight = 40.0;
    final itemWidth = (MediaQuery.of(context).size.width -
            (MediaQuery.of(context).padding.left +
                MediaQuery.of(context).padding.right)) /
        2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دیت تایم پیکر فارسی'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(8),
        physics: const AlwaysScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: (itemWidth / itemHeight),
        children: [
          TextButton(
            onPressed: () async {
              final picked = await showJalaliDatePicker(
                context,
                initialDate:
                    Jalali.fromDateTime(selectedDate ?? DateTime.now()),
                firstDate: Jalali(1385, 8),
                lastDate: Jalali(1450, 9),
                popOnSelectDate: false,
              );

              if (picked != null) {
                final pickedDateTime = picked.toDateTime();

                if (pickedDateTime != selectedDate) {
                  setState(() {
                    selectedDate = pickedDateTime;
                    label = pickedDateTime.dateToYMMMdPersian();
                  });
                }
              }
            },
            child: const Text(
              "Date Picker",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DatePickerScreen(
                            initialDate: Jalali.fromDateTime(
                                selectedDate ?? DateTime.now()),
                            firstDate: Jalali(1385, 8),
                            lastDate: Jalali(1450, 9),
                          )));

              if (picked is Jalali) {
                final pickedDateTime = picked.toDateTime();

                if (pickedDateTime != selectedDate) {
                  setState(() {
                    selectedDate = pickedDateTime;
                    label = pickedDateTime.dateToYMMMdPersian();
                  });
                }
              }
            },
            child: const Text(
              "Date Picker Widget",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DatePickerRangeScreen(
                            initialDateRange: JalaliRange(
                              start: Jalali(1403, 1, 1),
                              end: Jalali(1403, 1, 13),
                            ),
                            firstDate: Jalali(1385, 8),
                            lastDate: Jalali(1450, 9),
                          )));

              if (picked is JalaliRange) {
                setState(() {
                  label =
                      "${picked.start.toDateTime().dateToYMMMdPersian()} تا ${picked.end.toDateTime().dateToYMMMdPersian()}";
                });
              }
            },
            child: const Text(
              "Date Picker Range Widget",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showModalBottomSheet<Jalali>(
                context: context,
                builder: (context) {
                  Jalali? tempPickedDate;

                  return SizedBox(
                    height: 250,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CupertinoButton(
                              child: const Text('لغو'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoButton(
                              child: const Text('تایید'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(tempPickedDate ?? Jalali.now());
                              },
                            ),
                          ],
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        Expanded(
                          child: PCupertinoDatePicker(
                            mode: PCupertinoDatePickerMode.date,
                            initialDateTime: Jalali.fromDateTime(
                                selectedDate ?? DateTime.now()),
                            onDateTimeChanged: (Jalali dateTime) {
                              tempPickedDate = dateTime;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

              if (picked != null) {
                final pickedDateTime = picked.toDateTime();

                if (pickedDateTime != selectedDate) {
                  setState(() {
                    selectedDate = pickedDateTime;
                    label = pickedDateTime.dateToYMMMdPersian();
                  });
                }
              }
            },
            child: const Text(
              "Date Picker Cupertino",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showJalaliTimePicker(
                context,
                initialTime: TimeOfDay.now(),
                initialEntryMode: PTimePickerEntryMode.input,
                builder: (BuildContext context, Widget? child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    ),
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  label = picked.persianFormat(context);
                });
              }
            },
            child: const Text(
              "Time Picker Input Mode",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showModalBottomSheet<Jalali>(
                context: context,
                builder: (context) {
                  Jalali? tempPickedDate;

                  return SizedBox(
                    height: 250,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CupertinoButton(
                              child: const Text('لغو'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoButton(
                              child: const Text('تایید'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(tempPickedDate ?? Jalali.now());
                              },
                            ),
                          ],
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        Expanded(
                          child: PCupertinoDatePicker(
                            mode: PCupertinoDatePickerMode.dateAndTime,
                            initialDateTime: Jalali.fromDateTime(
                                selectedDate ?? DateTime.now()),
                            onDateTimeChanged: (Jalali dateTime) {
                              tempPickedDate = dateTime;
                            },
                            use24hFormat: false,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

              if (picked != null) {
                final pickedDateTime = picked.toDateTime();

                if (pickedDateTime != selectedDate) {
                  setState(() {
                    selectedDate = pickedDateTime;
                    label = pickedDateTime.dateTimeToStringPersian();
                  });
                }
              }
            },
            child: const Text(
              "Date & Time Picker Cupertino",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              Jalali? picked = await showModalBottomSheet<Jalali>(
                context: context,
                builder: (context) {
                  Jalali? tempPickedDate;
                  return SizedBox(
                    height: 250,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              child: const Text('لغو'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoButton(
                              child: const Text('تایید'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(tempPickedDate ?? Jalali.now());
                              },
                            ),
                          ],
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        Expanded(
                          child: PCupertinoDatePicker(
                            mode: PCupertinoDatePickerMode.time,
                            onDateTimeChanged: (Jalali dateTime) {
                              tempPickedDate = dateTime;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

              if (picked != null) {
                final pickedDateTime = picked.toDateTime();

                if (pickedDateTime != selectedDate) {
                  setState(() {
                    selectedDate = pickedDateTime;
                    label = picked.toJalaliDateTime();
                  });
                }
              }
            },
            child: const Text(
              "Time Picker Cupertino",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showJalaliDateRangePicker(
                context,
                initialDateRange: JalaliRange(
                  start: Jalali(1403, 1, 1),
                  end: Jalali(1403, 1, 13),
                ),
                firstDate: Jalali(1385, 8),
                lastDate: Jalali(1450, 9),
              );

              if (picked != null) {
                setState(() {
                  label =
                      "${picked.start.toDateTime().dateToYMMMdPersian()} تا ${picked.end.toDateTime().dateToYMMMdPersian()}";
                });
              }
            },
            child: const Text(
              "Range Date Picker",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              var picked = await showJalaliTimePicker(
                context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  label = picked.persianFormat(context);
                });
              }
            },
            child: const Text(
              "Time Picker",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () async {
              var picked = await showJalaliDateRangePicker(
                context,
                initialEntryMode: PDatePickerEntryMode.input,
                initialDateRange: JalaliRange(
                  start: Jalali(1403, 1, 1),
                  end: Jalali(1403, 1, 13),
                ),
                firstDate: Jalali(1385, 8),
                lastDate: Jalali(1450, 9),
              );

              if (picked != null) {
                setState(() {
                  label =
                      "${picked.start.toDateTime().dateToYMMMdPersian()} تا ${picked.end.toDateTime().dateToYMMMdPersian()}";
                });
              }
            },
            child: const Text(
              "Range Date Picker Input Mode",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: 70,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              label ?? 'انتخاب تاریخ زمان',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
