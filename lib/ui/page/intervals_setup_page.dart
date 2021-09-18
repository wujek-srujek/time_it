import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_group.dart';
import '../../provider/intervals_setup.dart';
import '../../provider/workout_intervals.dart';
import '../../util/duration_formatter.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/repetitions_picker.dart';
import '../workout_launcher.dart';
import 'interval_input_page.dart';

class IntervalsSetupPage extends StatelessWidget {
  const IntervalsSetupPage();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Define intervals',
      child: Column(
        children: [
          const Expanded(
            child: _IntervalsList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ResetButton(),
                _AddButton(),
                _StartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalsList extends ConsumerWidget {
  const _IntervalsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(intervalsSetupNotifierProvider);

    final leaveBehindIndicatorColor = Theme.of(context).colorScheme.error;

    return ReorderableListView.builder(
      itemCount: setup.groupedItems.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(intervalsSetupNotifierProvider.notifier)
            .move(oldIndex: oldIndex, newIndex: newIndex);
      },
      itemBuilder: (context, index) {
        final groupedItem = setup.groupedItems[index];

        return Dismissible(
          key: ObjectKey(groupedItem),
          background: Container(
            color: leaveBehindIndicatorColor,
          ),
          onDismissed: (direction) {
            ref.read(intervalsSetupNotifierProvider.notifier).remove(index);
          },
          child: _IntervalListTile(
            index: index,
            // Safe for now, the UI doesn't support anything else yet.
            intervalDefinition:
                (groupedItem.item as IntervalDefinitionItem).intervalDefinition,
          ),
        );
      },
    );
  }
}

class _IntervalListTile extends ConsumerWidget {
  final int index;
  final IntervalDefinition intervalDefinition;

  const _IntervalListTile({
    required this.index,
    required this.intervalDefinition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedInterval = _formatInterval(intervalDefinition.toDuration());

    return ListTile(
      title: Row(
        children: [
          Expanded(
            flex: 3,
            child: InkWell(
              borderRadius: allCircularBorderRadius,
              onTap: () {
                launchIntervalInput(
                  context,
                  IntervalInputDelegate(
                    submitIcon: Icons.refresh_rounded,
                    onSubmit: (intervalDefinition) {
                      ref.read(intervalsSetupNotifierProvider.notifier).update(
                            index: index,
                            item: IntervalDefinitionItem(intervalDefinition),
                          );

                      Navigator.of(context).pop();
                    },
                    prototype: intervalDefinition,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FittedText(formattedInterval),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: allCircularBorderRadius,
              onTap: () async {
                final repetitions = await showDialog<int>(
                  context: context,
                  builder: (context) => _RepetitionsDialog(
                    repetitions: intervalDefinition.repetitions,
                  ),
                );

                if (repetitions != null &&
                    repetitions != intervalDefinition.repetitions) {
                  ref.read(intervalsSetupNotifierProvider.notifier).update(
                        index: index,
                        item: IntervalDefinitionItem(
                          intervalDefinition.copyWith(
                            newRepetitions: repetitions,
                          ),
                        ),
                      );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: FittedText('×${intervalDefinition.repetitions}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatInterval(Duration interval) => formatDuration(
      interval,
      forceComponent: TimeComponent.minute,
      forceComponentPadding: TimeComponent.minute,
    );

class _ResetButton extends ConsumerWidget {
  const _ResetButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(intervalsSetupNotifierProvider);

    return Activation(
      isActive: setup.groupedItems.isNotEmpty,
      child: CommonButton.destructive(
        onLongPress: () {
          ref.read(intervalsSetupNotifierProvider.notifier).reset();
        },
        child: const Icon(Icons.clear_all),
      ),
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonButton(
      onTap: () {
        launchIntervalInput(
          context,
          IntervalInputDelegate(
            submitIcon: Icons.add_rounded,
            onSubmit: (intervalDefinition) {
              ref
                  .read(intervalsSetupNotifierProvider.notifier)
                  .add(IntervalDefinitionItem(intervalDefinition));

              Navigator.of(context).pop();
            },
          ),
        );
      },
      child: const Icon(Icons.add_rounded),
    );
  }
}

class _StartButton extends ConsumerWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(intervalsSetupNotifierProvider);

    return Activation(
      isActive: setup.hasIntervals,
      child: CommonButton.primary(
        onTap: () async {
          final repetitions = await showDialog<int>(
            context: context,
            builder: (context) => const _RepetitionsDialog(
              repetitions: 1,
            ),
          );

          if (repetitions == null) {
            return;
          }

          final group = ref
              .read(intervalsSetupNotifierProvider.notifier)
              .intervalGroup(repetitions);

          ref.read(workoutIntervalsProvider.notifier).state = [group];

          await launchIntervals(context);
        },
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}

class _RepetitionsDialog extends StatefulWidget {
  final int repetitions;

  const _RepetitionsDialog({
    required this.repetitions,
  });

  @override
  _RepetitionsDialogState createState() => _RepetitionsDialogState();
}

class _RepetitionsDialogState extends State<_RepetitionsDialog> {
  late int _repetitions;

  @override
  void initState() {
    super.initState();

    _repetitions = widget.repetitions;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: allCircularBorderRadius,
      ),
      actionsPadding: const EdgeInsets.all(16),
      title: const Text('Choose repetitions'),
      content: SizedBox(
        height: screenHeight / 6,
        child: RepetitionsPicker(
          value: _repetitions,
          onChanged: (value) => setState(() => _repetitions = value),
        ),
      ),
      actions: [
        CommonButton.primary(
          onTap: () => Navigator.of(context).pop(_repetitions),
          child: const Icon(Icons.check_rounded),
        ),
      ],
    );
  }
}
