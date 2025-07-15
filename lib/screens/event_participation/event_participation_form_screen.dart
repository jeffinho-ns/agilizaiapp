// lib/screens/event_participation/event_participation_form_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/guest_service.dart';

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
  final TextEditingController _documentController =
      TextEditingController(); // Para documento opcional
  final GuestService _guestService = GuestService();
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

    setState(() {
      _isLoading = true;
    });

    try {
      // O endpoint POST /convidados espera um array de nomes.
      // O documento e a lista serão 'null' e 'Geral' conforme sua API atual.
      await _guestService.addGuests(
        widget.event.id,
        [_nameController.text.trim()], // Passa o nome como um array de um item
        // Se a API fosse adaptada para receber documento/lista por cliente:
        // {
        //   'nome': _nameController.text.trim(),
        //   'documento': _documentController.text.trim(),
        //   'lista': 'Pista', // Ou a lista que o cliente escolheria
        // }
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sua participação foi registrada com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a tela de busca de eventos
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
        setState(() {
          _isLoading = false;
        });
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
