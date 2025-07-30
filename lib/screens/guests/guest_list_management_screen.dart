// lib/screens/guests/guest_list_management_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/guest_model.dart';
import 'package:agilizaiapp/services/event_service.dart'; // Para EventService, usado para selfCheckInGuest
import 'package:agilizaiapp/services/reservation_service.dart'; // Para ReservationService
import 'package:agilizaiapp/models/reservation_model.dart'; // Importar o modelo Reservation
import 'package:geolocator/geolocator.dart'; // Para geolocalização

class GuestListManagementScreen extends StatefulWidget {
  final Event event;

  const GuestListManagementScreen({super.key, required this.event});

  @override
  State<GuestListManagementScreen> createState() =>
      _GuestListManagementScreenState();
}

class _GuestListManagementScreenState extends State<GuestListManagementScreen> {
  // Alterado para Future<List<Reservation>> para buscar as reservas do evento
  late Future<List<Reservation>> _reservationsFuture;
  final ReservationService _reservationService = ReservationService();
  final EventService _eventService = EventService(); // Para o self check-in

  @override
  void initState() {
    super.initState();
    _fetchReservationsForEvent();
  }

  void _fetchReservationsForEvent() {
    setState(() {
      _reservationsFuture =
          _reservationService.fetchReservationsByEventId(widget.event.id);
    });
  }

  // Método para solicitar permissão de localização (copiado de ReservationDetailsScreen)
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Serviços de localização desativados. Ative-os para confirmar a presença.'),
            backgroundColor: Colors.red),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Permissão de localização negada. Conceda-a nas configurações do app.'),
              backgroundColor: Colors.red),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Permissão de localização permanentemente negada. Você precisa alterá-la nas configurações do dispositivo.'),
            backgroundColor: Colors.red),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Lógica para o self check-in do convidado (copiado de ReservationDetailsScreen)
  Future<void> _selfCheckIn(Guest guest) async {
    if (guest.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ID do convidado inválido.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final position = await _getCurrentLocation();
      if (position == null) {
        Navigator.pop(context);
        return;
      }

      final response = await _eventService.selfCheckInGuest(
        guest.id,
        position.latitude,
        position.longitude,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.green),
      );
      _fetchReservationsForEvent(); // Recarregar detalhes para atualizar o status na UI
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro no check-in: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
      print('Erro ao tentar self check-in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convidados do Evento: ${widget.event.nomeDoEvento}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Reservation>>(
        // Tipo Reservation encontrado
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Nenhuma reserva encontrada para este evento.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final reservation = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(
                        'Lista: ${reservation.nomeLista} (${reservation.quantidadeConvidados} convidados)'),
                    subtitle: Text('Status: ${reservation.status}'),
                    children: [
                      if (reservation.convidados != null &&
                          reservation.convidados!.isNotEmpty)
                        ...reservation.convidados!.map((guest) {
                          // Condições para exibir o botão de confirmação
                          final bool showConfirmButton = (guest.status ==
                                  'CHECK-IN' // Já fez check-in na entrada
                              &&
                              guest.geoCheckinStatus !=
                                  'CONFIRMADO_LOCAL'); // E ainda não confirmou local

                          final Color statusColor =
                              guest.geoCheckinStatus == 'CONFIRMADO_LOCAL'
                                  ? Colors.green
                                  : (guest.status == 'CHECK-IN'
                                      ? Colors.blue
                                      : Colors.orange);
                          final String guestStatusText =
                              guest.geoCheckinStatus == 'CONFIRMADO_LOCAL'
                                  ? 'Confirmado Local'
                                  : (guest.status == 'CHECK-IN'
                                      ? 'Check-in Entrada'
                                      : 'Pendente');

                          return ListTile(
                            title: Text(guest.nome),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ajuste o campo abaixo para o existente no modelo Guest, ou remova se não existir:
                                // Text('Documento: ${guest.documento ?? 'N/A'}'),
                                Text(
                                    'Status da Entrada: ${guest.status ?? 'Pendente'}'),
                                Text('Status Local: ${guestStatusText}',
                                    style: TextStyle(color: statusColor)),
                              ],
                            ),
                            trailing: showConfirmButton
                                ? ElevatedButton(
                                    onPressed: () => _selfCheckIn(guest),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      minimumSize:
                                          Size(80, 30), // Min size for button
                                    ),
                                    child: const Text('Confirmar Local',
                                        style: TextStyle(fontSize: 12)),
                                  )
                                : null,
                          );
                        }).toList()
                      else
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Nenhum convidado detalhado para esta lista.'),
                        ),
                    ],
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
