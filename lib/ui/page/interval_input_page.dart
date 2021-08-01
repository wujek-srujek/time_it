import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_input.dart';
import '../../provider/intervals_setup.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';

class OnIntervalInputCompletedDelegate {
  final IconData icon;
  final void Function(IntervalDefinition) callback;

  const OnIntervalInputCompletedDelegate({
    required this.icon,
    required this.callback,
  });
}

// Design and behavior influenced by the standard Android Clock app.
class IntervalInputPage extends StatelessWidget {
  const IntervalInputPage();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Define interval',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 24),
              child: const _IntervalTextWidget(),
            ),
          ),
          Divider(
            thickness: 2,
            color: textStyle(context).color,
          ),
          const Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: _DialWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalTextWidget extends ConsumerWidget {
  const _IntervalTextWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalDefinition = ref.watchIntervalDefinition();

    final textColor = intervalDefinition.isNotEmpty
        ? Theme.of(context).colorScheme.primary
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _UnitTile(
          intervalDefinition.hours,
          textColor: textColor,
        ),
        _DotsTile(textColor: textColor),
        _UnitTile(
          intervalDefinition.minutes,
          textColor: textColor,
        ),
        _DotsTile(textColor: textColor),
        _UnitTile(
          intervalDefinition.seconds,
          textColor: textColor,
        ),
        GestureDetector(
          onLongPress: intervalDefinition.isNotEmpty
              ? () => ref
                  .read(intervalInputNotifierProvider.notifier)
                  .resetOngoingDefinition()
              : null,
          child: IconButton(
            onPressed: intervalDefinition.isNotEmpty
                ? () => ref
                    .read(intervalInputNotifierProvider.notifier)
                    .deleteLastDigit()
                : null,
            icon: const Icon(
              Icons.backspace_outlined,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitTile extends StatelessWidget {
  final int amount;
  final Color? textColor;

  const _UnitTile(this.amount, {this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: FittedText(
        '$amount'.padLeft(2, '0'),
        color: textColor,
      ),
    );
  }
}

class _DotsTile extends StatelessWidget {
  final Color? textColor;

  const _DotsTile({this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedText(
        ':',
        color: textColor,
      ),
    );
  }
}

const _completedButtonMarker = -1;

class _DialWidget extends ConsumerWidget {
  const _DialWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget mapper(int? digit) {
      final Widget body;
      if (digit == _completedButtonMarker) {
        body = const _InputCompletedButton();
      } else if (digit != null) {
        body = CommonButton(
          onTap: () =>
              ref.read(intervalInputNotifierProvider.notifier).addDigit(digit),
          child: FittedText('$digit'),
        );
      } else {
        body = const SizedBox.shrink();
      }

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: body,
        ),
      );
    }

    Widget makeRow(List<int?> digits) {
      return Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: digits.map(mapper).toList(),
        ),
      );
    }

    return Column(
      children: [
        makeRow([1, 2, 3]),
        makeRow([4, 5, 6]),
        makeRow([7, 8, 9]),
        makeRow([null, 0, _completedButtonMarker]),
      ],
    );
  }
}

class _InputCompletedButton extends ConsumerWidget {
  const _InputCompletedButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalDefinition = ref.watchIntervalDefinition();

    final delegate = ModalRoute.of(context)!.settings.arguments!
        as OnIntervalInputCompletedDelegate;

    return Activation(
      isActive: intervalDefinition.isNotEmpty,
      child: CommonButton.primary(
        onTap: () => delegate.callback(intervalDefinition),
        child: Icon(delegate.icon),
      ),
    );
  }
}

// [OngoingIntervalDefinition] may be `null` in [intervalInputNotifierProvider]
// so let's use a 'null object'. If not, `null` would need to be dealt with in
// many places in this library.

class _UnsetIntervalDefinition implements IntervalDefinition {
  const _UnsetIntervalDefinition();

  @override
  Duration toDuration() => throw UnimplementedError('must not be called');

  @override
  int get hours => 0;

  @override
  int get minutes => 0;

  @override
  int get seconds => 0;
}

extension _IntervalDefinitionX on IntervalDefinition {
  bool get isNotEmpty => this is! _UnsetIntervalDefinition;
}

/// **Note**: this extension is pretty much a workaround for
/// https://github.com/rrousselGit/river_pod/issues/648 and should be replaced
/// with a standard and recommended solution once fixed.

extension _IntervalDefinitiontWidgetRefX on WidgetRef {
  IntervalDefinition watchIntervalDefinition() {
    return watch(intervalInputNotifierProvider) ??
        const _UnsetIntervalDefinition();
  }
}
