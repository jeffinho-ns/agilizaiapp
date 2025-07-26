import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importe as outras telas que você navega a partir daqui

class GuestListManagementScreen extends StatefulWidget {
  final Event event;
  const GuestListManagementScreen({super.key, required this.event});

  @override
  State<GuestListManagementScreen> createState() =>
      _GuestListManagementScreenState();
}

class _GuestListManagementScreenState extends State<GuestListManagementScreen> {
  late Future<List<Reservation>> _reservationsFuture;
  final ReservationService _reservationService = ReservationService();

  // Controllers para o diálogo de criação
  final TextEditingController _newListNameController = TextEditingController();
  final TextEditingController _addGuestNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _fetchReservationsForEvent();
  }

  Future<List<Reservation>> _fetchReservationsForEvent() async {
    try {
      // ATENÇÃO: Precisaremos adicionar um método `getReservationsForEvent`
      // ao nosso ReservationService, que chama a rota GET /api/events/:id/reservas
      final reservationsData =
          await _reservationService.getReservationsForEvent(widget.event.id);
      return reservationsData
          .map((json) => Reservation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar listas: ${e.toString()}');
    }
  }

  Future<void> _criarListaDePromoter() async {
    final nomeDaLista = _newListNameController.text.trim();
    if (nomeDaLista.isEmpty) {
      // Mostrar SnackBar
      return;
    }
    final nomesConvidados = _addGuestNameController.text.trim().split('\n');
    if (nomesConvidados.isEmpty || nomesConvidados.first.trim().isEmpty) {
      // Mostrar SnackBar
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.parse(prefs.getString('userId') ?? '0');
      final dataDoEvento = widget.event.dataDoEvento ??
          DateTime.now().toIso8601String().substring(0, 10);

      final Map<String, dynamic> payload = {
        "userId": userId,
        "tipoReserva": "PROMOTER",
        "nomeLista": nomeDaLista,
        "dataReserva": dataDoEvento,
        "eventoId": widget.event.id,
        "convidados":
            nomesConvidados.where((n) => n.trim().isNotEmpty).toList(),
        "brindes": []
      };

      await _reservationService.createReservation(payload);

      if (mounted) {
        Navigator.of(context).pop(); // Fecha dialog
        _newListNameController.clear();
        _addGuestNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lista "$nomeDaLista" criada com sucesso!')),
        );
        // Atualiza a lista na tela
        setState(() {
          _reservationsFuture = _fetchReservationsForEvent();
        });
      }
    } catch (e) {
      // Mostrar SnackBar de erro
    }
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Nova Lista de Promoter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newListNameController,
                  decoration:
                      const InputDecoration(labelText: 'Nome da Sua Lista'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addGuestNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nomes dos Convidados',
                    hintText: 'Um nome por linha',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: _criarListaDePromoter,
              child: const Text('Criar Lista'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas para: ${widget.event.nomeDoEvento ?? ''}'),
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
                child: Text('Nenhuma lista criada para este evento ainda.'));
          }

          final reservations = snapshot.data!;
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reserva = reservations[index];
              return ListTile(
                title: Text(reserva.nomeLista),
                subtitle: Text('${reserva.convidados.length} convidados'),
                // onTap: () => // Navegar para uma tela de detalhes da lista
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
