import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_group.dart';
import '../../provider/timer.dart';
import '../../provider/workout_intervals.dart';
import '../util/timer_widget_ref_x.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/page_scaffold.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  final List<IntervalGroup> intervalGroups;
  final Widget topWidget;
  final Widget bottomWidget;
  final List<Widget> menuItems;

  const WorkoutPage({
    required this.intervalGroups,
    required this.topWidget,
    required this.bottomWidget,
    this.menuItems = const [],
  });

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      lowerBound: _smallerMainBodyScale,
      value: 1,
      duration: animationDuration,
      vsync: this,
    );

    ref.read(workoutIntervalsProvider.notifier).state = widget.intervalGroups;
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Consumer(
        builder: (context, ref, child) {
          ref.listenTimerStatus((timerStatus) {
            final isRunning = timerStatus == TimerStatus.running;
            _animationController.animateTo(
              isRunning ? 1 : _smallerMainBodyScale,
            );
          });

          final isCompleted = ref.watchTimerStatus() == TimerStatus.completed;

          return WillPopScope(
            // No idea why this is still broken and undocumented, but we need
            // a workaround - setting to `null` instead of a function returning
            // `Future.value(true)` keeps the 'swipe to go back' iOS gesture.
            // https://github.com/flutter/flutter/issues/14203#issuecomment-644239576
            onWillPop: isCompleted ? null : () => Future.value(false),
            child: child!,
          );
        },
        child: Stack(
          children: [
            ScaleTransition(
              alignment: Alignment.topCenter,
              scale: _animationController,
              child: Column(
                children: [
                  Expanded(
                    child: widget.topWidget,
                  ),
                  Expanded(
                    child: widget.bottomWidget,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _WorkoutMenu(
                  menuItems: widget.menuItems,
                ),
              ],
            ),
          ],
        ),
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
        final isRunning = ref.watchTimerStatus() == TimerStatus.running;

        return Activation(
          isActive: !isRunning,
          child: child!,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _GoBackMenuButton(),
          ...menuItems,
        ],
      ),
    );
  }
}

class _GoBackMenuButton extends ConsumerWidget {
  const _GoBackMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watchTimerStatus() == TimerStatus.completed;

    return CommonButton.safetyCheck(
      safetyCheck: () => isCompleted,
      action: () => Navigator.of(context).pop(),
      child: const Icon(Icons.arrow_back_ios),
    );
  }
}

const _smallerMainBodyScale = 0.9;
