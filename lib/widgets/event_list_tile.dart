import 'package:agilizaiapp/models/event_model.dart';
import 'package:flutter/material.dart';

class EventListTile extends StatelessWidget {
  final Event event;
  const EventListTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 1. Adicionado InkWell para ser clicável
      onTap: () {
        // 2. Ação que vai acontecer ao clicar (vamos preencher no próximo passo)
        print('Card do evento ${event.nomeDoEvento} clicado!');
      },
      borderRadius: BorderRadius.circular(
        20,
      ), // Para o efeito de splash seguir as bordas
      child: Container(
        // O resto do seu Container continua exatamente o mesmo...
        width: 250,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
        ),
        child: Row(
          children: [
            // Imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                event.imagemDoEventoUrl ?? 'https://via.placeholder.com/100',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
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
                    '${event.dataDoEvento ?? 'Sem data'} • ${event.localDoEvento}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '\$10. USD', // Placeholder do preço
                        style: TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
                        child: const Text('JOIN NOW'),
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
