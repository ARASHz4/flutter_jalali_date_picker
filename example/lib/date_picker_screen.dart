import 'package:flutter/material.dart';
import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DatePickerScreen extends StatelessWidget {
  DatePickerScreen({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final Jalali initialDate;
  final Jalali firstDate;
  final Jalali lastDate;

  Jalali? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Date")),
      body: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: PCalendarDatePicker(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: (value) {
                selectedDate = value;
              },
            ),
          ),
          Row(
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
                  Navigator.pop(context, selectedDate);
                },
                child: const Text("OK"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
