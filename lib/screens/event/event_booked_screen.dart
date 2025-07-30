// lib/screens/event/event_booked_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:agilizaiapp/main.dart'; // <--- IMPORTADO AQUI: main.dart para navigatorKey

class EventBookedScreen extends StatefulWidget {
  final int reservaId;
  const EventBookedScreen({super.key, required this.reservaId});

  @override
  State<EventBookedScreen> createState() => _EventBookedScreenState();
}

class _EventBookedScreenState extends State<EventBookedScreen> {
  late Future<Reservation> _reservationFuture;
  Reservation? _currentReservation;
  final ReservationService _reservationService = ReservationService();
  io.Socket? socket;

  @override
  void initState() {
    super.initState();
    _reservationFuture = _fetchAndSetupReservation();
  }

  Future<Reservation> _fetchAndSetupReservation() async {
    try {
      final reservation =
          await _reservationService.fetchReservationDetails(widget.reservaId);
      if (mounted) {
        setState(() {
          _currentReservation = reservation;
        });
        _initSocketIO(reservation);
      }
      return reservation;
    } catch (e) {
      print('Erro ao buscar reserva em EventBookedScreen: $e');
      rethrow;
    }
  }

  void _initSocketIO(Reservation reservation) {
    if (socket != null && socket!.connected) {
      print('Socket já conectado. Desconectando para reconectar.');
      socket!.disconnect();
    }

    socket = io.io(
        'https://vamos-comemorar-api.onrender.com', // Sua URL base da API
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket!.connect();

    socket!.onConnect((_) {
      print('Socket.IO Conectado!');
      socket!.emit('joinReservationRoom', {'reservationId': reservation.id});
    });

    socket!.on('qrCodeScanned', (data) {
      print('QR Code Scaneado Recebido: $data');
      if (mounted && data != null && data['guestName'] != null) {
        // USANDO navigatorKey AQUI:
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          // <--- CORREÇÃO AQUI
          SnackBar(
            content: Text('${data['guestName']} fez check-in!'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
    });

    socket!.onDisconnect((_) => print('Socket.IO Desconectado!'));
    socket!.onError((error) => print('Socket.IO Erro: $error'));
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  void _shareInviteLink(BuildContext context, Reservation reservation) {
    if (reservation.codigoConvite == null ||
        reservation.codigoConvite!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Código de convite não disponível.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final String inviteLink =
        'https://seuapp.com/invite?code=${reservation.codigoConvite}'; // Ajuste sua URL base
    print('Link de convite para compartilhar: $inviteLink');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Link de convite gerado: $inviteLink (Copie do console)'),
          backgroundColor: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reserva Confirmada!'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: FutureBuilder<Reservation>(
        future: _reservationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar reserva: ${snapshot.error}'));
          } else if (!snapshot.hasData || _currentReservation == null) {
            return const Center(child: Text('Reserva não encontrada.'));
          }

          final reservation = _currentReservation!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Sua reserva foi criada com sucesso!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  _buildDetailRow('Lista:', reservation.nomeLista ?? 'N/A'),
                  _buildDetailRow('Evento:', reservation.nomeDoEvento ?? 'N/A'),
                  _buildDetailRow('Data:',
                      '${reservation.dataDoEvento ?? 'N/A'} às ${reservation.horaDoEvento ?? 'N/A'}'),
                  _buildDetailRow('Local:', reservation.localDoEvento ?? 'N/A'),
                  _buildDetailRow('Convidados:',
                      reservation.quantidadeConvidados.toString()),
                  _buildDetailRow(
                      'Código de Convite:', reservation.codigoConvite ?? 'N/A'),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () => _shareInviteLink(context, reservation),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar Link do Convite'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26422),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Voltar para a Página Inicial',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
