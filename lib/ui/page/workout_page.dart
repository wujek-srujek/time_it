import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/timer.dart';
import '../util/timer_widget_ref_x.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/page_scaffold.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  final Widget topWidget;
  final Widget bottomWidget;
  final List<Widget> menuItems;

  const WorkoutPage({
    required this.topWidget,
    required this.bottomWidget,
    this.menuItems = const [],
  });

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _wasAutoStarted = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      lowerBound: _smallerMainBodyScale,
      value: 1,
      duration: animationDuration,
      vsync: this,
    );

    // TimerNotifier.start changes the state to 'running' and this is not
    // allowed in 'initState' by Riverpod. We want the timer to start
    // automatically and the usual workaround is to do it with a slight delay.
    // However, this results in the first frame being drawn for the 'stopped'
    // timer state, and then almost immediately redrawn for 'started', causing a
    // flicker. To work around this, before timer auto start, an empty view is
    // drawn; when the timer is auto started, its state change causes another
    // redraw, which this time results in the proper UI.
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _wasAutoStarted = true;
        ref.read(timerNotifierProvider.notifier).start();
      },
    );
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

          final timerStatus = ref.watchTimerStatus();

          return PopScope(
            canPop: timerStatus == TimerStatus.completed,
            child: timerStatus == TimerStatus.stopped && !_wasAutoStarted
                ? const SizedBox.shrink()
                : child!,
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _WorkoutMenu(
                menuItems: widget.menuItems,
              ),
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
