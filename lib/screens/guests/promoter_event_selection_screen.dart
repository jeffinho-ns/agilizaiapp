import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/event_service.dart'; // NOVO
import 'package:agilizaiapp/screens/guests/guest_list_management_screen.dart';

class PromoterEventSelectionScreen extends StatefulWidget {
  const PromoterEventSelectionScreen({super.key});
  @override
  State<PromoterEventSelectionScreen> createState() =>
      _PromoterEventSelectionScreenState();
}

class _PromoterEventSelectionScreenState
    extends State<PromoterEventSelectionScreen> {
  late Future<List<Event>> _eventsFuture;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    // Busca todos os tipos de evento por padrão
    _eventsFuture = _eventService.fetchAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Evento'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Erro ao carregar eventos: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum evento disponível."));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event.nomeDoEvento ?? 'Evento Sem Nome'),
                  subtitle: Text(
                      '${event.casaDoEvento ?? ''} - ${event.dataDoEvento ?? ''}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GuestListManagementScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
