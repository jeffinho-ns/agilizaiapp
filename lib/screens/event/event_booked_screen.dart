import 'dart:convert'; // Para jsonDecode
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/models/reservation_model.dart'; // NOVO: Importe o modelo de Reservation
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Para buscar o usuário logado
import 'package:qr_flutter/qr_flutter.dart'; // NOVO: Para exibir o QR Code

class EventBookedScreen extends StatefulWidget {
  final Event event;
  const EventBookedScreen({super.key, required this.event});

  @override
  State<EventBookedScreen> createState() => _EventBookedScreenState();
}

class _EventBookedScreenState extends State<EventBookedScreen> {
  User? _currentUser; // Para armazenar os dados do usuário logado
  Reservation? _currentReservation; // Para armazenar os detalhes da reserva
  bool _isLoading = true; // Para gerenciar o estado de carregamento
  String? _errorMessage; // Para exibir mensagens de erro

  // URLs da API (mantenha consistência com event_details.dart)
  static const String _apiBaseUrl =
      'https://vamos-comemorar-api.onrender.com/api/events';

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndReservation();
  }

  // Função para buscar os dados do usuário logado e a reserva
  Future<void> _fetchUserDataAndReservation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Buscar o usuário logado do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('currentUser');
      if (userJson == null) {
        throw Exception('Usuário não logado. Faça login novamente.');
      }
      _currentUser = User.fromJson(jsonDecode(userJson));

      // 2. Buscar a reserva específica para este evento e usuário
      // Para isso, sua API precisa de um endpoint para buscar reservas por userId e eventId
      // Exemplo: GET /api/reservations?userId=X&eventId=Y
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/reservas?userId=${_currentUser!.id}&eventId=${widget.event.id}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservationsJson = jsonDecode(response.body);
        if (reservationsJson.isNotEmpty) {
          // Pega a primeira reserva encontrada, ou implemente lógica se houver múltiplas
          _currentReservation = Reservation.fromJson(reservationsJson.first);
        } else {
          throw Exception('Nenhuma reserva encontrada para este evento.');
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Falha ao carregar reserva: ${errorBody['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: ${e.toString()}';
      });
      print('DEBUG: Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para exibir o SnackBar de "Aguardando Aprovação"
  void _showPendingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sua reserva está aguardando aprovação."),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Função para exibir o popup com o QR Code
  void _showQrCodePopup(String qrCodeData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Seu Ingresso',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrCodeData, // Use a URL do QR Code ou dados reais
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
                  return const Center(
                    child: Text(
                      'Ops! Algo deu errado ao gerar o QR Code.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Apresente este QR Code na entrada do evento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
              },
              child: const Text(
                'Fechar',
                style: TextStyle(
                  color: Color(0xFFF26422),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF26422)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchUserDataAndReservation,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Se não está carregando e não há erro, exibe o conteúdo
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // Passa a reserva para o widget de detalhes
              _buildEventDetailsPanel(context, _currentReservation),
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
              widget.event.imagemDoEventoUrl ??
                  'https://i.imgur.com/715zr01.jpeg',
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
          _buildActionButton(Icons.call, 'Call', () {
            print('Call clicado');
            // Implementar ação de chamada
          }),
          _buildActionButton(Icons.directions, 'Directions', () {
            print('Directions clicado');
            // Implementar ação de direções (e.g., abrir mapa)
          }),
          // Condição para o botão "My Ticket"
          _buildActionButton(Icons.confirmation_num_outlined, 'My Ticket', () {
            if (_currentReservation?.statusDaReserva == 'approved') {
              // Supondo que o status 'approved' significa aprovado
              if (_currentReservation?.qrcodeUrl != null &&
                  _currentReservation!.qrcodeUrl!.isNotEmpty) {
                _showQrCodePopup(_currentReservation!.qrcodeUrl!);
              } else {
                _showQrCodePopup(
                  'https://example.com/default-qrcode-data-${_currentReservation?.id}',
                ); // Fallback ou dados do evento
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "QR Code URL não disponível, exibindo um genérico.",
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else if (_currentReservation?.statusDaReserva == 'pending') {
              // Supondo que 'pending' significa aguardando
              _showPendingMessage();
            } else {
              // Se o status for outro (e.g., 'rejected', 'cancelled' ou desconhecido)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Status da reserva: ${_currentReservation?.statusDaReserva ?? 'Desconhecido'}",
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
  Widget _buildEventDetailsPanel(
    BuildContext context,
    Reservation? reservation,
  ) {
    String displayDate = widget.event.dataDoEvento ?? 'Data Indefinida';
    String bookingStatusText = 'Status Desconhecido';
    Color bookingStatusColor = Colors.grey;

    if (reservation != null) {
      if (reservation.statusDaReserva == 'approved') {
        bookingStatusText = 'APROVADO';
        bookingStatusColor = Colors.green;
      } else if (reservation.statusDaReserva == 'pending') {
        bookingStatusText = 'AGUARDANDO';
        bookingStatusColor = Colors.orange;
      } else if (reservation.statusDaReserva == 'rejected') {
        bookingStatusText = 'REJEITADO';
        bookingStatusColor = Colors.red;
      }
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
                  child: Text(
                    widget.event.nomeDoEvento ?? 'Nome Indefinido',
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.event.localDoEvento ?? 'Local Indefinido',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  displayDate,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Exibir a quantidade de pessoas da reserva
            if (reservation != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${reservation.quantidadePessoas} Pessoa(s)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.table_bar, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Mesas: ${reservation.mesas ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Poderíamos buscar o número de membros da API aqui também
                const Text(
                  '15.7K+ Members are joined:', // Mantenho mockado por enquanto, mas pode ser dinâmico
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    // Ação para VIEW ALL / INVITE
                  },
                  child: const Text(
                    'VIEW ALL / INVITE',
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
        name: 'Member A',
        email: 'a@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/women/1.jpg',
      ),
      User(
        id: 2,
        name: 'Member B',
        email: 'b@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/men/2.jpg',
      ),
      User(
        id: 3,
        name: 'Member C',
        email: 'c@example.com',
        fotoPerfil: 'https://randomuser.me/api/portraits/women/3.jpg',
      ),
      User(
        id: 4,
        name: 'Member D',
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
          final memberImageUrl =
              mockMembers[index].fotoPerfil ??
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
                    'Event Organiser',
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
    // Usa a descrição do evento que veio no `Event` model
    String descriptionText =
        widget.event.descricao ?? 'Sem descrição disponível.';
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
            'Description',
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
                  TextSpan(
                    text: ' Read More',
                    style: const TextStyle(
                      color: Color(0xFFF26422),
                      fontWeight: FontWeight.bold,
                    ),
                    // Você pode adicionar um `TapGestureRecognizer` aqui se quiser expandir a descrição
                    // recognizer: TapGestureRecognizer()..onTap = () {
                    //   print('Read More clicado (Event Booked Screen)');
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
                content: Text("Funcionalidade de mensagens em breve!"),
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
            'Messages',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
