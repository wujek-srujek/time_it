import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/timer.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/page_scaffold.dart';

class WorkoutPage extends StatelessWidget {
  final Widget topWidget;
  final Widget bottomWidget;
  final List<Widget> menuItems;

  const WorkoutPage({
    required this.topWidget,
    required this.bottomWidget,
    this.menuItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: topWidget,
          ),
          Expanded(
            flex: 4,
            child: bottomWidget,
          ),
          Expanded(
            child: _WorkoutMenu(
              menuItems: menuItems,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutMenu extends StatelessWidget {
  final List<Widget> menuItems;

  const _WorkoutMenu({required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isRunning = ref.watch(timerStatusProvider) == TimerStatus.running;

        return AnimatedOpacity(
          duration: opacityAnimationDuration,
          opacity: !isRunning ? 1 : 0,
          child: IgnorePointer(
            ignoring: isRunning,
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonButton.destructive(
            onLongPress: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios),
          ),
          ...menuItems,
        ],
      ),
    );
  }
}
