// lib/widgets/app_drawer.dart

import 'package:agilizaiapp/screens/main_screen.dart'; // IMPORTANTE: Importar a main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';
import 'package:agilizaiapp/screens/profile/edit_profile_screen.dart';
import 'package:agilizaiapp/screens/profile/profile_screen.dart';

import 'package:agilizaiapp/screens/my_reservations_screen.dart'; // Importe a nova tela de reservas

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const AppDrawer({super.key, this.onClose});

  Future<void> _logout(BuildContext context) async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'jwt_token');

      Provider.of<UserProfileProvider>(
        context,
        listen: false,
      ).setUser(User(id: 0, name: '', email: ''));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        final User? currentUser = userProfileProvider.currentUser;

        return Container(
          color: const Color(0xFF2B3245),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context, currentUser),
              const SizedBox(height: 20),
              _buildSectionTitle('BROWSE'),

              // Itens que controlam o MainScreen
              _buildDrawerItem(
                icon: Icons.home_outlined,
                text: 'Home',
                onTap: () {
                  onClose?.call();
                  mainScreenKey.currentState?.onItemTapped(
                    0,
                  ); // Vai para a aba Home (índice 0)
                },
              ),
              _buildDrawerItem(
                icon: Icons.person_outline,
                text: 'My Profile',
                onTap: () {
                  onClose?.call();
                  // CORRETO: usa a chave para chamar o método
                  mainScreenKey.currentState?.onItemTapped(3);
                },
              ),
              _buildDrawerItem(
                icon: Icons.calendar_today_outlined,
                text: 'Calendar',
                onTap: () {
                  onClose?.call();
                  mainScreenKey.currentState?.onItemTapped(
                    1,
                  ); // Vai para a aba Calendar (índice 1)
                },
              ),

              // Itens que (no futuro) abrirão telas separadas
              _buildDrawerItem(
                icon: Icons.search_outlined,
                text: 'Search',
                onTap: () => _showSnackbar(context, 'Search clicado!'),
              ),
              _buildDrawerItem(
                icon: Icons.bookmark_border_outlined,
                text: 'Reservas',
                // CORREÇÃO: Usar 'onTap' em vez de 'onPressed'
                onTap: () {
                  onClose?.call(); // Fecha o drawer ao clicar no item
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyReservationsScreen(),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.headset_mic_outlined,
                text: 'Contact us',
                onTap: () => _showSnackbar(context, 'Contact us clicado!'),
              ),
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                text: 'Settings',
                onTap: () => _showSnackbar(context, 'Settings clicado!'),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Divider(color: Colors.white24),
              ),

              _buildDrawerItem(
                icon: Icons.logout,
                text: 'Sign Out',
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // MÉTODOS AUXILIARES (COMPLETOS)

  void _showSnackbar(BuildContext context, String message) {
    onClose?.call();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? currentUser) {
    final bool hasProfileImage =
        currentUser?.fotoPerfil != null && currentUser!.fotoPerfil!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: onClose,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: hasProfileImage
                    ? NetworkImage(currentUser!.fotoPerfil!)
                    : null,
                backgroundColor: Colors.grey[700],
                child: hasProfileImage
                    ? null
                    : const Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.name ?? 'Guest User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentUser?.role ?? 'Usuário Comum',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap, // <-- Aqui é 'onTap'
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: onTap, // <-- Aqui é usado 'onTap'
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
