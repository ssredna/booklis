import 'package:booklis/dashboard.dart';
import 'package:booklis/provider/reading_goal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoalModel(),
      child: MaterialApp(
        title: 'Booklis',
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        home: Selector<GoalModel, bool>(
          selector: (context, goalModel) => goalModel.isLoaded,
          builder: (context, isLoaded, child) {
            return isLoaded
                ? const DashBoard()
                : const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
