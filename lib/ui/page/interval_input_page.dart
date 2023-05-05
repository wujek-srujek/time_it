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
      builder: (context) => const IntervalInputPage(),
      settings: RouteSettings(
        arguments: delegate,
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
class IntervalInputPage extends ConsumerStatefulWidget {
  const IntervalInputPage();

  @override
  ConsumerState<IntervalInputPage> createState() => _IntervalInputPageState();
}

class _IntervalInputPageState extends ConsumerState<IntervalInputPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final delegate =
        ModalRoute.of(context)!.settings.arguments! as IntervalInputDelegate;
    if (delegate.prototype != null) {
      ref
          .read(intervalInputNotifierProvider.notifier)
          .override(delegate.prototype!);
    }
  }

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
    final intervalInput = ref.watch(intervalInputNotifierProvider);

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
              ? () => ref.read(intervalInputNotifierProvider.notifier).reset()
              : null,
          child: IconButton(
            onPressed: intervalInput.isNotEmpty
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

const _submitButtonMarker = -1;

class _DialWidget extends ConsumerWidget {
  const _DialWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget mapper(int? digit) {
      final Widget body;
      if (digit == _submitButtonMarker) {
        body = const _SubmitButton();
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
        makeRow([null, 0, _submitButtonMarker]),
      ],
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalInput = ref.watch(intervalInputNotifierProvider);

    final delegate =
        ModalRoute.of(context)!.settings.arguments! as IntervalInputDelegate;

    return Activation(
      isActive: intervalInput.isNotEmpty,
      child: CommonButton.primary(
        onTap: () => delegate.onSubmit(
          ref.watch(intervalInputNotifierProvider.notifier).intervalDefinition,
        ),
        child: Icon(delegate.submitIcon),
      ),
    );
  }
}
