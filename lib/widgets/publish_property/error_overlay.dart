import 'package:flutter/material.dart';

class ErrorOverlay extends StatelessWidget {
  const ErrorOverlay({super.key});

  @override
  Widget build(BuildContext context) => const Positioned.fill(
        child: ColoredBox(
          color: Colors.black45,
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
}
