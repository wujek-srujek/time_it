import 'package:flutter/material.dart';

class NumberAvatar extends StatelessWidget {
  final int number;

  const NumberAvatar({
    required this.number,
  }) : assert(number > 0);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      child: Text('$number'),
    );
  }
}
