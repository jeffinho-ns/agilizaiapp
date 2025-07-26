import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart'; // NOVO: Usando ReservationService
import 'package:shared_preferences/shared_preferences.dart'; // NOVO: Para pegar o userId

class EventParticipationFormScreen extends StatefulWidget {
  final Event event;

  const EventParticipationFormScreen({super.key, required this.event});

  @override
  State<EventParticipationFormScreen> createState() =>
      _EventParticipationFormScreenState();
}

class _EventParticipationFormScreenState
    extends State<EventParticipationFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final ReservationService _reservationService = ReservationService(); // NOVO
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _submitParticipation() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira seu nome para participar.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('userId');
      if (userIdString == null) {
        throw Exception('Usuário não logado. Faça login para continuar.');
      }
      final userId = int.parse(userIdString);

      // Monta o payload para CRIAR UMA RESERVA
      final payload = {
        "userId": userId,
        "tipoReserva": "NORMAL", // Tipo de reserva para participação simples
        "nomeLista":
            "Participação em: ${widget.event.nomeDoEvento ?? 'Evento'}",
        "dataReserva": widget.event.dataDoEvento ??
            DateTime.now().toIso8601String().substring(0, 10),
        "eventoId": widget.event.id,
        "convidados": [
          _nameController.text.trim()
        ], // Lista com apenas o nome do participante
        "brindes": []
      };

      // Chama o serviço para criar a reserva
      await _reservationService.createReservation(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sua participação foi registrada com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Falha ao registrar participação: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Participação'),
        backgroundColor: const Color(0xFF242A38),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evento: ${widget.event.nomeDoEvento ?? 'Sem Nome'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Local: ${widget.event.localDoEvento ?? 'Não informado'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Data: ${widget.event.dataDoEvento ?? 'Não informada'} às ${widget.event.horaDoEvento ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Seus Dados para Participação:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Seu Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _documentController,
              decoration: const InputDecoration(
                labelText: 'Seu Documento (CPF/RG - Opcional)',
                hintText: 'Ex: 123.456.789-00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitParticipation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26422),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar Participação',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
