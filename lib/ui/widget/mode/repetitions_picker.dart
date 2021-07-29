import 'package:flutter/material.dart';

import '../common/activation.dart';
import '../common/common_button.dart';
import '../common/fitted_text.dart';

class RepetitionsPicker extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const RepetitionsPicker({
    this.value = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Activation(
          isActive: value > 1,
          inactiveOpacity: _inactiveOpacity,
          child: CommonButton(
            onTap: () => onChanged(value - 1),
            child: const Icon(Icons.remove_rounded),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FittedText('$value'),
          ),
        ),
        CommonButton(
          onTap: () => onChanged(value + 1),
          child: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

const _inactiveOpacity = 0.5;
