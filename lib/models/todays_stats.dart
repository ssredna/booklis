import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TodaysStats {
  DateTime date;
  int pagesRead;

  TodaysStats({
    required this.date,
    required this.pagesRead,
  }) {
    _resetIfNecessary();
  }

  void changePagesRead(int increase) {
    _resetIfNecessary();
    pagesRead += increase;
    if (pagesRead < 0) pagesRead = 0;
  }

  void _resetIfNecessary() {
    DateTime now = DateTime.now();
    if (daysBetween(date, now) != 0) {
      date = now;
      pagesRead = 0;
    }
  }

  TodaysStats.newDay()
      : date = DateTime.now(),
        pagesRead = 0;

  factory TodaysStats.fromPrefs(SharedPreferences prefs) {
    String? jsonString = prefs.getString('todaysStats');
    if (jsonString == null) {
      return TodaysStats.newDay();
    }
    return TodaysStats.fromJson(jsonDecode(jsonString));
  }

  factory TodaysStats.fromJson(Map<String, dynamic> map) => TodaysStats(
        date: DateTime.parse(map['date']),
        pagesRead: map['pagesRead'],
      );

  Map<String, dynamic> toJson() => {
        'date': date.toString(),
        'pagesRead': pagesRead,
      };
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}
