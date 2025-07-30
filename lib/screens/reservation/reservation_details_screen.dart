// lib/screens/reservation/reservation_details_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/models/guest_model.dart';
import 'package:agilizaiapp/models/brinde_model.dart'; // Importar BrindeRule
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:agilizaiapp/services/event_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Para gerar QR Code
import 'package:share_plus/share_plus.dart'; // Para compartilhar link
import 'package:url_launcher/url_launcher.dart'; // Para abrir link no navegador

class ReservationDetailsScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailsScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late Future<Reservation> _reservationDetailsFuture;
  final ReservationService _reservationService = ReservationService();
  final EventService _eventService = EventService();

  // URL base para o convite. Adapte para a URL real do seu app/site!
  // Ex: se o seu link for https://meuapp.com/convite?code=XYZW12
  static const String _baseUrl =
      'https://seusite.com/convite'; // <--- MUDE ESTA URL!

  @override
  void initState() {
    super.initState();
    _fetchReservationDetails();
  }

  void _fetchReservationDetails() {
    setState(() {
      _reservationDetailsFuture =
          _reservationService.fetchReservationDetails(widget.reservationId);
    });
  }

  // Método para solicitar permissão de localização
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Serviços de localização desativados. Ative-os para confirmar sua presença.'),
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

  // Lógica para o self check-in do convidado
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
        guest.id!, // Usar guest.id! porque já verificamos se não é null
        position.latitude,
        position.longitude,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.green),
      );
      _fetchReservationDetails(); // Recarregar detalhes para atualizar o status na UI
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

  // Método para compartilhar o link da reserva
  void _shareReservationLink(String? uniqueCode) async {
    if (uniqueCode == null || uniqueCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Código de convite não disponível.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    final String shareLink = '$_baseUrl?code=$uniqueCode';
    try {
      await Share.share(
        'Olá! Você foi convidado para um evento! Acesse o link para ver os detalhes e seu QR Code: $shareLink',
        subject: 'Seu Convite para o Evento!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao compartilhar: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fundo cinza claro
      appBar: AppBar(
        title: const Text('Detalhes da Reserva'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Cor mais vibrante
        foregroundColor: Colors.white, // Cor do texto e ícones
        elevation: 0,
      ),
      body: FutureBuilder<Reservation>(
        future: _reservationDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar reserva: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Reserva não encontrada.'));
          }

          final Reservation reservation = snapshot.data!;
          final String shareLink =
              '$_baseUrl?code=${reservation.codigoConvite ?? ''}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Detalhes da Reserva (Card principal)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.nomeDoEvento ?? 'Evento Sem Nome',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Criado por: ${reservation.creatorName ?? 'N/A'}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Data: ${reservation.dataDoEvento ?? 'N/A'} às ${reservation.horaDoEvento ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${reservation.casaDoEvento ?? 'N/A'} - ${reservation.localDoEvento ?? 'N/A'}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.confirmation_number,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${reservation.status ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: reservation.status == 'ATIVA'
                                      ? Colors.green[700]
                                      : (reservation.status == 'CANCELADA'
                                          ? Colors.red[700]
                                          : Colors.blue[700])),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.people,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Convidados: ${reservation.convidados?.where((g) => g.status == 'CHECK-IN' && g.geoCheckinStatus == 'CONFIRMADO_LOCAL').length ?? 0} / ${reservation.quantidadeConvidados}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção de Compartilhamento
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Convide seus Amigos!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Link de Compartilhamento
                        if (reservation.codigoConvite != null &&
                            reservation.codigoConvite!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Link do Convite:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () async {
                                  if (await canLaunchUrl(
                                      Uri.parse(shareLink))) {
                                    await launchUrl(Uri.parse(shareLink));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Não foi possível abrir o link.'),
                                          backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                child: Text(
                                  shareLink,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _shareReservationLink(
                                      reservation.codigoConvite),
                                  icon: const Icon(Icons.share),
                                  label: const Text('Compartilhar Convite'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            'Código de convite não disponível para esta reserva.',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção de Convidados
                Text('Convidados (${reservation.convidados?.length ?? 0}):',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800])),
                const SizedBox(height: 10),
                if (reservation.convidados == null ||
                    reservation.convidados!.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nenhum convidado nesta reserva ainda.'),
                  ))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reservation.convidados!.length,
                    itemBuilder: (context, index) {
                      final guest = reservation.convidados![index];
                      final bool showConfirmButton =
                          (guest.status == 'CHECK-IN' &&
                              guest.geoCheckinStatus != 'CONFIRMADO_LOCAL' &&
                              guest.geoCheckinStatus !=
                                  'INVALIDO'); // Adicionado INVALIDO
                      final Color statusColor =
                          guest.geoCheckinStatus == 'CONFIRMADO_LOCAL'
                              ? Colors.green
                              : (guest.status == 'CHECK-IN'
                                  ? Colors.blue
                                  : (guest.geoCheckinStatus == 'INVALIDO'
                                      ? Colors.red
                                      : Colors.orange));
                      final String guestStatusText =
                          guest.geoCheckinStatus == 'CONFIRMADO_LOCAL'
                              ? 'Confirmado Local'
                              : (guest.status == 'CHECK-IN'
                                  ? 'Check-in Entrada'
                                  : (guest.geoCheckinStatus == 'INVALIDO'
                                      ? 'Local Inválido'
                                      : 'Pendente'));

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(guest.nome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Status: $guestStatusText',
                                  style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),

                              // Exibir QR Code para CADA convidado
                              if (guest.qrCode != null &&
                                  guest.qrCode!.isNotEmpty)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: QrImageView(
                                      data: guest.qrCode!,
                                      version: QrVersions.auto,
                                      size: 150.0,
                                      gapless: true,
                                      errorStateBuilder: (cxt, err) {
                                        return const Center(
                                          child: Text(
                                            'Erro ao gerar QR Code',
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),

                              // Botão de Confirmar Local (para promoters)
                              if (showConfirmButton)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _selfCheckIn(guest),
                                    icon:
                                        const Icon(Icons.check_circle_outline),
                                    label: const Text('Confirmar Local'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                // Seção de Brindes
                if (reservation.brindes != null &&
                    reservation.brindes!.isNotEmpty) ...[
                  Text('Brindes Associados (${reservation.brindes!.length}):',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[800])),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reservation.brindes!.length,
                    itemBuilder: (context, index) {
                      final brinde = reservation.brindes![index];
                      Color brindeStatusColor = Colors.grey;
                      if (brinde.status == 'LIBERADO') {
                        brindeStatusColor = Colors.green;
                      } else if (brinde.status == 'ENTREGUE') {
                        brindeStatusColor = Colors.blue;
                      } else if (brinde.status == 'PENDENTE') {
                        brindeStatusColor = Colors.orange;
                      }

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brinde.descricao ?? 'Brinde sem descrição',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  'Condição: ${brinde.condicaoTipo ?? 'N/A'} - ${brinde.condicaoValor ?? 'N/A'}',
                                  style: TextStyle(color: Colors.grey[700])),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: brindeStatusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Status: ${brinde.status ?? 'N/A'}',
                                    style: TextStyle(
                                      color: brindeStatusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
