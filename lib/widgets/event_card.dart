import 'package:agilizaiapp/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/widgets/event_preview_sheet.dart'; // Mantém o import do Preview Sheet
import 'package:intl/intl.dart'; // Para formatação monetária

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});

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
          isScrollControlled: true, // Permite que o sheet ocupe a tela toda
          backgroundColor:
              Colors.transparent, // O fundo do modal é transparente
          builder: (context) {
            return EventPreviewSheet(
              event: event,
            ); // Passa o evento para o sheet
          },
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(
          left: 16,
        ), // Ajuste a margem conforme necessário
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                event.imagemDoEventoUrl ??
                    'https://via.placeholder.com/250x150',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.nomeDoEvento ?? 'Nome Indefinido',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.dataDoEvento ?? 'Data não definida',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.localDoEvento ?? 'Local Indefinido',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _formatPrice(
                              event.valorDaEntrada,
                            ), // Formatado em R$
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF26422),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Ação do botão "Detalhes" dentro do card
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
            ),
          ],
        ),
      ),
    );
  }
}
