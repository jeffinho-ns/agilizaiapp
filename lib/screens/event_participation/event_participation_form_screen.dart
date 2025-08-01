import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ReservationService _reservationService = ReservationService();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _submitParticipation() async {
    if (!_formKey.currentState!.validate()) {
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
            content: Text('Sua participação foi registrada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao registrar participação: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu nome';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateDocument(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      // Remove caracteres especiais para validação
      final cleanDocument = value.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanDocument.length != 11 && cleanDocument.length != 14) {
        return 'CPF deve ter 11 dígitos ou CNPJ 14 dígitos';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Participação'),
        backgroundColor: const Color(0xFFF26422),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card com informações do evento
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFF26422),
                            backgroundImage: widget.event.imagemDoEventoUrl !=
                                    null
                                ? NetworkImage(widget.event.imagemDoEventoUrl!)
                                : null,
                            child: widget.event.imagemDoEventoUrl == null
                                ? const Icon(Icons.event,
                                    color: Colors.white, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.event.nomeDoEvento ??
                                      'Evento Sem Nome',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.event.casaDoEvento ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFF26422),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.location_on, 'Local',
                          widget.event.localDoEvento ?? 'Não informado'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.calendar_today, 'Data',
                          '${widget.event.dataDoEvento ?? 'Não informada'} às ${widget.event.horaDoEvento}'),
                      if (widget.event.valorDaEntrada != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.attach_money, 'Valor',
                            'R\$ ${widget.event.valorDaEntrada!.toStringAsFixed(2)}'),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Seção de dados pessoais
              const Text(
                'Seus Dados para Participação:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo *',
                  hintText: 'Digite seu nome completo',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _documentController,
                decoration: InputDecoration(
                  labelText: 'CPF (Opcional)',
                  hintText: '000.000.000-00',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: _validateDocument,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 32),

              // Botão de confirmação
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitParticipation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF26422),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Registrando...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Confirmar Participação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Informações adicionais
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200] ?? Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sua participação será registrada e você receberá confirmação por email.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
