import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/views/login_view.dart';
import 'package:realestate_app/views/properties/favorite_list_view.dart';
import 'package:realestate_app/views/properties/my_properties_list_view.dart';
import 'package:realestate_app/views/register/register_wizard.dart';
import 'package:realestate_app/views/visits/my_visits_view.dart';
import 'package:realestate_app/views/visits/owner_visits_view.dart';
import 'package:realestate_app/widgets/profile/action_tiles.dart';
import 'package:realestate_app/widgets/profile/header_sliver.dart';
import 'package:realestate_app/widgets/profile/info_section.dart';
import 'package:realestate_app/widgets/profile/quick_stats.dart';

import '../../theme/theme.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/favorite_viewmodel.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../../viewmodels/visits_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileViewModel>().fetchProfile(),
    );
  }

  Future<void> _logout() async {
    final auth = context.read<AuthViewModel>();
    await auth.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final cs = Theme.of(context).colorScheme;

          /// -------- estados de carga / error ----------
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: AppSpacing.m),
                  Text(vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: vm.fetchProfile,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (vm.profile == null) {
            return const Center(child: Text('Sin datos de perfil'));
          }

          // --- ViewModels auxiliares para contadores ──────────
          final favCount =
              context.watch<FavoriteViewModel>().favoriteIds.length;
          final myPropsCount =
              context.watch<PropertyViewModel>().myProperties.length;
          final visitsCount = context
              .watch<VisitViewModel>()
              .myVisits
              .length; // ajusta si varía

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// ---------- Encabezado ----------
              ProfileHeaderSliver(
                profile: vm.profile!,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterFormWizard(profile: vm.profile!),
                  ),
                ),
              ),

              /// ---------- Quick-stats ----------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl, vertical: AppSpacing.l),
                  child: QuickStatsRow(
                    favourites: favCount,
                    myProperties: myPropsCount,
                    visits: visitsCount,
                    onTapFav: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavHistoryView()),
                    ),
                    onTapProps: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyPropertiesListView()),
                    ),
                    onTapVisits: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyVisitsView()),
                    ),
                  ),
                ),
              ),

              /// ---------- Info personal ----------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl, vertical: AppSpacing.l),
                  child: PersonalInfoSection(profile: vm.profile!),
                ),
              ),

              /// ---------- Logout ----------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl, vertical: AppSpacing.l),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    onPressed: _logout,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
