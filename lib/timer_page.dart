import 'package:flutter/material.dart';

class TimerPage extends StatelessWidget {
  const TimerPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
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
