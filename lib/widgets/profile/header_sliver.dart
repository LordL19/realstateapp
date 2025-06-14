// lib/views/profile/widgets/profile_header_sliver.dart
import 'package:flutter/material.dart';
import 'package:realestate_app/models/user_profile.dart';
import '../../../theme/theme.dart';

class ProfileHeaderSliver extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;
  const ProfileHeaderSliver({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent, // ← lo pintamos dentro
      elevation: 0,
      pinned: false,
      expandedHeight: 250,
      // acción editar
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          color: cs.onPrimary,
          onPressed: onEdit,
          tooltip: 'Editar perfil',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: ClipPath(
          clipper: _ArcClipper(), // ← recorte inferior
          child: Container(
            color: cs.primary,
            padding: const EdgeInsets.only(
              top: kToolbarHeight + AppSpacing.l,
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: cs.surface,
                  child: Text(
                    profile.firstName.isNotEmpty
                        ? profile.firstName[0].toUpperCase()
                        : 'U',
                    style: tt.headlineMedium?.copyWith(
                      color: cs.primary,
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // const SizedBox(height: AppSpacing.xs),
                // Text(
                //   profile.email,
                //   style: tt.bodyLarge?.copyWith(
                //     color: cs.onPrimary.withOpacity(.85),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recorta una suave onda (arco cóncavo) en la base del header.
class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40); // baja casi hasta el final
    // curva de lado a lado
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path
      ..lineTo(size.width, 0) // sube hasta la esquina superior derecha
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
