// lib/screens/event/upcoming_events_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/widgets/event_preview_sheet.dart';
import 'package:agilizaiapp/services/event_service.dart'; // <--- NOVO: Importe o serviço de eventos

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  late Future<List<Event>> _upcomingEventsFuture;
  final EventService _eventService =
      EventService(); // <--- NOVO: Instância do serviço

  @override
  void initState() {
    super.initState();
    _upcomingEventsFuture = _fetchAndFilterUpcomingEvents();
  }

  Future<List<Event>> _fetchAndFilterUpcomingEvents() async {
    // Usando EventService para buscar todos os eventos
    final List<Event> allEvents =
        await _eventService.fetchAllEvents(); // <--- CORREÇÃO AQUI

    DateTime now = DateTime.now();
    List<Event> upcomingEvents = allEvents.where((event) {
      if (event.dataDoEvento == null || event.dataDoEvento!.isEmpty) {
        return false;
      }
      try {
        DateTime eventDate = DateTime.parse(event.dataDoEvento!);
        return eventDate.isAfter(DateTime(now.year, now.month, now.day));
      } catch (e) {
        print('Erro ao parsear data do evento ${event.nomeDoEvento}: $e');
        return false;
      }
    }).toList();

    upcomingEvents.sort((a, b) {
      if (a.dataDoEvento == null || b.dataDoEvento == null) return 0;
      try {
        DateTime dateA = DateTime.parse(a.dataDoEvento!);
        DateTime dateB = DateTime.parse(b.dataDoEvento!);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    return upcomingEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Próximos Eventos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eventos Imperdíveis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _upcomingEventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum evento futuro encontrado.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Event event = snapshot.data![index];
                        return _buildEventHighlightCard(event);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHighlightCard(Event event) {
    String priceText = 'Gratuito';
    if (event.valorDaEntrada != null) {
      final price = double.tryParse(event.valorDaEntrada.toString());
      if (price != null && price > 0) {
        priceText = 'R\$${price.toStringAsFixed(2)}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: EventPreviewSheet(event: event),
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    event.imagemDoEventoUrl ??
                        'https://via.placeholder.com/400x200',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.nomeDoEvento ?? 'Nome Indefinido',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.dataDoEvento ?? 'Sem data'} ${event.horaDoEvento}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.localDoEvento ?? 'Local Indefinido',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF26422).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priceText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF26422),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
