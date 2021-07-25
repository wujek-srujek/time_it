import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/intervals_setup.dart';
import '../../util/duration_formatter.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/duration_list_item.dart';
import 'interval_input_page.dart';

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
    final intervals = ref.watch(intervalsSetupNotifierProvider);

    return ListView.builder(
      itemCount: intervals.length,
      itemBuilder: (context, index) {
        final interval = intervals[index];

        return DurationListItem(
          ordinal: index + 1,
          text: _formatInterval(interval),
        );
      },
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
    final intervals = ref.watch(intervalsSetupNotifierProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Activation(
          isActive: false,
          child: CommonButton.destructive(
            child: Icon(Icons.clear_all),
          ),
        ),
        CommonButton(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const IntervalInputPage(),
                settings: RouteSettings(
                  arguments: OnIntervalInputCompletedDelegate(
                    icon: Icons.add_rounded,
                    callback: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            );
          },
          child: const Icon(Icons.add_rounded),
        ),
        Activation(
          isActive: intervals.isNotEmpty,
          child: const CommonButton.primary(
            child: Icon(Icons.play_arrow_rounded),
          ),
        ),
      ],
    );
  }
}