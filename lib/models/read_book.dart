import 'dart:convert';

import 'package:booklis/models/book.dart';

class ReadBook {
  Book book;
  DateTime startDate;
  DateTime endDate;

  ReadBook({
    required this.book,
    required this.startDate,
    required this.endDate,
  });

  factory ReadBook.fromJson(Map<String, dynamic> json) => ReadBook(
        book: Book.fromJson(json['book']),
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
      );

  Map<String, dynamic> toJson() => {
        'book': book.toJson(),
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
      };

  static List<ReadBook> decode(String readBooksString) =>
      (jsonDecode(readBooksString) as List<dynamic>)
          .map<ReadBook>((map) => ReadBook.fromJson(map))
          .toList();
}
