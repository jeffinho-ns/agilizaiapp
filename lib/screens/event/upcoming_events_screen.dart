// lib/screens/event/upcoming_events_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/widgets/event_preview_sheet.dart';
// REMOVA ESTES IMPORTS, pois não são mais necessários sem WishListProvider:
// import 'package:provider/provider.dart';
// import 'package:agilizaiapp/providers/wish_list_provider.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  late Future<List<Event>> _upcomingEventsFuture;

  @override
  void initState() {
    super.initState();
    _upcomingEventsFuture = _fetchAndFilterUpcomingEvents();
  }

  Future<List<Event>> _fetchAndFilterUpcomingEvents() async {
    final response = await http.get(
      Uri.parse('https://vamos-comemorar-api.onrender.com/api/events/'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Event> allEvents = jsonResponse
          .map((event) => Event.fromJson(event))
          .toList();

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
    } else {
      throw Exception('Falha ao carregar eventos da API');
    }
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
                        // Não precisamos mais passar o `context` para a interação do WishList
                        return _buildEventHighlightCard(
                          event,
                        ); // Contexto removido
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

  // --- ONDE O BOTÃO DE CORAÇÃO FOI REMOVIDO ---
  // O contexto 'BuildContext context' foi removido dos parâmetros pois não é mais necessário para WishList
  Widget _buildEventHighlightCard(Event event) {
    String priceText = 'Gratuito';
    if (event.valorDaEntrada != null) {
      final price = double.tryParse(event.valorDaEntrada.toString());
      if (price != null && price > 0) {
        priceText = 'R\$${price.toStringAsFixed(2)}';
      }
    }

    // REMOVEMOS TODAS AS LINHAS RELACIONADAS AO WISHLISTPROVIDER:
    // final wishListProvider = Provider.of<WishListProvider>(context);
    // bool isFavorite = wishListProvider.isInWishList(event);

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
              // Usamos Stack para posicionar o botão de coração na imagem
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
                // O BLOCO Positioned DO BOTÃO DE CORAÇÃO FOI REMOVIDO DAQUI:
                /*
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          wishListProvider.removeEvent(event);
                        } else {
                          wishListProvider.addEvent(event);
                        }
                      },
                    ),
                  ),
                ),
                */
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
