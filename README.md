# Jalali/Persian Date Picker

[![pub package](https://img.shields.io/pub/v/signalr_socket.svg)](https://pub.dev/packages/flutter_jalali_date_picker)

A Jalali/Persian Date Picker with Format Date to Persian for Android, iOS, macOS, Windows, Linux and Web

## Platform Support

| Android | iOS | macOS | Web | Windows | Linux |
| :-----: | :-: | :---: | :-: | :-----: | :---: |
|   ✔️    | ✔️   |  ✔️  | ✔️  |   ✔️   |  ✔️   |

## Getting Started


### Add dependency

```yaml
dependencies:
  flutter_jalali_date_picker: ^1.0.0 #latest version
```

This sample open DatePicker and return the selected DateTime

```dart
DateTime? datePicked = await jalaliDatePicker(
  context,
  initialDate: selectedDate ?? DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);
```

Format DateTime to Persian

```dart
final date = DateTime.now();

Text(date.dateToYMMMdPersian()),
Text(date.dateToMMMdPersian()),
Text(date.dateTimeToStringWithDayPersian()),
```