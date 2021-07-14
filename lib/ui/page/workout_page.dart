import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/timer.dart';
import '../widget/common/page_scaffold.dart';

class WorkoutPage extends StatelessWidget {
  final Widget topWidget;
  final Widget bottomWidget;

  const WorkoutPage({
    required this.topWidget,
    required this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: const _BackButton(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: topWidget,
          ),
          Expanded(
            child: bottomWidget,
          ),
        ],
      ),
    );
  }
}

class _BackButton extends ConsumerWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watch(timerStatusProvider);

    return FloatingActionButton(
      backgroundColor: timerStatus == TimerStatus.completed
          ? null
          : Theme.of(context).colorScheme.error,
      onPressed: () {
        Navigator.of(context).pop();
      },
      mini: true,
      child: Icon(
        timerStatus == TimerStatus.completed
            ? Icons.arrow_back_ios_rounded
            : Icons.stop_rounded,
      ),
    );
  }
}
