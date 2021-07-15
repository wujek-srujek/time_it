import 'package:flutter/material.dart';

import '../widget/common/common_button.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/menu_items.dart';
import '../widget/mode/rounds_widget.dart';
import '../widget/mode/stopwatch_widget.dart';
import 'interval_config_page.dart';
import 'workout_page.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Choose mode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _ModeButton(
            modeName: 'AMRAP',
            targetPage: IntervalConfigPage(),
          ),
          _ModeButton(
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
          Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String modeName;
  final Widget targetPage;

  const _ModeButton({
    required this.modeName,
    required this.targetPage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: CommonButton(
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => targetPage,
              ),
            );
          },
          child: FittedText(modeName),
        ),
      ),
    );
  }
}
