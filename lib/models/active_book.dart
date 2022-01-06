import 'dart:convert';

import 'package:booklis/models/book.dart';

class ActiveBook {
  Book book;
  int _pagesRead;
  DateTime startDate;

  ActiveBook({
    required this.book,
    required int pagesRead,
    required this.startDate,
  }) : _pagesRead = pagesRead;

  int get pagesRead => _pagesRead;
  set pagesRead(int newPagesRead) =>
      _pagesRead = newPagesRead > book.pages ? book.pages : newPagesRead;

  factory ActiveBook.fromJson(Map<String, dynamic> json) => ActiveBook(
        book: Book.fromJson(json['book']),
        pagesRead: json['pagesRead'],
        startDate: DateTime.parse(json['startDate']),
      );

  Map<String, dynamic> toJson() => {
        'book': book.toJson(),
        'pagesRead': pagesRead,
        'startDate': startDate.toString(),
      };

  static List<ActiveBook> decode(String activeBooksString) =>
      (jsonDecode(activeBooksString) as List<dynamic>)
          .map((map) => ActiveBook.fromJson(map))
          .toList();
}
