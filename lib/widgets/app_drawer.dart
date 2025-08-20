// lib/widgets/app_drawer.dart

import 'package:agilizaiapp/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';
import 'package:agilizaiapp/screens/profile/edit_profile_screen.dart';
import 'package:agilizaiapp/screens/profile/profile_screen.dart';
import 'package:agilizaiapp/screens/my_reservations_screen.dart';
import 'package:agilizaiapp/screens/reservation/birthday_reservation_screen.dart';
import 'package:agilizaiapp/screens/search/search_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onClose;

  const AppDrawer({super.key, this.onClose});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          if (response.statusCode == 200) {
            _currentUser = User.fromJson(jsonDecode(response.body));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar usuário atual no AppDrawer: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'jwt_token');

      Provider.of<UserProfileProvider>(
        context,
        listen: false,
      ).setUser(const User(id: 0, name: '', email: ''));

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
    return Container(
      color: const Color(0xFF2B3245),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          const SizedBox(height: 20),
          _buildSectionTitle('BROWSE'),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            text: 'Home',
            onTap: () {
              widget.onClose?.call();
              mainScreenKey.currentState?.onItemTapped(0);
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Meu Perfil',
            onTap: () {
              widget.onClose?.call();
              mainScreenKey.currentState?.onItemTapped(3);
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today_outlined,
            text: 'Calendário',
            onTap: () {
              widget.onClose?.call();
              mainScreenKey.currentState?.onItemTapped(1);
            },
          ),
          _buildDrawerItem(
            icon: Icons.search_outlined,
            text: 'Buscar',
            onTap: () {
              widget.onClose?.call();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.bookmark_border_outlined,
            text: 'Reservas',
            onTap: () {
              widget.onClose?.call();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyReservationsScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.celebration_outlined,
            text: 'Meu Aniversário',
            onTap: () {
              widget.onClose?.call();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BirthdayReservationScreen(),
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
            text: 'Configurações',
            onTap: () {
              widget.onClose?.call();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
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
  }

  void _showSnackbar(BuildContext context, String message) {
    widget.onClose?.call();
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

  Widget _buildDrawerHeader(BuildContext context) {
    final bool hasProfileImage = _currentUser?.fotoPerfil != null &&
        _currentUser!.fotoPerfil!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: widget.onClose,
            ),
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: hasProfileImage
                          ? NetworkImage(_currentUser!.fotoPerfil!)
                          : null,
                      backgroundColor: Colors.grey[700],
                      child: hasProfileImage
                          ? null
                          : const Icon(Icons.person,
                              size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.name ?? 'Guest User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currentUser?.role ?? 'Usuário Comum',
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
    VoidCallback? onTap,
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
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
