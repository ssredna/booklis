import 'package:booklis/models/read_book.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadBookWidget extends StatelessWidget {
  final ReadBook readBook;

  const ReadBookWidget(this.readBook, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {},
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 65,
                      child: Text(
                        readBook.book.name,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Expanded(
                      flex: 35,
                      child: Text(
                        '${readBook.book.pages} sider',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${DateFormat.MMMd().format(readBook.startDate)} - ${DateFormat.MMMd().format(readBook.endDate)}',
                  style: Theme.of(context).textTheme.headline5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
