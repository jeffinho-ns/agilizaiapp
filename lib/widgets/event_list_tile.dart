import 'package:agilizaiapp/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/widgets/event_preview_sheet.dart'; // NOVO: Importe o Preview Sheet
import 'package:intl/intl.dart'; // Para formatação monetária

class EventListTile extends StatelessWidget {
  final Event event;
  const EventListTile({super.key, required this.event});

  // Função auxiliar para formatar o preço em R$
  String _formatPrice(dynamic price) {
    if (price == null) {
      return 'Grátis';
    }
    try {
      final number = price is String
          ? double.tryParse(price)
          : price.toDouble();
      if (number == null || number == 0) {
        return 'Grátis';
      }
      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      return formatter.format(number);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Abre o EventPreviewSheet como um modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return EventPreviewSheet(
              event: event,
            ); // Passa o evento para o sheet
          },
        );
      },
      borderRadius: BorderRadius.circular(
        12, // Bordas arredondadas para o InkWell
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
        ),
        child: Row(
          children: [
            // Imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                event.imagemDoEventoUrl ?? 'https://via.placeholder.com/80x80',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Textos e botão
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.nomeDoEvento ?? 'Nome Indefinido',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.dataDoEvento ?? 'Sem data'} • ${event.localDoEvento ?? 'Local Indefinido'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(event.valorDaEntrada), // Formatado em R$
                        style: const TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Ação do botão "Detalhes" dentro do tile
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return EventPreviewSheet(event: event);
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF242A38),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('VER PRÉVIA'), // Traduzido
                      ),
                    ],
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
