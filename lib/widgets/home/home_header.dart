// lib/widgets/home/home_header.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 500;
    // Usamos un ratio fijo más compacto en móvil (1.25:1)
    final narrowRatio = isWide ? 3 / 1 : 5 / 3;

    return AspectRatio(
      aspectRatio: isWide ? 2.8 / 1 : narrowRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Splash art ───
          Positioned(
            left: -60,
            top: -40,
            child: _SplashAccent(color: cs.primary.withValues(alpha: .25)),
          ),

          // ─── Textos ───
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xxxl,
              AppSpacing.xxl,
              AppSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Encuentra el hogar\nde tus sueños',
                    style: tt.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Descubre las mejores propiedades del mercado y vive una experiencia única.',
                  style: tt.bodyLarge?.copyWith(
                    color: cs.onSurface.withValues(alpha: .7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// El "blob" borroso de fondo.
class _SplashAccent extends StatelessWidget {
  final Color color;
  const _SplashAccent({required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
