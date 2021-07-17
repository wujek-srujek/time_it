import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/timer.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/page_scaffold.dart';

class WorkoutPage extends StatefulWidget {
  final Widget topWidget;
  final Widget bottomWidget;
  final List<Widget> menuItems;

  const WorkoutPage({
    required this.topWidget,
    required this.bottomWidget,
    this.menuItems = const [],
  });

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
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
          ref.listen(timerStatusProvider, (timerStatus) {
            final isRunning = timerStatus == TimerStatus.running;
            _animationController.animateTo(
              isRunning ? 1 : _smallerMainBodyScale,
            );
          });

          return child!;
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
        final isRunning = ref.watch(timerStatusProvider) == TimerStatus.running;

        return Activation(
          isActive: !isRunning,
          child: child!,
        );
      },
      child: Row(
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

const _smallerMainBodyScale = 0.9;
