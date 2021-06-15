import 'package:flutter/material.dart';

void main() {
  runApp(TimeItApp());
}

class TimeItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time it',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Container(),
      ),
    );
  }
}
