import 'dart:collection';
import 'dart:convert';

import 'package:booklis/models/active_book.dart';
import 'package:booklis/models/read_book.dart';
import 'package:booklis/models/todays_stats.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalModel extends ChangeNotifier {
  late final SharedPreferences _prefs;
  bool _isLoaded = false;

  final DateTime _deadline = DateTime(2023);
  final int _numberOfBooksToRead = 14;
  final int _avgPageCount = 350;

  TodaysStats _todaysStats = TodaysStats.newDay();
  List<ActiveBook> _activeBooks = [];
  List<ReadBook> _readBooks = [];

  UnmodifiableListView<ActiveBook> get activeBooks =>
      UnmodifiableListView(_activeBooks);
  UnmodifiableListView<ReadBook> get readBooks =>
      UnmodifiableListView(_readBooks);
  int get numberOfBooksToRead => _numberOfBooksToRead;
  bool get isLoaded => _isLoaded;
  int get pagesPerDay => _calculatePagesPerDay();
  int get pagesLeftToday {
    int pagesLeft = pagesPerDay - _todaysStats.pagesRead;
    return pagesLeft >= 0 ? pagesLeft : 0;
  }

  GoalModel() {
    _loadPrefs();
  }

  void addActiveBook(ActiveBook activeBook) {
    _activeBooks = [..._activeBooks, activeBook];
    _prefs.setString('activeBooks', jsonEncode(_activeBooks));
    notifyListeners();
  }

  void finishBook(ActiveBook activeBook) {
    final ReadBook readBook = ReadBook(
      book: activeBook.book,
      startDate: activeBook.startDate,
      endDate: DateTime.now(),
    );
    _readBooks = [..._readBooks, readBook];

    _activeBooks = [..._activeBooks]
      ..removeWhere((cActiveBook) => cActiveBook.book.id == activeBook.book.id);

    _prefs.setString('activeBooks', jsonEncode(_activeBooks));
    _prefs.setString('readBooks', jsonEncode(_readBooks));

    notifyListeners();
  }

  void changePagesReadInBook(ActiveBook activeBook, int newPagesRead) {
    final int increase = newPagesRead - activeBook.pagesRead;

    activeBook.pagesRead = newPagesRead;
    _todaysStats.changePagesRead(increase);

    _prefs.setString('todaysStats', jsonEncode(_todaysStats));
    _prefs.setString('activeBooks', jsonEncode(_activeBooks));

    notifyListeners();
  }

  void clearToday() {
    _todaysStats = TodaysStats.newDay();
    _prefs.setString('todaysStats', jsonEncode(_todaysStats));
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    await _initPrefs();
    _getPrefItems();
    _isLoaded = true;
    notifyListeners();
  }

  int _calculatePagesPerDay() {
    int totalPagesToRead = _totalPagesToRead();
    int daysUntilDeadline = daysBetween(DateTime.now(), _deadline);
    return (totalPagesToRead / daysUntilDeadline).ceil();
  }

  int _totalPagesToRead() {
    int pagesLeftInActiveBooks = _activeBooks.isNotEmpty
        ? _activeBooks
            .map((activeBook) => activeBook.book.pages - activeBook.pagesRead)
            .reduce((pagesLeftTotal, pagesLeftInBook) =>
                pagesLeftTotal + pagesLeftInBook)
        : 0;
    int unknownBooksLeft =
        _numberOfBooksToRead - activeBooks.length - readBooks.length;
    int pagesLeftInUnknownBooks =
        unknownBooksLeft >= 0 ? unknownBooksLeft * _avgPageCount : 0;
    return pagesLeftInActiveBooks + pagesLeftInUnknownBooks;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _getPrefItems() {
    _todaysStats = TodaysStats.fromPrefs(_prefs);
    _activeBooks = _activeBooksFromPrefs();
    _readBooks = _readBooksFromPrefs();
  }

  List<ActiveBook> _activeBooksFromPrefs() {
    final String? jsonString = _prefs.getString('activeBooks');
    if (jsonString == null) {
      return [];
    }
    return ActiveBook.decode(jsonString);
  }

  List<ReadBook> _readBooksFromPrefs() {
    final String? jsonString = _prefs.getString('readBooks');
    if (jsonString == null) {
      return [];
    }
    return ReadBook.decode(jsonString);
  }
}
