import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interval_config_page.dart';
import 'player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Player.init();

  runApp(TimeItApp());
}

class TimeItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Time it',
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const IntervalConfigPage(),
      ),
    );
  }
}
