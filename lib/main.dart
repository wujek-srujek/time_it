import 'package:flutter/material.dart';

import 'config_page.dart';

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
      home: const ConfigPage(),
    );
  }
}
