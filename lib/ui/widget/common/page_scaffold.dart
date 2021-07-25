import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final String? title;
  final Widget child;

  const PageScaffold({
    this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}
