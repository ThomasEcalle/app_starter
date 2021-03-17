import 'package:example/core/core.dart';
import 'package:flutter/material.dart';

class TemplateHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello from Flappy Template"),
            Text(ConfigManager.of(context).apiBaseUrl),
          ],
        ),
      ),
    );
  }
}
