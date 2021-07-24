import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widget/common/common_button.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/countdown_timer_widget.dart';
import '../widget/mode/menu_items.dart';
import '../widget/mode/rounds_widget.dart';
import '../widget/mode/stopwatch_widget.dart';
import 'interval_input_page.dart';
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
            children: [
              _ModeButton(
                modeName: 'AMRAP',
                targetPage: const IntervalInputPage(),
                arguments: _amrapIntervalInputCompletedDelegate(context),
              ),
              const _ModeButton(
                modeName: 'Stopwatch',
                targetPage: WorkoutPage(
                  topWidget: RoundsWidget(),
                  bottomWidget: StopwatchWidget(),
                  menuItems: [
                    RestartMenuButton(),
                    RoundSummaryMenuButton(),
                  ],
                ),
              ),
              const Expanded(
                flex: 2,
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

OnIntervalInputCompletedDelegate _amrapIntervalInputCompletedDelegate(
  BuildContext context,
) =>
    OnIntervalInputCompletedDelegate(
      icon: Icons.play_arrow_rounded,
      callback: () {
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
    );
