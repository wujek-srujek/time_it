import 'package:flutter/material.dart';

class OrderedAvatar extends StatelessWidget {
  final int ordinal;

  const OrderedAvatar({
    required this.ordinal,
  }) : assert(ordinal > 0);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      child: Text('$ordinal'),
    );
  }
}
