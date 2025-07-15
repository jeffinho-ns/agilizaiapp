// lib/screens/event_participation/event_search_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/guest_service.dart'; // Reutilizamos o GuestService
import 'package:agilizaiapp/screens/event_participation/event_participation_form_screen.dart'; // Tela de formulário de participação

class EventSearchScreen extends StatefulWidget {
  const EventSearchScreen({super.key});

  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  final GuestService _guestService = GuestService();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAllEvents();
  }

  Future<void> _fetchAllEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Sua rota GET /api/events/ já retorna todos os eventos.
      // Poderíamos usar um filtro `tipo=unico` ou `tipo=semanal` se a API suportar
      // e se quisermos limitar quais eventos o cliente pode participar.
      final events = await _guestService.fetchPromoterEvents(
          0); // O userId 0 é um placeholder aqui, não é usado por esta rota
      setState(() {
        _allEvents = events;
        _filteredEvents =
            events; // Inicialmente, todos os eventos são mostrados
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar eventos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterEvents(String query) {
    setState(() {
      _searchQuery = query;
      _filteredEvents = _allEvents.where((event) {
        final eventName = event.nomeDoEvento?.toLowerCase() ?? '';
        final eventLocation = event.localDoEvento?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return eventName.contains(searchLower) ||
            eventLocation.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participar de Evento'),
        backgroundColor: const Color(0xFF242A38),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar Evento (nome ou local)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterEvents,
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : _errorMessage.isNotEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    )
                  : _filteredEvents.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'Nenhum evento disponível para participação.'
                                  : 'Nenhum evento encontrado para "${_searchQuery}".',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = _filteredEvents[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: event.imagemDoEventoUrl != null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              event.imagemDoEventoUrl!),
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.event)),
                                  title: Text(
                                      event.nomeDoEvento ?? 'Evento Sem Nome'),
                                  subtitle: Text(
                                      '${event.localDoEvento ?? ''} - ${event.dataDoEvento ?? ''} às ${event.horaDoEvento ?? ''}'),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EventParticipationFormScreen(
                                                event: event),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
        ],
      ),
    );
  }
}
