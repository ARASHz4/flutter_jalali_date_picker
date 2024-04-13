# Jalali/Persian Date Picker

[![pub package](https://img.shields.io/pub/v/signalr_socket.svg)](https://pub.dev/packages/flutter_jalali_date_picker)

A Jalali/Persian Date Time Picker with Format Date to Persian for Android, iOS, macOS, Windows, Linux and Web

This project Based on https://pub.dev/packages/persian_datetime_picker

## Platform Support

| Android | iOS | macOS | Web | Windows | Linux |
| :-----: | :-: | :---: | :-: | :-----: | :---: |
|   ✔️    | ✔️   |  ✔️  | ✔️  |   ✔️   |  ✔️   |

## Getting Started


### Add dependency

```yaml
dependencies:
  flutter_jalali_date_picker: ^2.1.0 #latest version
```

This sample open DatePicker and return the selected Date

```dart
Jalali? picked = await showJalaliDatePicker(
  context,
  initialDate: Jalali.now(),
  firstDate: Jalali(1385, 8),
  lastDate: Jalali(1450, 9),
);
```

Format DateTime to Persian

```dart
final date = DateTime.now();

date.dateToYMMMdPersian();
date.dateToMMMdPersian();
date.dateToStringWithDayPersian();
```