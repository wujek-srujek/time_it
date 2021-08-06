import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/intervals_setup.dart';
import '../../util/duration_formatter.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/ordered_avatar.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/countdown_timer_widget.dart';
import '../widget/mode/intervals_widget.dart';
import '../widget/mode/menu_items.dart';
import '../widget/mode/repetitions_picker.dart';
import 'interval_input_page.dart';
import 'workout_page.dart';

class IntervalsSetupPage extends StatelessWidget {
  const IntervalsSetupPage();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Define intervals',
      child: Column(
        children: const [
          Expanded(
            child: _IntervalsList(),
          ),
          _ActionsMenu(),
        ],
      ),
    );
  }
}

class _IntervalsList extends ConsumerWidget {
  const _IntervalsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalDefinitions = ref.watch(intervalsSetupNotifierProvider);

    final leaveBehindIndicatorColor = Theme.of(context).colorScheme.error;

    return ReorderableListView.builder(
      itemCount: intervalDefinitions.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(intervalsSetupNotifierProvider.notifier)
            .move(oldIndex: oldIndex, newIndex: newIndex);
      },
      itemBuilder: (context, index) {
        final intervalDefinition = intervalDefinitions[index];

        return Dismissible(
          key: ObjectKey(intervalDefinition),
          background: Container(
            color: leaveBehindIndicatorColor,
          ),
          onDismissed: (direction) {
            ref.read(intervalsSetupNotifierProvider.notifier).remove(index);
          },
          child: _IntervalListTile(
            index: index,
            intervalDefinition: intervalDefinition,
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
    final orderedAvatar = OrderedAvatar(
      ordinal: index + 1,
    );
    final formattedInterval = _formatInterval(intervalDefinition.toDuration());

    return ListTile(
      leading: orderedAvatar,
      title: Row(
        children: [
          Expanded(
            flex: 3,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const IntervalInputPage(),
                    settings: RouteSettings(
                      arguments: IntervalInputDelegate(
                        submitIcon: Icons.refresh_rounded,
                        onSubmit: (intervalDefinition) {
                          ref
                              .read(intervalsSetupNotifierProvider.notifier)
                              .update(
                                index: index,
                                intervalDefinition: intervalDefinition,
                              );

                          Navigator.of(context).pop();
                        },
                        prototype: intervalDefinition,
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FittedText(formattedInterval),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () async {
                final repetitions = await showDialog<int>(
                  context: context,
                  builder: (context) => _RepetitionsDialog(
                    repetitions: intervalDefinition.repetitions,
                    subject: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          orderedAvatar,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: FittedText(formattedInterval),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (repetitions != null &&
                    repetitions != intervalDefinition.repetitions) {
                  ref.read(intervalsSetupNotifierProvider.notifier).update(
                        index: index,
                        intervalDefinition: intervalDefinition.copyWith(
                          newRepetitions: repetitions,
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

class _ActionsMenu extends ConsumerWidget {
  const _ActionsMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalDefinitions = ref.watch(intervalsSetupNotifierProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Activation(
          isActive: intervalDefinitions.isNotEmpty,
          child: CommonButton.destructive(
            onLongPress: () {
              ref.read(intervalsSetupNotifierProvider.notifier).reset();
            },
            child: const Icon(Icons.clear_all),
          ),
        ),
        CommonButton(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const IntervalInputPage(),
                settings: RouteSettings(
                  arguments: IntervalInputDelegate(
                    submitIcon: Icons.add_rounded,
                    onSubmit: (intervalDefinition) {
                      ref
                          .read(intervalsSetupNotifierProvider.notifier)
                          .add(intervalDefinition);

                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            );
          },
          child: const Icon(Icons.add_rounded),
        ),
        Activation(
          isActive: intervalDefinitions.isNotEmpty,
          child: CommonButton.primary(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const WorkoutPage(
                    topWidget: IntervalsWidget(),
                    bottomWidget: CountdownTimerWidget(),
                    menuItems: [
                      RestartMenuButton(),
                    ],
                  ),
                ),
              );
            },
            child: const Icon(Icons.play_arrow_rounded),
          ),
        ),
      ],
    );
  }
}

class _RepetitionsDialog extends StatefulWidget {
  final int repetitions;
  final Widget subject;

  const _RepetitionsDialog({
    required this.repetitions,
    required this.subject,
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
        borderRadius: borderRadius,
      ),
      actionsPadding: const EdgeInsets.all(16),
      title: const Text('Choose repetitions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.subject,
          SizedBox(
            height: screenHeight / 6,
            child: RepetitionsPicker(
              value: _repetitions,
              onChanged: (value) => setState(() => _repetitions = value),
            ),
          ),
        ],
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
