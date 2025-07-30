// lib/screens/my_reservations_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:agilizaiapp/screens/reservation/reservation_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late Future<List<Reservation>> _reservationsFuture;
  final ReservationService _reservationService = ReservationService();
  String? _currentUserName; // Para armazenar o nome do usuário logado

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData(); // Carrega o nome do usuário logado
    _fetchReservations();
  }

  // Novo método para carregar o nome do usuário logado do SharedPreferences
  Future<void> _loadCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Certifique-se que você está salvando o nome do usuário com a chave 'userName' no seu login
    setState(() {
      _currentUserName = prefs.getString('userName');
    });
    print(
        'Nome do usuário logado (MyReservationsScreen): $_currentUserName'); // Para depuração
  }

  void _fetchReservations() {
    setState(() {
      _reservationsFuture = _reservationService.fetchAllUserReservations();
    });
    _reservationsFuture.then((reservas) {
      print('Reservas carregadas: $reservas');
    }).catchError((error) {
      print('Erro ao carregar reservas no THEN: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar reservas: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Você não tem nenhuma reserva.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final reservations = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];

                String formattedDate = 'N/A';
                if (reservation.dataDoEvento != null &&
                    reservation.dataDoEvento!.isNotEmpty) {
                  try {
                    formattedDate = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(reservation.dataDoEvento!));
                  } catch (e) {
                    print(
                        'Erro ao parsear data do evento ${reservation.dataDoEvento}: $e');
                    formattedDate = reservation.dataDoEvento!;
                  }
                }

                Color statusColor = Colors.grey;
                if (reservation.status == 'ATIVA') {
                  statusColor = Colors.green[700]!;
                } else if (reservation.status == 'CANCELADA') {
                  statusColor = Colors.red[700]!;
                } else if (reservation.status == 'CONCLUIDA') {
                  statusColor = Colors.blue[700]!;
                }

                // Lógica para determinar quem criou a lista
                String creatorDisplayName;
                if (reservation.creatorName != null &&
                    _currentUserName != null &&
                    reservation.creatorName == _currentUserName) {
                  creatorDisplayName = 'Você';
                } else {
                  creatorDisplayName = reservation.creatorName ?? 'N/A';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => ReservationDetailsScreen(
                                reservationId: reservation.id,
                              ),
                            ),
                          )
                          .then((_) => _fetchReservations());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nome do Evento em destaque (como na sua última tentativa)
                                    Text(
                                      reservation.nomeDoEvento ??
                                          'Evento Sem Nome',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    // Nome do criador da lista como subtítulo
                                    Text(
                                      'Criado por: $creatorDisplayName', // Usando a nova lógica aqui
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  reservation.status ?? 'N/A',
                                  style: TextStyle(
                                    color: statusColor,
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
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Data: $formattedDate às ${reservation.horaDoEvento ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Convidados: ${reservation.quantidadeConvidados}',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
