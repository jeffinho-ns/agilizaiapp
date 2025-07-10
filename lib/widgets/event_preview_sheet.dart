// lib/widgets/event_preview_sheet.dart

import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/screens/event/event_details_screen.dart'; // Importa a tela de detalhes
import 'package:flutter/material.dart';

class EventPreviewSheet extends StatelessWidget {
  final Event event;
  // A única mudança: Tornamos o scrollController opcional para compatibilidade.
  final ScrollController? scrollController;

  const EventPreviewSheet({
    super.key,
    required this.event,
    this.scrollController, // Ele pode ser nulo agora
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Fundo transparente para o modal
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Image.network(
                event.imagemDoEventoUrl ?? 'https://i.imgur.com/715zr01.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey);
                },
              ),
            ),
          ),
          // Gradiente
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Botões de Voltar e Favoritar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopIconButton(
                  context,
                  Icons.arrow_back,
                  () => Navigator.of(context).pop(),
                ),
                _buildTopIconButton(
                  context,
                  Icons.favorite,
                  () {},
                  color: Colors.red,
                ),
              ],
            ),
          ),
          // Conteúdo principal
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize
                  .min, // Para a coluna não tentar ocupar todo o espaço
              children: [
                Text(
                  event.nomeDoEvento ?? 'Nome Indefinido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.location_on,
                  event.localDoEvento ?? 'Local Indefinido',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  event.dataDoEvento ?? 'Data não definida',
                ),
                const SizedBox(height: 24),
                _buildMembersRow(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          // Passe o evento aqui
                          builder: (_) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26422),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: const Text(
                      'CHOOSE YOUR SEAT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os botões do topo
  Widget _buildTopIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    Color color = Colors.white,
  }) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white.withOpacity(0.15),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  // Widget auxiliar para as linhas de informação (local, data)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        // Expanded para garantir que o texto não quebre o layout
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget para a seção de membros
  Widget _buildMembersRow() {
    // Avatares empilhados
    final avatars = [
      _buildMemberAvatar('https://randomuser.me/api/portraits/women/1.jpg'),
      _buildMemberAvatar('https://randomuser.me/api/portraits/men/2.jpg'),
      _buildMemberAvatar('https://randomuser.me/api/portraits/women/3.jpg'),
      _buildMemberAvatar('https://randomuser.me/api/portraits/men/4.jpg'),
    ];

    return Row(
      children: [
        SizedBox(
          width: 100, // Largura total para os avatares empilhados
          height: 40,
          child: Stack(
            children: List.generate(avatars.length, (index) {
              return Positioned(
                left: index * 25.0, // Espaçamento entre os avatares
                child: avatars[index],
              );
            }),
          ),
        ),
        const SizedBox(width: 8),

        // SOLUÇÃO: Envolver o Text com o widget Expanded.
        // Ele força o texto a usar apenas o espaço restante na linha.
        const Expanded(
          child: Text(
            '15.7K+ Members are joined',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            // Boa prática: adicionar overflow para cortar o texto com "..." se
            // o espaço for extremamente pequeno.
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget para cada avatar de membro
  Widget _buildMemberAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white, // Borda branca
      child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(imageUrl)),
    );
  }
}
