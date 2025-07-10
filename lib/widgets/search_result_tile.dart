// lib/widgets/search_result_tile.dart

import 'package:agilizaiapp/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchResultTile extends StatelessWidget {
  final Event event;

  const SearchResultTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Usando 'valorDaEntrada' (com 'a') e tratando como dynamic
    String price = '\$0 USD'; // Valor padrão
    if (event.valorDaEntrada != null) {
      price = '\$${event.valorDaEntrada} USD';
    }

    String formattedDate = 'Data indefinida';
    if (event.dataDoEvento != null) {
      try {
        final date = DateTime.parse(event.dataDoEvento!);
        formattedDate = DateFormat('dd MMM, yyyy').format(date);
      } catch (e) {
        formattedDate = event.dataDoEvento!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              event.imagemDoEventoUrl ?? 'https://via.placeholder.com/150',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // CORREÇÃO: Adicionando valor padrão para nulos
                  event.nomeDoEvento ?? 'Evento sem nome',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // CORREÇÃO: Adicionando valor padrão para nulos
                  '$formattedDate • ${event.localDoEvento ?? 'Local indefinido'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price, // Usando a variável corrigida
                style: const TextStyle(
                  color: Color(0xFFF26422),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'JOIN NOW',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
