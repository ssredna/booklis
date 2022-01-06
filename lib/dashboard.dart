import 'package:booklis/active_book_widget.dart';
import 'package:booklis/info_header.dart';
import 'package:booklis/models/active_book.dart';
import 'package:booklis/models/read_book.dart';
import 'package:booklis/provider/reading_goal.dart';
import 'package:booklis/new_active_book_form.dart';
import 'package:booklis/read_book_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int numberOfBooks =
        Provider.of<GoalModel>(context, listen: false).numberOfBooksToRead;

    return FractionallySizedBox(
      widthFactor: 0.95,
      child: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: ListView(
          children: [
            Selector<GoalModel, int>(
              selector: (context, goalModel) => goalModel.pagesLeftToday,
              builder: (context, pagesLeftToday, child) => InfoHeader(
                pagesLeftToday: pagesLeftToday,
              ),
            ),
            Selector<GoalModel, int>(
              selector: (context, goalModel) => goalModel.pagesPerDay,
              builder: (context, pagesPerDay, child) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$pagesPerDay sider om dagen for å nå målet om $numberOfBooks bøker.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Aktive bøker:',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Selector<GoalModel, List<ActiveBook>>(
              selector: (context, goalModel) => goalModel.activeBooks,
              builder: (context, activeBooks, child) => Column(
                children: [
                  for (ActiveBook activeBook in activeBooks)
                    ActiveBookWidget(
                      key: ValueKey(activeBook.book.id),
                      activeBook: activeBook,
                    )
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(4.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const NewActiveBookForm();
                    },
                  );
                },
                label: const Text('Ny bok'),
                icon: const Icon(Icons.add),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Leste bøker:',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Selector<GoalModel, List<ReadBook>>(
              selector: (context, goalModel) => goalModel.readBooks,
              builder: (context, readBooks, child) => Column(
                children: [
                  for (ReadBook readBook in readBooks) ReadBookWidget(readBook),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
