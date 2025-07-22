import 'dart:convert'; // Para jsonDecode
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/models/reservation_model.dart'; // Importe o modelo de Reservation
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Para buscar o usuário logado
import 'package:qr_flutter/qr_flutter.dart'; // Para exibir o QR Code
import 'package:intl/intl.dart'; // Para formatação de data

class EventBookedScreen extends StatefulWidget {
  final Reservation reservation;
  final Event? event; // Evento agora é opcional

  const EventBookedScreen({
    super.key,
    required this.reservation,
    this.event, // Torne o evento opcional
  });

  @override
  State<EventBookedScreen> createState() => _EventBookedScreenState();
}

class _EventBookedScreenState extends State<EventBookedScreen> {
  // URLs da API (mantenha consistência com event_details.dart)
  static const String _imageBaseUrl =
      'https://vamos-comemorar-api.onrender.com/uploads/events';

  String _getImageUrl() {
    if (widget.event?.imagemDoEventoUrl != null &&
        widget.event!.imagemDoEventoUrl!.isNotEmpty) {
      return widget.event!.imagemDoEventoUrl!;
    }
    if (widget.reservation.imagemDoEvento != null &&
        widget.reservation.imagemDoEvento!.isNotEmpty) {
      return '$_imageBaseUrl/${widget.reservation.imagemDoEvento}';
    }
    return 'https://i.imgur.com/715zr01.jpeg'; // Fallback
  }

