import 'package:riverpod/riverpod.dart';
import 'package:wakelock/wakelock.dart';

/// A simple service to keep the device awake.
///
/// It exists to not have to call static methods which will help with testing,
/// and also to make it available using a provider.
class KeepAwake {
  void enable() => Wakelock.enable();
  void disable() => Wakelock.disable();
}

final keepAwakeProvider = Provider((ref) => KeepAwake());
