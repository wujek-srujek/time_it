import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/player.dart';
import 'ui/page/mode_selection_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  // The following Crashlytics setup means:
  // 1. The default of automatically reporting crashes is used.
  // 2. Flutter errors are handled in non-debug modes only (because only then
  //  are error handlers installed).
  // 3. Native errors are handled in all modes. To disable it, either change
  //  native configuration (in Info.plist and AndroidManifest.xml) for debug,
  //  or call __outside of the if block___
  //  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)
  //  It is important to call it outside of the if block because this setting is
  //  stored on the phone and shared between all modes, so developing in debug
  //  mode and disabling this, and then subsequently installing in release mode
  //  without reenabling it would not report crashes automatically.
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (exception, stackTrace) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace);

      return true;
    };
  }

  await Player.init();

  runApp(ProviderScope(child: TimeItApp()));
}

class TimeItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time it',
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2196F3),
          error: Colors.red,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const ModeSelectionPage(),
    );
  }
}
