// lib/screens/main_screen.dart

import 'package:agilizaiapp/screens/calendar/calendar_screen.dart';
import 'package:agilizaiapp/screens/home/home_screen.dart';
import 'package:agilizaiapp/screens/location/select_location_screen.dart';
import 'package:agilizaiapp/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

// A chave global continua aqui, está correta.
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  // --- PASSO 1: CONSTRUTOR CORRIGIDO ---
  // Este construtor garante que a MainScreen SEMPRE use a nossa chave global.
  // Ele não aceita parâmetros e atribui a chave correta automaticamente.
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Índice 0
    CalendarScreen(), // Índice 1
    SelectLocationScreen(), // Índice 2
    ProfileScreen(), // Índice 3
  ];

  void onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- PASSO 2: CHAVE REMOVIDA DO SCAFFOLD ---
    // A chave não é mais necessária aqui, pois já foi atribuída
    // ao widget MainScreen através do construtor.
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Floating Action Button clicado');
        },
        backgroundColor: const Color(0xFFF26422),
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNavItem(icon: Icons.home, index: 0, label: 'Home'),
                  _buildNavItem(
                    icon: Icons.calendar_today,
                    index: 1,
                    label: 'Calendar',
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNavItem(
                    icon: Icons.location_on,
                    index: 2,
                    label: 'Location',
                  ),
                  _buildNavItem(icon: Icons.person, index: 3, label: 'Profile'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: _selectedIndex == index
                ? const Color(0xFFF26422)
                : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index
                  ? const Color(0xFFF26422)
                  : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