  // Função para exibir o SnackBar de "Aguardando Aprovação"
  void _showPendingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sua reserva está aguardando aprovação."), // Traduzido
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Função para exibir o popup com o QR Code
  void _showQrCodePopup(String qrCodeData) {
    print('DEBUG (showQrCodePopup): Dados do QR Code recebidos: $qrCodeData');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define a largura do popup para ser 80% da tela, mas no máximo 350 pixels.
        final popupWidth = (MediaQuery.of(context).size.width * 0.8).clamp(
          250.0,
          350.0,
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Seu Ingresso', // Traduzido de 'Your Ticket'
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Defina um padding customizado para o conteúdo para remover o espaço extra padrão.
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
          // A SOLUÇÃO ESTÁ AQUI: Envolvemos a Column em um SizedBox com largura definida.
          content: SizedBox(
            width: popupWidth,
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Essencial para a coluna não tentar preencher verticalmente
              children: [
                if (qrCodeData.isNotEmpty)
                  QrImageView(
                    data: qrCodeData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                    errorStateBuilder: (cxt, err) {
                      print(
                        'DEBUG (QrImageView Error): Erro ao gerar QrImageView: $err',
                      );
                      return const Center(
                        child: Text(
                          'Ops! Algo deu errado ao gerar o QR Code.', // Traduzido
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.0),
                    child: Text(
                      'QR Code não disponível para esta reserva.', // Traduzido
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                // O Text agora não precisa mais de um SizedBox com largura infinita.
                Text(
                  'Evento: ${widget.reservation.nomeDoEvento ?? widget.reservation.casaDaReserva ?? 'N/A'}\n'
                  'Data: ${widget.reservation.dataDaReserva != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.reservation.dataDaReserva!)) : 'N/A'}\n'
                  'Hora: ${widget.reservation.horaDoEvento ?? 'N/A'}\n'
                  'Local: ${widget.reservation.localDoEvento ?? 'N/A'}\n'
                  'Pessoas: ${widget.reservation.quantidadePessoas ?? 'N/A'}\n'
                  'Mesas: ${widget.reservation.mesas ?? 'N/A'}', // Todas as labels dentro do texto
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Apresente este QR Code na entrada do evento.', // Traduzido
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24), // Espaço antes dos botões
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fechar', // Traduzido de 'Close'
                style: TextStyle(
                  color: Color(0xFFF26422),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          // Centraliza os botões (actions)
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se não está carregando e não há erro, exibe o conteúdo
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // Passa a reserva para o widget de detalhes
              _buildEventDetailsPanel(context),
              const SizedBox(height: 24),
              _buildOrganizerInfo(), // Mantém o organizador mockado por enquanto, ou você pode buscar do evento ou de outra API
              const SizedBox(height: 24),
              _buildDescription(),
              const SizedBox(height: 32),
              _buildMessagesButton(),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _getImageUrl(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildActionCards(),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // Ação para o botão de coração
            },
          ),
        ),
      ],
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.call, 'Ligar', () {
            // Traduzido de 'Call'
            print('Ligar clicado');
            // Implementar ação de chamada
          }),
          _buildActionButton(Icons.directions, 'Direções', () {
            // Traduzido de 'Directions'
            print('Direções clicado');
            // Implementar ação de direções (e.g., abrir mapa)
          }),
          // Condição para o botão "My Ticket"
          _buildActionButton(Icons.confirmation_num_outlined, 'Meu Ingresso',
              () {
            // Traduzido de 'My Ticket'
            if (widget.reservation.statusDaReserva == 'Aprovado') {
              if (widget.reservation.qrcodeUrl != null &&
                  widget.reservation.qrcodeUrl!.isNotEmpty) {
                _showQrCodePopup(widget.reservation.qrcodeUrl!);
              } else {
                _showQrCodePopup(
                  'https://example.com/default-qrcode-data-${widget.reservation.id}',
                ); // Fallback ou dados do evento
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "URL do QR Code não disponível, exibindo um genérico.", // Traduzido
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else if (widget.reservation.statusDaReserva == 'Aguardando') {
              _showPendingMessage();
            } else {
              // Se o status for outro (e.g., 'Rejeitado', 'Cancelado' ou desconhecido)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Status da reserva: ${widget.reservation.statusDaReserva ?? 'Desconhecido'}", // Traduzido
                  ),
                  backgroundColor: Colors.grey,
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // _buildActionButton agora recebe uma função onPressed
  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed, // Usa a função passada como parâmetro
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFF26422), size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildEventDetailsPanel agora recebe a reserva para exibir as informações
  Widget _buildEventDetailsPanel(BuildContext context) {
    String displayDate = widget.reservation.dataDaReserva != null
        ? DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(DateTime.parse(widget.reservation.dataDaReserva!))
        : widget.event?.dataDoEvento ?? 'Data Indefinida';

    String displayTime = widget.reservation.horaDoEvento ??
        widget.event?.horaDoEvento ??
        'Hora Indefinida';

    String bookingStatusText = 'Status Desconhecido'; // Traduzido
    Color bookingStatusColor = Colors.grey;

    if (widget.reservation.statusDaReserva == 'Aprovado') {
      bookingStatusText = 'APROVADO'; // Traduzido
      bookingStatusColor = Colors.green;
    } else if (widget.reservation.statusDaReserva == 'Aguardando') {
      bookingStatusText = 'AGUARDANDO'; // Traduzido
      bookingStatusColor = Colors.orange;
    } else if (widget.reservation.statusDaReserva == 'Rejeitado' ||
        widget.reservation.statusDaReserva == 'Cancelado') {
      bookingStatusText = 'REJEITADO'; // Traduzido. Ou 'CANCELADO'
      bookingStatusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // Usar Flexible para o nome do evento
                  child: Text(
                    widget.reservation.nomeDoEvento ??
                        widget.event?.nomeDoEvento ??
                        widget.reservation.casaDaReserva ??
                        'Nome Indefinido', // Traduzido
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bookingStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bookingStatusText,
                    style: TextStyle(
                      color: bookingStatusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Aumentei o espaçamento aqui
            // NOVO: Separar Local e Data/Hora para melhor organização e evitar overflow
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinhar ícones e texto no topo
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  // Usar Expanded para o local
                  child: Text(
                    widget.reservation.localDoEvento ??
                        widget.event?.localDoEvento ??
                        'Local Indefinido', // Traduzido
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines:
                        2, // Permite quebrar a linha em duas se for muito longo
                    overflow: TextOverflow
                        .ellipsis, // Adiciona "..." se exceder 2 linhas
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Espaçamento entre Local e Data/Hora
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  displayDate,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 16), // Espaçamento entre Data e Hora
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  displayTime,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Exibir a quantidade de pessoas da reserva e mesas
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                // Alterado de Row para Column
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Alinha o conteúdo da coluna à esquerda
                children: [
                  Row(
                    // Este Row conterá as informações de Pessoas
                    children: [
                      const Icon(Icons.people, color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.reservation.quantidadePessoas ?? 'N/A'} Pessoa(s)', // Traduzido
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ), // Espaçamento entre as duas linhas de informação
                  Row(
                    // Este novo Row conterá as informações de Mesas
                    children: [
                      const Icon(Icons.table_bar, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Mesas: ${widget.reservation.mesas ?? 'N/A'}', // Traduzido
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Poderíamos buscar o número de membros da API aqui também
                const Flexible(
                  // Adicionado Flexible aqui para o texto não causar overflow
                  child: Text(
                    '15.7K+ Membros confirmados:', // Traduzido de '15.7K+ Members are joined:'
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Ação para VER TODOS / CONVIDAR
                  },
                  child: const Text(
                    'VER TODOS / CONVIDAR', // Traduzido de 'VIEW ALL / INVITE'
                    style: TextStyle(
                      color: Color(0xFFF26422),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMemberAvatars(), // Mantém os avatares mockados por enquanto
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatars() {
    // Isso ainda usa dados mockados. Se quiser que seja dinâmico,
    // sua API precisaria fornecer uma lista de participantes do evento.
    final List<User> mockMembers = [
      User(
        id: 1,
        name: 'Membro A',
        email: 'a@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/women/1.jpg',
      ),
      User(
        id: 2,
        name: 'Membro B',
        email: 'b@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/men/2.jpg',
      ),
      User(
        id: 3,
        name: 'Membro C',
        email: 'c@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/women/3.jpg',
      ),
      User(
        id: 4,
        name: 'Membro D',
        email: 'd@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/men/4.jpg',
      ),
    ];

    return SizedBox(
      width:
          100, // Ajuste este valor se tiver mais avatares ou tamanhos diferentes
      height: 40,
      child: Stack(
        children: List.generate(mockMembers.length, (index) {
          final memberImageUrl = mockMembers[index].fotoPerfil ??
              'https://via.placeholder.com/150';
          return Positioned(
            left: index * 25.0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(memberImageUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  print('Erro ao carregar imagem do avatar: $exception');
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrganizerInfo() {
    // Mantendo o organizador mockado por enquanto, pois não está vindo diretamente do Event ou Reservation
    // Se sua API de eventos ou de casas de evento retornar os dados do organizador,
    // você poderia buscá-los aqui.
    final User mockOrganizer = User(
      id: 1,
      name: 'Tamim Ikram',
      email: 'tamim.ikram@example.com',
      fotoPerfil: 'https://randomuser.me/api/portraits/men/5.jpg',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    mockOrganizer.fotoPerfil ??
                        'https://i.imgur.com/715zr01.jpeg',
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Erro ao carregar imagem do organizador: $exception');
                  },
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mockOrganizer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Organizador do Evento', // Traduzido de 'Event Organiser'
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildCircularButton(Icons.chat_bubble_outline),
                const SizedBox(width: 12),
                _buildCircularButton(Icons.call_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      child: Icon(icon, color: Colors.black54, size: 20),
    );
  }

  Widget _buildDescription() {
    // Usa a descrição do evento que veio no `Event` model, se disponível
    String descriptionText =
        widget.event?.descricao ?? 'Sem descrição disponível.'; // Traduzido
    String displayDescription = descriptionText.length > 150
        ? '${descriptionText.substring(0, 150)}...'
        : descriptionText;
    bool isLongDescription = descriptionText.length > 150;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descrição', // Traduzido de 'Description'
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              children: [
                TextSpan(text: displayDescription),
                if (isLongDescription)
                  const TextSpan(
                    text: ' Ler Mais', // Traduzido de 'Read More'
                    style: TextStyle(
                      color: Color(0xFFF26422),
                      fontWeight: FontWeight.bold,
                    ),
                    // Você pode adicionar um `TapGestureRecognizer` aqui se quiser expandir a descrição
                    // recognizer: TapGestureRecognizer()..onTap = () {
                    //    print('Read More clicado (Event Booked Screen)');
                    // },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Ação para o botão de mensagens
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Funcionalidade de mensagens em breve!"), // Traduzido
                backgroundColor: Colors.blue,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C2C2C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Mensagens', // Traduzido de 'Messages'
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
