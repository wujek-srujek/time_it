import 'package:flutter/material.dart';

import 'timer_page.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) {
                return const TimerPage();
              },
            ),
          );
        },
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
