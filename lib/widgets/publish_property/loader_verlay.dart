import 'package:flutter/material.dart';

class LoaderOverlay extends StatelessWidget {
  const LoaderOverlay({super.key});

  @override
  Widget build(BuildContext context) => const Positioned.fill(
        child: ColoredBox(
          color: Colors.black45,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
}
