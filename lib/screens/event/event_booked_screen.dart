import 'package:agilizaiapp/models/guest_model.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class EventBookedScreen extends StatefulWidget {
  final int reservaId;
  const EventBookedScreen({super.key, required this.reservaId});

  @override
  State<EventBookedScreen> createState() => _EventBookedScreenState();
}

class _EventBookedScreenState extends State<EventBookedScreen> {
  late Future<Reservation> _reservationFuture;
  final ReservationService _reservationService = ReservationService();
  IO.Socket? socket;

  // Variável para guardar a reserva DEPOIS que o Future for resolvido
  Reservation? _currentReservation;

  @override
  void initState() {
    super.initState();
    _reservationFuture = _fetchAndSetupReservation();
  }

  Future<Reservation> _fetchAndSetupReservation() async {
    try {
      final reservation =
          await _reservationService.getReservationDetails(widget.reservaId);
      // Guarda a reserva no estado para uso posterior
      _currentReservation = reservation;
      _initSocketIO(reservation); // Inicia o Socket.IO depois de ter os dados
      return reservation;
    } catch (e) {
      throw Exception('Erro ao carregar e configurar a reserva: $e');
    }
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  void _initSocketIO(Reservation reservation) {
    socket =
        IO.io('https://vamos-comemorar-api.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket!.connect();
    socket!.onConnect((_) {
      print('Socket.IO Conectado!');
      socket!.emit('join_reserva_room', 'reserva_${reservation.id}');
    });
    socket!.on('novo_convidado_adicionado', (data) {
      print('Novo convidado recebido via Socket.IO: $data');
      if (data is Map<String, dynamic>) {
        final newGuest = Guest.fromJson(data);
        setState(() {
          _currentReservation?.convidados.add(newGuest);
        });
      }
    });
  }

  void _showGuestQrCodePopup(BuildContext context, Guest guest) {
    // --- PRINT 1: VERIFICAR OS DADOS DO CONVIDADO ---
    print('DEBUG: Mostrando popup para o convidado "${guest.nome}".');
    print('DEBUG: Dados do QR Code: "${guest.qrCode}"');
    // ---------------------------------------------

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(guest.nome, textAlign: TextAlign.center),
          content: SizedBox(
            width: 250,
            height: 250,
            child: QrImageView(
              data: guest.qrCode,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  void _shareInviteLink(BuildContext context, Reservation reservation) {
    final link =
        'https://vamos-comemorar-app.com/convite/${reservation.codigoConvite}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link de convite copiado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Reserva'),
      ),
      body: FutureBuilder<Reservation>(
        future: _reservationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar detalhes: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Reserva não encontrada.'));
          }

          final reservation = snapshot.data!;
          final creator = reservation.convidados.isNotEmpty
              ? reservation.convidados.first
              : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (creator != null)
                          ListTile(
                            leading: const Icon(Icons.confirmation_number,
                                color: Colors.green),
                            title: const Text('Seu Ingresso',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(creator.nome),
                            trailing: const Icon(Icons.qr_code_2),
                            onTap: () {
                              // --- PRINT 2: VERIFICAR SE O TAP ESTÁ FUNCIONANDO ---
                              print('DEBUG: Botão "Seu Ingresso" foi tocado!');
                              // ----------------------------------------------------
                              _showGuestQrCodePopup(context, creator);
                            },
                          ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.share, color: Colors.blue),
                          title: const Text('Convidar Amigos',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Copiar link de convite'),
                          trailing: const Icon(Icons.copy),
                          onTap: () => _shareInviteLink(context, reservation),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Lista de Convidados (${reservation.convidados.length} / ${reservation.quantidadeConvidados})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: reservation.convidados.length,
                    itemBuilder: (context, index) {
                      final guest = reservation.convidados[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(guest.nome),
                          trailing: const Icon(Icons.qr_code_scanner),
                          onTap: () => _showGuestQrCodePopup(context, guest),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
