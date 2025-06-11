import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/views/visits/owner_visits_view.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/visits/my_visits_view.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Cargar perfil después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  Future<void> _logout() async {
    try {
      final authVM = context.read<AuthViewModel>();
      final profileVM = context.read<ProfileViewModel>();

      await authVM.logout();
      profileVM.clearProfile();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar("Error al cerrar sesión", isError: true);
    }
  }

  Future<void> _refreshProfile() async {
    await context.read<ProfileViewModel>().fetchProfile();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Importante para AutomaticKeepAliveClientMixin

    return WillPopScope(
      onWillPop: () async {
        await _logout();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mi Perfil"),
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshProfile,
              tooltip: 'Actualizar perfil',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Cargando perfil..."),
                  ],
                ),
              );
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshProfile,
                      child: const Text("Reintentar"),
                    ),
                  ],
                ),
              );
            }

            if (vm.profile == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No se pudo cargar el perfil",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header del perfil
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.blue.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              vm.profile!.firstName.isNotEmpty
                                  ? vm.profile!.firstName[0].toUpperCase()
                                  : "U",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${vm.profile!.firstName} ${vm.profile!.lastName}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vm.profile!.email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Información del perfil
                    const Text(
                      "Información Personal",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      icon: Icons.person,
                      title: "Nombre Completo",
                      value: "${vm.profile!.firstName} ${vm.profile!.lastName}",
                    ),

                    _buildInfoCard(
                      icon: Icons.email,
                      title: "Email",
                      value: vm.profile!.email,
                    ),

                    _buildInfoCard(
                      icon: Icons.location_city,
                      title: "Ciudad",
                      value: vm.profile!.city.isNotEmpty
                          ? vm.profile!.city
                          : "No especificada",
                    ),

                    _buildInfoCard(
                      icon: Icons.flag,
                      title: "País",
                      value: vm.profile!.country.isNotEmpty
                          ? vm.profile!.country
                          : "No especificado",
                    ),

                    ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text("Mis visitas agendadas"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyVisitsView()),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text("Visitas solicitadas"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OwnerVisitsView()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 32),

                    // Botón de logout
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text("Cerrar Sesión"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
