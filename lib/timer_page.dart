import 'dart:ui';

import 'package:flutter/material.dart';

class TimerPage extends StatelessWidget {
  final Duration interval;

  const TimerPage({required this.interval});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            '$interval',
            style: Theme.of(context).textTheme.headline3!.copyWith(
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.error,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.stop_rounded),
      ),
    );
  }
}
