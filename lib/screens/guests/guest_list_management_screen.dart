// lib/screens/guests/guest_list_management_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/guest_model.dart';
import 'package:agilizaiapp/services/event_service.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:geolocator/geolocator.dart';

class GuestListManagementScreen extends StatefulWidget {
  final Event event;

  const GuestListManagementScreen({super.key, required this.event});

  @override
  State<GuestListManagementScreen> createState() =>
      _GuestListManagementScreenState();
}

class _GuestListManagementScreenState extends State<GuestListManagementScreen> {
  late Future<List<Reservation>> _reservationsFuture;
  late Future<bool> _promoterCheckFuture;
  final ReservationService _reservationService = ReservationService();
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _promoterCheckFuture = _eventService.isUserPromoterOfEvent(widget.event.id);
    _fetchReservationsForEvent();
  }

  void _fetchReservationsForEvent() {
    setState(() {
      _reservationsFuture =
          _reservationService.fetchReservationsByEventId(widget.event.id);
    });
  }

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

  Future<void> _selfCheckIn(Guest guest) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Confirmando presença...'),
                ],
              ),
            ),
          ),
        );
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
          content: Text(response['message']),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      _fetchReservationsForEvent();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no check-in: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      print('Erro ao tentar self check-in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convidados: ${widget.event.nomeDoEvento}'),
        backgroundColor: const Color(0xFF242A38),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReservationsForEvent,
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _promoterCheckFuture,
        builder: (context, promoterSnapshot) {
          if (promoterSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (promoterSnapshot.hasError || !promoterSnapshot.data!) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acesso Negado',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Você não tem permissão para gerenciar este evento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<Reservation>>(
            future: _reservationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando lista de convidados...'),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReservationsForEvent,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma reserva encontrada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ainda não há reservas para este evento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async => _fetchReservationsForEvent(),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final reservation = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 2,
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getStatusColor(reservation.status),
                            child: Text(
                              '${reservation.quantidadeConvidados}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            'Lista: ${reservation.nomeLista}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${reservation.status}'),
                              Text(
                                  'Total: ${reservation.quantidadeConvidados} convidados'),
                            ],
                          ),
                          children: [
                            if (reservation.convidados != null &&
                                reservation.convidados!.isNotEmpty)
                              ...reservation.convidados!.map((guest) {
                                final bool showConfirmButton =
                                    (guest.status == 'CHECK-IN' &&
                                        guest.geoCheckinStatus !=
                                            'CONFIRMADO_LOCAL');

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
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor,
                                    child: Icon(
                                      guest.geoCheckinStatus ==
                                              'CONFIRMADO_LOCAL'
                                          ? Icons.check
                                          : (guest.status == 'CHECK-IN'
                                              ? Icons.person
                                              : Icons.person_outline),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    guest.nome,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Status da Entrada: ${guest.status ?? 'Pendente'}'),
                                      Text(
                                        'Status Local: $guestStatusText',
                                        style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  trailing: showConfirmButton
                                      ? ElevatedButton.icon(
                                          onPressed: () => _selfCheckIn(guest),
                                          icon: const Icon(Icons.location_on,
                                              size: 16),
                                          label: const Text('Confirmar Local',
                                              style: TextStyle(fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            minimumSize: const Size(80, 30),
                                          ),
                                        )
                                      : null,
                                );
                              })
                            else
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Nenhum convidado detalhado para esta lista.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toUpperCase()) {
      case 'APROVADO':
        return Colors.green;
      case 'PENDENTE':
        return Colors.orange;
      case 'REPROVADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
