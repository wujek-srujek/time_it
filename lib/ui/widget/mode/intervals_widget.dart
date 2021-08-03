import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/timer.dart';
import '../../../util/duration_formatter.dart';
import '../common/fitted_text.dart';
import 'mode_widget.dart';

class IntervalsWidget extends ConsumerWidget {
  const IntervalsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalInfo = ref.watchIntervalInfo();

    return ModeWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FittedText(
              formatDuration(
                intervalInfo.interval,
                forceComponent: TimeComponent.minute,
                forceComponentPadding: TimeComponent.second,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FittedText(
                    '${intervalInfo.ordinal}',
                  ),
                ),
                const Expanded(
                  child: FittedText(
                    '/',
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: FittedText(
                    '${intervalInfo.totalCount}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// **Note**: this extension is pretty much a workaround for
/// https://github.com/rrousselGit/river_pod/issues/648 and should be replaced
/// with a standard and recommended solution once fixed.

extension _IntervalInfoWidgetRefX on WidgetRef {
  IntervalInfo watchIntervalInfo() {
    // `IntervalsWidget` is only used in 'intervals' mode, which must have at
    // least one interval, so let's get rid of nullability here already.
    return watch(timerNotifierProvider.select((state) => state.intervalInfo!));
  }
}
