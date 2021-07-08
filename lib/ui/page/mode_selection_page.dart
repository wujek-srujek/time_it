import 'package:flutter/material.dart';

import '../widget/fitted_text_button.dart';
import 'interval_config_page.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose mode'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _ModeButton(
                modeName: 'AMRAP',
                targetPage: IntervalConfigPage(),
              ),
              Expanded(
                flex: 3,
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String modeName;
  final Widget targetPage;

  const _ModeButton({
    required this.modeName,
    required this.targetPage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: FittedTextButton(
          modeName,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => targetPage,
              ),
            );
          },
        ),
      ),
    );
  }
}
