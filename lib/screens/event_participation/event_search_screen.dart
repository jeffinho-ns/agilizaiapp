import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/event_service.dart'; // Usando o novo EventService
import 'package:agilizaiapp/screens/event_participation/event_participation_form_screen.dart';

class EventSearchScreen extends StatefulWidget {
  const EventSearchScreen({super.key});

  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  final EventService _eventService = EventService();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllEvents();
  }

  Future<void> _fetchAllEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.fetchAllEvents();
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participar de Evento'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar Evento (nome ou local)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterEvents,
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            Expanded(
                child: Center(
                    child: Text(_errorMessage,
                        style: const TextStyle(color: Colors.red))))
          else if (_filteredEvents.isEmpty)
            const Expanded(
                child: Center(child: Text('Nenhum evento encontrado.')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = _filteredEvents[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: event.imagemDoEventoUrl != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(event.imagemDoEventoUrl!))
                          : const CircleAvatar(child: Icon(Icons.event)),
                      title: Text(event.nomeDoEvento ?? 'Evento Sem Nome'),
                      subtitle: Text(
                          '${event.localDoEvento ?? ''} - ${event.dataDoEvento ?? ''}'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EventParticipationFormScreen(event: event),
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
