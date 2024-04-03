import 'package:flutter/material.dart';
import 'package:flutter_jalali_date_picker/flutter_jalali_date_picker.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Jalali Date Picker Example"),
      ),
      body: Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  DateTime? datePicked = await jalaliDatePicker(
                    context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  if (datePicked != null) {
                    setState(() {
                      selectedDate = datePicked;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("برگزیدن تاریخ"),
              ),

              if (selectedDate != null)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(selectedDate!.dateToYMMMdPersian()),
                    Text(selectedDate!.dateToMMMdPersian()),
                    Text(selectedDate!.dateTimeToStringWithDayPersian()),
                  ],
                ),
            ],
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
