import 'package:booklis/provider/reading_goal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoHeader extends StatelessWidget {
  final int pagesLeftToday;

  const InfoHeader({
    Key? key,
    required this.pagesLeftToday,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onLongPress: () {
            Provider.of<GoalModel>(context, listen: false).clearToday();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Du må lese',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                pagesLeftToday.toString(),
                style: Theme.of(context).textTheme.headline1,
              ),
              Text(
                'sider i dag',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
