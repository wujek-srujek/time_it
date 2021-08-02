import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../provider/intervals_setup.dart';
import '../widget/common/common_button.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/countdown_timer_widget.dart';
import '../widget/mode/menu_items.dart';
import '../widget/mode/rounds_widget.dart';
import '../widget/mode/stopwatch_widget.dart';
import 'interval_input_page.dart';
import 'intervals_setup_page.dart';
import 'workout_page.dart';

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
  final Widget targetPage;
  final Object? arguments;

  const _ModeButton({
    required this.modeName,
    required this.targetPage,
    this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: CommonButton(
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (context) => targetPage,
                settings: RouteSettings(
                  arguments: arguments,
                ),
              ),
            );
          },
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
      targetPage: const IntervalInputPage(),
      arguments: OnIntervalInputCompletedDelegate(
        icon: Icons.play_arrow_rounded,
        callback: (intervalDefinition) {
          ref
              .read(intervalsSetupNotifierProvider.notifier)
              .add(intervalDefinition);

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const WorkoutPage(
                topWidget: RoundsWidget(),
                bottomWidget: CountdownTimerWidget(),
                menuItems: [
                  RestartMenuButton(),
                  RoundSummaryMenuButton(),
                ],
              ),
            ),
          );
        },
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
    return const _ModeButton(
      modeName: 'Stopwatch',
      targetPage: WorkoutPage(
        topWidget: RoundsWidget(),
        bottomWidget: StopwatchWidget(),
        menuItems: [
          RestartMenuButton(),
          RoundSummaryMenuButton(),
        ],
      ),
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
    return const _ModeButton(
      modeName: 'Intervals',
      targetPage: IntervalsSetupPage(),
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
