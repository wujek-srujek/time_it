import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/player.dart';
import 'ui/page/mode_selection_page.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await Firebase.initializeApp();

      if (kDebugMode) {
        // Report crashes in release mode only.
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false);
      }
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      await Player.init();

      runApp(TimeItApp());
    },
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack),
  );
}

class TimeItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Time it',
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const ModeSelectionPage(),
      ),
    );
  }
}
