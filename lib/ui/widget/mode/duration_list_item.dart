import 'package:flutter/material.dart';

import '../common/fitted_text.dart';

class DurationListItem extends StatelessWidget {
  final int ordinal;
  final String text;
  final Color? textColor;
  final void Function()? onTap;

  const DurationListItem({
    required this.ordinal,
    required this.text,
    this.textColor,
    this.onTap,
  }) : assert(ordinal > 0);

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: onSurfaceColor,
        child: Text('$ordinal'),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: FittedText(
          text,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
