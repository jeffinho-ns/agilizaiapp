import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/screens/event/event_booked_screen.dart';
import 'package:agilizaiapp/services/reservation_service.dart'; // NOVO: Usando o serviço correto
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _fetchMyReservations();
  }

  Future<List<Reservation>> _fetchMyReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('userId');
      if (userIdString == null) {
        throw Exception('Usuário não logado.');
      }
      final userId = int.parse(userIdString);

      // A mágica acontece aqui: chamando a nova rota da API através do serviço
      final reservationsData =
          await _reservationService.getMyReservations(userId);

      // Mapeia a lista de JSONs para uma lista de objetos Reservation
      return reservationsData
          .map((json) => Reservation.fromJson(json))
          .toList();
    } catch (e) {
      // Propaga o erro para o FutureBuilder poder tratar
      throw Exception('Erro ao carregar suas reservas: ${e.toString()}');
    }
  }

  void _handleReservaClick(Reservation reserva) {
    // A MUDANÇA ESTÁ AQUI: Passamos apenas o ID da reserva.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventBookedScreen(
          reservaId: reserva.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Você não possui nenhuma reserva ainda.'));
          }

          final reservations = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reserva = reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(reserva.nomeLista,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reserva.dataReserva))}\nStatus: ${reserva.status}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  isThreeLine: true,
                  onTap: () => _handleReservaClick(reserva),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
