import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/intervals_setup.dart';
import '../../util/duration_formatter.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/filled_box.dart';
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
                _AddIntervalButton(),
                _AddGroupButton(),
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
    final groupedItems = ref.watch(intervalsSetupNotifierProvider).groupedItems;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ReorderableListView.builder(
        itemCount: groupedItems.length,
        onReorder: (oldIndex, newIndex) {
          ref
              .read(intervalsSetupNotifierProvider.notifier)
              .move(oldIndex: oldIndex, newIndex: newIndex);
        },
        itemBuilder: (context, index) {
          final groupedItem = groupedItems[index];

          return _IntervalsListItem(
            index: index,
            groupedItem: groupedItem,
          );
        },
      ),
    );
  }
}

class _IntervalsListItem extends ConsumerWidget {
  final int index;
  final GroupedIntervalsSetupItem groupedItem;

  _IntervalsListItem({
    required this.index,
    required this.groupedItem,
  }) : super(key: ObjectKey(groupedItem));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = groupedItem.item;

    final colorScheme = Theme.of(context).colorScheme;
    final baseColor =
        groupedItem.group.isEven ? colorScheme.primary : colorScheme.secondary;

    return Dismissible(
      key: key!,
      onDismissed: (direction) {
        ref.read(intervalsSetupNotifierProvider.notifier).remove(index);
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: groupedItem.isFirst ? 4 : 0,
          bottom: groupedItem.isLast ? 4 : 0,
        ),
        child: FilledBox(
          color: baseColor.withAlpha(100),
          roundedCorners: {
            if (groupedItem.isFirst) ...{
              Corner.topLeft,
              Corner.topRight,
            },
            if (groupedItem.isLast) ...{
              Corner.bottomLeft,
              Corner.bottomRight,
            },
          },
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _IntervalsItemWidget(
                  index: index,
                  item: item,
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
                        repetitions: item.repetitions,
                      ),
                    );

                    if (repetitions != null &&
                        repetitions != item.repetitions) {
                      ref.read(intervalsSetupNotifierProvider.notifier).update(
                            index: index,
                            item: item.withRepetitions(repetitions),
                          );
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    child: FittedText('×${item.repetitions}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntervalsItemWidget extends ConsumerWidget {
  final int index;
  final IntervalsSetupItem item;

  const _IntervalsItemWidget({
    required this.index,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = this.item;

    if (item is IntervalGroupItem) {
      return Container();
    } else if (item is IntervalDefinitionItem) {
      return InkWell(
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
              prototype: item.intervalDefinition,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FittedText(
            _formatInterval(
              item.intervalDefinition.toDuration(),
            ),
          ),
        ),
      );
    }

    assert(false, 'unknown item type');

    return Container();
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

class _AddIntervalButton extends ConsumerWidget {
  const _AddIntervalButton();

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
      child: const Icon(Icons.timelapse_rounded),
    );
  }
}

class _AddGroupButton extends ConsumerWidget {
  const _AddGroupButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonButton(
      onTap: () {
        ref
            .read(intervalsSetupNotifierProvider.notifier)
            .add(const IntervalGroupItem());
      },
      child: const Icon(Icons.list_alt_rounded),
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
        onTap: () => launchIntervals(context, setup.toIntervalGroups()),
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
