import 'package:flutter/material.dart';
import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DatePickerRangeScreen extends StatelessWidget {
  DatePickerRangeScreen({
    super.key,
    required this.initialDateRange,
    this.firstDate,
    this.lastDate,
  }) {
    selectedStartDate = initialDateRange.start;
    selectedEndDate = initialDateRange.end;
  }

  final JalaliRange initialDateRange;
  final Jalali? firstDate;
  final Jalali? lastDate;

  Jalali? selectedStartDate;
  Jalali? selectedEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Date")),
      body: Column(
        children: [
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PCalendarDateRangePicker(
                initialStartDate: initialDateRange.start,
                initialEndDate: initialDateRange.end,
                firstDate: firstDate ?? Jalali.min,
                lastDate: lastDate ?? Jalali.max,
                onStartDateChanged: (date) {
                  selectedStartDate = date;
                },
                onEndDateChanged: (date) {
                  selectedEndDate = date;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedStartDate != null && selectedEndDate != null) {
                      Navigator.pop(
                          context,
                          JalaliRange(
                              start: selectedStartDate!,
                              end: selectedEndDate!));
                    }
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
