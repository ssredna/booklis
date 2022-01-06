import 'package:uuid/uuid.dart';

Uuid uuid = const Uuid();

class Book {
  String id = uuid.v4();
  String name;
  int pages;

  Book({
    required this.name,
    required this.pages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pages': pages,
      };

  factory Book.fromJson(Map<String, dynamic> map) =>
      Book(name: map['name'], pages: map['pages']);

  @override
  String toString() {
    return 'Book{id: $id, name: $name, pages: $pages}';
  }
}
