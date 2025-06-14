import 'dart:ui';
import 'package:flutter/material.dart';

class SplashAccent extends StatelessWidget {
  const SplashAccent({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      left: -80,
      top: -40,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: .25),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
