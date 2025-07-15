// lib/screens/main_screen.dart

import 'package:agilizaiapp/screens/calendar/calendar_screen.dart';
import 'package:agilizaiapp/screens/home/home_screen.dart';
import 'package:agilizaiapp/screens/location/select_location_screen.dart';
import 'package:agilizaiapp/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/guests/promoter_event_selection_screen.dart';
import 'package:agilizaiapp/screens/event_participation/event_search_screen.dart'; // NOVO: Importe a tela de busca de eventos para participação

// A chave global continua aqui, está correta.
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
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

  // Método para exibir o modal de opções do botão '+'
  void _showAddOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'O que você deseja fazer?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o modal
                  // NOVO: Navega para a tela de busca de eventos para participação do cliente
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const EventSearchScreen()),
                  );
                },
                icon: const Icon(Icons.confirmation_num, color: Colors.white),
                label: const Text(
                  'Participar de Evento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26422),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PromoterEventSelectionScreen()),
                  );
                },
                icon: const Icon(Icons.manage_accounts, color: Colors.white),
                label: const Text(
                  'Gerenciar Meus Eventos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF242A38),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptionsModal,
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
                    label: 'Calendário',
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNavItem(
                    icon: Icons.location_on,
                    index: 2,
                    label: 'Localização',
                  ),
                  _buildNavItem(icon: Icons.person, index: 3, label: 'Perfil'),
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
            color:
                _selectedIndex == index ? const Color(0xFFF26422) : Colors.grey,
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
