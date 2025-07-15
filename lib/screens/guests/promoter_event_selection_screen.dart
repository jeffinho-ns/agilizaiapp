// lib/screens/guests/promoter_event_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/guest_service.dart';
import 'package:agilizaiapp/screens/guests/guest_list_management_screen.dart'; // A tela principal de gerenciamento
import 'package:provider/provider.dart'; // Para UserProfileProvider ou AuthenticationProvider
import 'package:agilizaiapp/providers/user_profile_provider.dart'; // Assumindo que você tem isso para pegar o userId

class PromoterEventSelectionScreen extends StatefulWidget {
  const PromoterEventSelectionScreen({super.key});

  @override
  State<PromoterEventSelectionScreen> createState() =>
      _PromoterEventSelectionScreenState();
}

class _PromoterEventSelectionScreenState
    extends State<PromoterEventSelectionScreen> {
  final GuestService _guestService = GuestService();
  List<Event> _promoterEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPromoterEvents();
  }

  Future<void> _fetchPromoterEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Obtenha o ID do usuário logado (promotor)
      // Isso é crucial para filtrar os eventos do promotor.
      // Você precisa adaptar como pega o userId do seu provedor de autenticação.
      final currentUserId =
          Provider.of<UserProfileProvider>(context, listen: false)
              .currentUser
              ?.id;

      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'Usuário não logado ou ID não disponível.';
          _isLoading = false;
        });
        return;
      }

      final events = await _guestService.fetchPromoterEvents(currentUserId);
      setState(() {
        // Se sua API não filtra por promotor, filtre aqui no Flutter:
        // _promoterEvents = events.where((event) => event.promoterId == currentUserId).toList();
        _promoterEvents =
            events; // Usando todos os eventos se o backend não filtrar
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar seus eventos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione o Evento para Gerenciar'),
        backgroundColor: const Color(0xFF242A38),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : _promoterEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'Você não tem eventos criados para gerenciar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _promoterEvents.length,
                      itemBuilder: (context, index) {
                        final event = _promoterEvents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: event.imagemDoEventoUrl != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(event.imagemDoEventoUrl!),
                                  )
                                : const CircleAvatar(child: Icon(Icons.event)),
                            title:
                                Text(event.nomeDoEvento ?? 'Evento Sem Nome'),
                            subtitle: Text(
                                '${event.casaDoEvento ?? ''} - ${event.dataDoEvento ?? ''}'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GuestListManagementScreen(event: event),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
