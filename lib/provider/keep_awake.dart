import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// A simple service to keep the device awake.
///
/// It exists to not have to call static methods which will help with testing,
/// and also to make it available using a provider.
class KeepAwake {
  void enable() => unawaited(WakelockPlus.enable());
  void disable() => unawaited(WakelockPlus.disable());
}

final keepAwakeProvider = Provider((ref) => KeepAwake());
