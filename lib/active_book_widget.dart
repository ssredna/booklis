import 'package:booklis/models/active_book.dart';
import 'package:booklis/provider/reading_goal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveBookWidget extends StatefulWidget {
  final ActiveBook activeBook;

  const ActiveBookWidget({
    Key? key,
    required this.activeBook,
  }) : super(key: key);

  @override
  State<ActiveBookWidget> createState() => _ActiveBookWidgetState();
}

class _ActiveBookWidgetState extends State<ActiveBookWidget> {
  int _readPages = 0;
  int _percentage = 0;

  @override
  void initState() {
    super.initState();
    _readPages = widget.activeBook.pagesRead;
    _percentage = _readPages * 100 ~/ widget.activeBook.book.pages;
  }

  void _onSliderChange(double newCount) {
    setState(() {
      _readPages = newCount.toInt();
    });
  }

  void _onSliderChangeEnd(double newCount) {
    Provider.of<GoalModel>(context, listen: false)
        .changePagesReadInBook(widget.activeBook, newCount.toInt());
    setState(() {
      _percentage = newCount * 100 ~/ widget.activeBook.book.pages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {},
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.activeBook.book.name,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Text(
                            '$_readPages / ${widget.activeBook.book.pages}',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 35,
                      child: _percentage != 100
                          ? Text(
                              '$_percentage %',
                              style: Theme.of(context).textTheme.headline2,
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Provider.of<GoalModel>(context, listen: false)
                                    .finishBook(widget.activeBook);
                              },
                              child: Text(
                                'FERDIG',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                    ),
                  ],
                ),
                Slider(
                  value: _readPages.toDouble(),
                  onChanged: _onSliderChange,
                  onChangeEnd: _onSliderChangeEnd,
                  min: 0,
                  max: widget.activeBook.book.pages.toDouble(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
