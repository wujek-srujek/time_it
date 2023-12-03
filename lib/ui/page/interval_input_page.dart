import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_input.dart';
import '../widget/common/activation.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';

Future<void> launchIntervalInput(
  BuildContext context,
  IntervalInputDelegate delegate,
) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => IntervalInputPage(
        delegate: delegate,
      ),
    ),
  );
}

class IntervalInputDelegate {
  final IconData submitIcon;
  final void Function(IntervalDefinition) onSubmit;
  final IntervalDefinition? prototype;

  const IntervalInputDelegate({
    required this.submitIcon,
    required this.onSubmit,
    this.prototype,
  });
}

// Design and behavior influenced by the standard Android Clock app.
class IntervalInputPage extends StatelessWidget {
  final IntervalInputDelegate delegate;

  const IntervalInputPage({
    required this.delegate,
  });

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
              child: _IntervalTextWidget(
                prototype: delegate.prototype,
              ),
            ),
          ),
          Divider(
            thickness: 2,
            color: textStyle(context).color,
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: _DialWidget(
                delegate: delegate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalTextWidget extends ConsumerWidget {
  final IntervalDefinition? prototype;

  const _IntervalTextWidget({
    required this.prototype,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalInput = ref.watch(intervalInputNotifierProvider(prototype));

    final textColor =
        intervalInput.isNotEmpty ? Theme.of(context).colorScheme.primary : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _UnitTile(
          intervalInput.hours,
          textColor: textColor,
        ),
        _DotsTile(textColor: textColor),
        _UnitTile(
          intervalInput.minutes,
          textColor: textColor,
        ),
        _DotsTile(textColor: textColor),
        _UnitTile(
          intervalInput.seconds,
          textColor: textColor,
        ),
        GestureDetector(
          onLongPress: intervalInput.isNotEmpty
              ? () => ref
                  .read(intervalInputNotifierProvider(prototype).notifier)
                  .reset()
              : null,
          child: IconButton(
            onPressed: intervalInput.isNotEmpty
                ? () => ref
                    .read(intervalInputNotifierProvider(prototype).notifier)
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

class _DialWidget extends ConsumerWidget {
  final IntervalInputDelegate delegate;

  const _DialWidget({
    required this.delegate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget mapper(int digit) {
      final Widget body;
      if (digit == _double0ButtonMarker) {
        body = CommonButton(
          onTap: () {
            ref.read(intervalInputNotifierProvider(delegate.prototype).notifier)
              ..addDigit(0)
              ..addDigit(0);
          },
          child: const FittedText('00'),
        );
      } else if (digit == _submitButtonMarker) {
        body = _SubmitButton(
          delegate: delegate,
        );
      } else {
        body = CommonButton(
          onTap: () => ref
              .read(intervalInputNotifierProvider(delegate.prototype).notifier)
              .addDigit(digit),
          child: FittedText('$digit'),
        );
      }

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: body,
        ),
      );
    }

    Widget makeRow(List<int> digits) {
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
        makeRow([_double0ButtonMarker, 0, _submitButtonMarker]),
      ],
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  final IntervalInputDelegate delegate;

  const _SubmitButton({
    required this.delegate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalDefinition = ref.watch(
      intervalInputNotifierProvider(delegate.prototype),
    );

    return Activation(
      isActive: intervalDefinition.isNotEmpty,
      child: CommonButton.primary(
        onTap: () => delegate.onSubmit(intervalDefinition),
        child: Icon(delegate.submitIcon),
      ),
    );
  }
}

extension _IsEmptyIntervalDefinitionX on IntervalDefinition {
  bool get isNotEmpty => seconds > 0 || minutes > 0 || hours > 0;
}

const _double0ButtonMarker = -1;
const _submitButtonMarker = -2;
