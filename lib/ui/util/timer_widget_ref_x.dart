import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/timer.dart';

/// Extensions to expose [TimerState.status] changes only.
///
/// [timerNotifierProvider] provides the whole state which includes
/// [TimerState.elapsed], meaning its updates are very frequent. Using this
/// helper will result in fewer dependent `Provider` and `Widget` rebuilds if
/// only [TimerState.status] is of interest.
///
/// While it is possible to use [timerNotifierProvider] together with
/// [ProviderBase.select], requesting `status` only happens to be used pretty
/// often so it is implemented here to avoid duplication.
extension TimerWidgetRefX on WidgetRef {
  TimerStatus watchTimerStatus() {
    return watch(_timerStatusSelector);
  }

  void listenTimerStatus(void Function(TimerStatus) listener) {
    listen(_timerStatusSelector, (previous, next) => listener(next));
  }
}

final _timerStatusSelector = timerNotifierProvider.select(
  (state) => state.status,
);
