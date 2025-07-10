// lib/widgets/event_timeline_tile.dart

import 'package:agilizaiapp/models/event_model.dart'; // Usando seu modelo oficial
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTimelineTile extends StatelessWidget {
  final Event event; // Agora usa a classe 'Event'
  const EventTimelineTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    DateTime? eventDate;
    if (event.dataDoEvento != null && event.dataDoEvento!.isNotEmpty) {
      try {
        eventDate = DateTime.parse(event.dataDoEvento!);
      } catch (e) {
        print("Erro ao converter data do evento: $e");
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              event.imagemDoEventoUrl ?? 'https://via.placeholder.com/150',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.nomeDoEvento ?? 'Evento sem nome',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${eventDate != null ? DateFormat.jm().format(eventDate) : event.horaDoEvento ?? ''} • ${event.localDoEvento ?? 'Local indefinido'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
