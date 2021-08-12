import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../provider/interval_group.dart';
import '../../provider/workout_intervals.dart';
import '../widget/common/common_button.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../workout_lanucher.dart';
import 'interval_input_page.dart';
import 'intervals_setup_page.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Choose mode',
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _AmrapModeButton(),
              _StopwatchModeButton(),
              _IntervalsModeButton(),
              Expanded(
                child: SizedBox.shrink(),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            child: _VersionInfo(),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String modeName;
  final void Function() onTap;

  const _ModeButton({
    required this.modeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: CommonButton(
          onTap: onTap,
          child: FittedText(modeName),
        ),
      ),
    );
  }
}

// In this mode, a single interval is defined and the workout is finished when
// it completes. `intervalsSetupNotifierProvider` (used internally by
// `timerNotifierProvider` to get the intervals) is short-lived and created when
// the sole interval is added in `IntervalInputPage`, right before the workout
// page is pushed (see the callback below), and disposed when coming back.
class _AmrapModeButton extends ConsumerWidget {
  const _AmrapModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ModeButton(
      modeName: 'AMRAP',
      onTap: () => launchIntervalInput(
        context,
        IntervalInputDelegate(
          submitIcon: Icons.play_arrow_rounded,
          onSubmit: (intervalDefinition) {
            ref.read(workoutIntervalsProvider.notifier).state = [
              IntervalGroup.single(intervalDefinition),
            ];

            launchAmrap(context);
          },
        ),
      ),
    );
  }
}

// In this mode, there is no interval defined, the timer counts upwards and the
// workout can only be finished by the user.
class _StopwatchModeButton extends StatelessWidget {
  const _StopwatchModeButton();

  @override
  Widget build(BuildContext context) {
    return _ModeButton(
      modeName: 'Stopwatch',
      onTap: () => launchStopwatch(context),
    );
  }
}

// In this mode, potentially multiple intervals are defined and the workout is
// finished when all of them complete. `intervalsSetupNotifierProvider`'s life
// spans the whole intervals setup; `intervalInputProvider` is created and
// disposed multiple times, each time a new interval is dfined.
class _IntervalsModeButton extends StatelessWidget {
  const _IntervalsModeButton();

  @override
  Widget build(BuildContext context) {
    return _ModeButton(
      modeName: 'Intervals',
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (context) => const IntervalsSetupPage(),
        ),
      ),
    );
  }
}

class _VersionInfo extends StatefulWidget {
  const _VersionInfo();

  @override
  _VersionInfoState createState() => _VersionInfoState();
}

class _VersionInfoState extends State<_VersionInfo> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();

    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final info = snapshot.data!;

          return Opacity(
            opacity: 0.25,
            child: Text(info.version),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
