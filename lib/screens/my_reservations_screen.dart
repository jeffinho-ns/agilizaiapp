// lib/screens/my_reservations_screen.dart

import 'dart:convert';
import 'package:agilizaiapp/models/reservation_model.dart'; // Seu modelo de reserva
import 'package:agilizaiapp/models/event_model.dart'; // NOVO: Para poder passar um Event (mesmo que parcial/nulo)
import 'package:agilizaiapp/screens/event/event_booked_screen.dart'; // NOVO: Para navegar para EventBookedScreen
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Para o QR Code
import 'package:intl/intl.dart'; // Para formatação de data

// Import da tela para onde o botão "Encontrar Eventos" ou "Novas Reservas" irá.
import 'package:agilizaiapp/screens/main_screen.dart'; // Para navegar para a MainScreen

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentUserId;

  static const String _apiBaseUrl =
      'https://vamos-comemorar-api.onrender.com/api';
  static const String _imageBaseUrl =
      'https://vamos-comemorar-api.onrender.com/uploads/events';

  String _defaultBannerUrl =
      'https://via.placeholder.com/400x200?text=Imagem+Nao+Disponivel';

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
      final String? userIdString = prefs.getString('userId');

      if (userIdString != null) {
        _currentUserId = int.tryParse(userIdString);

        if (_currentUserId == null) {
          throw Exception(
            'ID do usuário inválido. Por favor, faça login novamente.',
          );
        }

        final response = await http.get(
          Uri.parse('$_apiBaseUrl/reservas'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print(
            'DEBUG: JSON da API (Reservas): ${response.body}',
          ); // Adicionado para depuração
          final List<dynamic> allReservationsJson = jsonDecode(response.body);

          final List<Reservation> filteredReservations = allReservationsJson
              .map((json) => Reservation.fromJson(json))
              .where((reserva) => reserva.userId == _currentUserId)
              .toList();

          filteredReservations.sort((a, b) {
            int statusComparison = _getStatusOrder(
              a.statusDaReserva,
            ).compareTo(_getStatusOrder(b.statusDaReserva));
            if (statusComparison != 0) return statusComparison;

            DateTime dateA =
                DateTime.tryParse(a.dataDaReserva ?? '') ?? DateTime(0);
            DateTime dateB =
                DateTime.tryParse(b.dataDaReserva ?? '') ?? DateTime(0);
            return dateA.compareTo(dateB);
          });

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

  int _getStatusOrder(String? status) {
    switch (status) {
      case 'Aprovado':
        return 1;
      case 'Aguardando':
        return 2;
      case 'Cancelado':
        return 3;
      default:
        return 4;
    }
  }

  void _handleReservaClick(Reservation reserva) {
    if (reserva.statusDaReserva == 'Aprovado') {
      // Navega para EventBookedScreen com a reserva
      // Passamos 'null' para o Event, pois o EventBookedScreen agora aceita Event?
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventBookedScreen(
            reservation: reserva,
            event: null, // Event não está disponível aqui, então passamos nulo.
          ),
        ),
      );
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
            reserva.qrcodeUrl != null && reserva.qrcodeUrl!.isNotEmpty
            ? reserva.qrcodeUrl!
            : 'Dados da reserva: ${reserva.nomeDoEvento ?? reserva.casaDaReserva}, ID: ${reserva.id}';

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
              if (qrCodeData.isNotEmpty)
                QrImageView(
                  data: qrCodeData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'Ops! Algo deu errado ao gerar o QR Code.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                )
              else
                const Text(
                  'QR Code não disponível para esta reserva.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              Text(
                // Use ?? 'N/A' para todos os campos que podem ser nulos
                'Evento: ${reserva.nomeDoEvento ?? reserva.casaDaReserva ?? 'N/A'}\n'
                'Data: ${reserva.dataDaReserva != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reserva.dataDaReserva!)) : 'N/A'}\n'
                'Hora: ${reserva.horaDoEvento ?? 'N/A'}\n' // Adicionado
                'Local: ${reserva.localDoEvento ?? 'N/A'}\n' // Adicionado
                'Pessoas: ${reserva.quantidadePessoas ?? 'N/A'}\n'
                'Mesas: ${reserva.mesas ?? 'N/A'}', // Adicionado
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
    return Scaffold(
      // Usando o AppBar padrão do Flutter
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26422),
                        foregroundColor: Colors.white,
                      ),
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
                      // Navega para a MainScreen como a página principal
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => MainScreen(),
                        ), // Assumindo MainScreen é a Home
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26422),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Encontrar Eventos'),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    'Minhas Reservas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final reserva = _reservations[index];
                      final imageUrl =
                          reserva.imagemDoEvento != null &&
                              reserva.imagemDoEvento!.isNotEmpty
                          ? '$_imageBaseUrl/${reserva.imagemDoEvento}'
                          : _defaultBannerUrl;

                      Color statusColor;
                      Color statusBgColor;
                      String statusText;

                      switch (reserva.statusDaReserva) {
                        case 'Aprovado':
                          statusColor = Colors.green[800]!;
                          statusBgColor = Colors.green[100]!;
                          statusText = 'Aprovado';
                          break;
                        case 'Cancelado':
                          statusColor = Colors.red[800]!;
                          statusBgColor = Colors.red[100]!;
                          statusText = 'Cancelado';
                          break;
                        case 'Aguardando':
                        default:
                          statusColor = Colors.orange[800]!;
                          statusBgColor = Colors.orange[100]!;
                          statusText = 'Aguardando';
                          break;
                      }

                      String formattedDate = 'Data Indefinida';
                      if (reserva.dataDaReserva != null) {
                        try {
                          DateTime date = DateTime.parse(
                            reserva.dataDaReserva!,
                          );
                          formattedDate = DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(date);
                        } catch (e) {
                          print(
                            'Erro ao formatar data: ${reserva.dataDaReserva} - $e',
                          );
                        }
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
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 100,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            color: const Color(0xFFF26422),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
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
                                            reserva.casaDaReserva ??
                                            'Evento Desconhecido',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Data: $formattedDate',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      // Adicionando informações detalhadas como no pop-up
                                      if (reserva.horaDoEvento != null &&
                                          reserva.horaDoEvento!.isNotEmpty)
                                        Text(
                                          'Hora: ${reserva.horaDoEvento}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (reserva.localDoEvento != null &&
                                          reserva.localDoEvento!.isNotEmpty)
                                        Text(
                                          'Local: ${reserva.localDoEvento}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (reserva.mesas != null &&
                                          reserva.mesas!.isNotEmpty)
                                        Text(
                                          'Mesas: ${reserva.mesas}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (reserva.quantidadePessoas != null)
                                        Text(
                                          'Pessoas: ${reserva.quantidadePessoas}',
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
                                          statusText,
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
              ],
            ),
    );
  }
}
