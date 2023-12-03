import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widget/common/common_button.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../workout_launcher.dart';
import 'interval_input_page.dart';
import 'intervals_setup_page.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage();

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Choose mode',
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AmrapModeButton(),
              _StopwatchModeButton(),
              _IntervalsModeButton(),
              Expanded(
                child: SizedBox.shrink(),
              ),
            ],
          ),
          Positioned(
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
      onTap: () async => launchIntervalInput(
        context,
        IntervalInputDelegate(
          submitIcon: Icons.play_arrow_rounded,
          onSubmit: (intervalDefinition) async {
            return launchAmrap(ref, intervalDefinition);
          },
        ),
      ),
    );
  }
}

// In this mode, there is no interval defined, the timer counts upwards and the
// workout can only be finished by the user.
class _StopwatchModeButton extends ConsumerWidget {
  const _StopwatchModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ModeButton(
      modeName: 'Stopwatch',
      onTap: () async => launchStopwatch(ref),
    );
  }
}

// In this mode, potentially multiple intervals are defined and the workout is
// finished when all of them complete. `intervalsSetupNotifierProvider`'s life
// spans the whole intervals setup; `intervalInputProvider` is created and
// disposed multiple times, each time a new interval is defined.
class _IntervalsModeButton extends StatelessWidget {
  const _IntervalsModeButton();

  @override
  Widget build(BuildContext context) {
    return _ModeButton(
      modeName: 'Intervals',
      onTap: () async => Navigator.of(context).push<void>(
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

    unawaited(_packageInfoFuture = PackageInfo.fromPlatform());
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
