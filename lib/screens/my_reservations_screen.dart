// lib/screens/my_reservations_screen.dart

import 'dart:convert';
import 'package:agilizaiapp/models/reservation_model.dart'; // Seu modelo de reserva
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Para o QR Code

// Assumindo que você tem um Header e Footer. Se não, use AppBar e BottomNavigationBar.
// IMPORT TEMPORÁRIO, AJUSTE SE NECESSÁRIO
// import '../components/headernotification/headernotification.dart';
// import '../components/footer/footer.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentUserId; // Para armazenar o ID do usuário logado

  static const String _apiBaseUrl =
      'https://vamos-comemorar-api.onrender.com/api';
  static const String _imageBaseUrl =
      'https://vamos-comemorar-api.onrender.com/uploads/events'; // Base para imagens de eventos

  @override
  void initState() {
    super.initState();
    _fetchMyReservations();
  }

  Future<void> _fetchMyReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('currentUser');

      if (userJson != null) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        _currentUserId =
            userData['id']; // Assumindo que 'id' é o campo no JSON do usuário

        if (_currentUserId == null) {
          throw Exception(
            'ID do usuário não encontrado. Faça login novamente.',
          );
        }

        // 1. Chamar a API para pegar TODAS as reservas (ou todas do usuário se houver rota específica)
        // Conforme a lógica do Next.js, estamos pegando TUDO e filtrando no cliente.
        // Se você tiver a rota GET /api/reservas?userId=X, use-a para maior eficiência!
        final response = await http.get(
          Uri.parse('$_apiBaseUrl/reservas'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> allReservationsJson = jsonDecode(response.body);

          // 2. Filtrar as reservas no lado do cliente (Flutter), como no Next.js
          final List<Reservation> filteredReservations = allReservationsJson
              .map((json) => Reservation.fromJson(json))
              .where((reserva) => reserva.userId == _currentUserId)
              .toList();

          _reservations = filteredReservations;
        } else {
          final errorBody = jsonDecode(response.body);
          throw Exception(
            'Falha ao carregar reservas: ${errorBody['error'] ?? response.statusCode}',
          );
        }
      } else {
        throw Exception('Nenhum usuário logado. Por favor, faça login.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar suas reservas: ${e.toString()}';
      });
      print('DEBUG: Erro ao carregar minhas reservas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleReservaClick(Reservation reserva) {
    if (reserva.statusDaReserva == 'Aprovado') {
      _showQrCodePopup(reserva);
    } else if (reserva.statusDaReserva == 'Aguardando') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sua reserva está aguardando aprovação."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status da reserva: ${reserva.statusDaReserva}"),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  void _showQrCodePopup(Reservation reserva) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String qrCodeData =
            reserva.qrcodeUrl ??
            'Dados do evento: ${reserva.nomeDoEvento ?? reserva.casaDaReserva} ID: ${reserva.id}';
        // Se o qrcodeUrl não vier direto do backend, você pode gerar um com dados da reserva
        // Exemplo: 'Tipo: Reserva; ID: ${reserva.id}; Evento: ${reserva.nomeDoEvento ?? reserva.casaDaReserva}'

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
                  return const Center(
                    child: Text(
                      'Ops! Algo deu errado ao gerar o QR Code.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Evento: ${reserva.nomeDoEvento ?? reserva.casaDaReserva}\nData: ${reserva.dataDaReserva}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apresente este QR Code na entrada do evento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
    // String defaultBanner = 'https://i.imgur.com/715zr01.jpeg'; // Ou um asset local
    String defaultBanner =
        'https://via.placeholder.com/150'; // Placeholder genérico

    return Scaffold(
      // Se você tiver os componentes Header/Footer, use-os assim:
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(60.0), // Ajuste a altura conforme seu Header
      //   child: Header(),
      // ),
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF26422)),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchMyReservations,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            )
          : _reservations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sentiment_dissatisfied,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Você não possui nenhuma reserva ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      ); // Voltar para a tela inicial
                      // Ou para a tela de lista de eventos: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EventsListingScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Fazer Nova Reserva'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minhas Reservas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final reserva = _reservations[index];
                        final imageUrl = reserva.imagemDoEvento != null
                            ? '$_imageBaseUrl/${reserva.imagemDoEvento}'
                            : defaultBanner;

                        Color statusColor;
                        Color statusBgColor;
                        switch (reserva.statusDaReserva) {
                          case 'Aprovado':
                            statusColor = Colors.green[600]!;
                            statusBgColor = Colors.green[100]!;
                            break;
                          case 'Cancelado':
                            statusColor = Colors.red[600]!;
                            statusBgColor = Colors.red[100]!;
                            break;
                          default: // Aguardando
                            statusColor = Colors.orange[600]!;
                            statusBgColor = Colors.orange[100]!;
                            break;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _handleReservaClick(reserva),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 100,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reserva.nomeDoEvento ??
                                              reserva
                                                  .casaDaReserva, // Nome do evento ou da casa
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Data: ${reserva.dataDaReserva}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusBgColor,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            reserva.statusDaReserva,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        ); // Volta para a rota inicial (MainScreen)
                        // Ou router.push('/') se você tiver uma rota nomeada para a Home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fazer Novas Reservas',
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
      // Se você tiver o componente Footer, use-o assim:
      // bottomNavigationBar: Footer(),
    );
  }
}
