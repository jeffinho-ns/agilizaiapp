import 'dart:convert';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/screens/event/event_booked_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // ✨ IMPORTANTE: Adicione para formatação monetária

class EventDetailsPage extends StatefulWidget {
  final Event event;
  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int _pessoas = 1;
  late int _mesas;
  bool _isLoading = false;

  static const String apiUrl =
      'https://vamos-comemorar-api.onrender.com/api/reservas';

  @override
  void initState() {
    super.initState();
    _calculateMesas();
  }

  void _calculateMesas() {
    _mesas = (_pessoas / 6).ceil();
  }

  // ✨ NOVO: Função para formatar o preço em R$
  String _formatPrice(dynamic price) {
    if (price == null) {
      return 'Grátis';
    }
    try {
      // Tenta converter para double, se for string, tenta fazer o parse
      final number =
          price is String ? double.tryParse(price) : price.toDouble();
      if (number == null || number == 0) {
        return 'Grátis';
      }
      // Formatação para Real Brasileiro (R$)
      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      return formatter.format(number);
    } catch (e) {
      print('Erro ao formatar preço: $e');
      return 'N/A';
    }
  }

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('currentUser');

    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Falha ao decodificar o JSON do usuário: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _confirmReservation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não identificado. Faça login novamente.');
      }

      if (widget.event.casaDoEvento == null) {
        throw Exception('Informação da casa do evento não encontrada.');
      }

      final reservationData = {
        'userId': user.id,
        'eventId': widget.event.id,
        'quantidade_pessoas': _pessoas,
        'mesas': '$_mesas Mesa(s) / ${_mesas * 6} cadeiras',
        'data_da_reserva': DateTime.now().toIso8601String(),
        'casa_da_reserva': widget.event.casaDoEvento,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reservationData),
      );

      if (response.statusCode == 201) {
        final Reservation newReservation = Reservation.fromJson(
          jsonDecode(response.body),
        );
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventBookedScreen(
                reservation: newReservation,
                event: widget.event,
              ),
            ),
          );
        }
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception('Falha ao confirmar reserva: ${responseBody['error']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
    const bottomBarHeight = 90.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.event.imagemDoEventoUrl ??
                  'https://i.imgur.com/715zr01.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      'Falha ao carregar imagem do evento', // Traduzido
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildTopButtons(context),
          Padding(
            padding: const EdgeInsets.only(bottom: bottomBarHeight),
            child: DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.65,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      _buildEventHeader(widget.event),
                      const SizedBox(height: 20),
                      _buildMembersSection(),
                      const Divider(height: 40, thickness: 1),
                      _buildOrganizerInfo(),
                      const SizedBox(height: 20),
                      _buildDescription(widget.event),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                // TODO: Implementar lógica de favoritar/desfavoritar
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.nomeDoEvento ?? 'Nome Indefinido', // Traduzido
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                event.localDoEvento ?? 'Local Indefinido', // Traduzido
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(event.dataDoEvento ?? 'Sem data'), // Traduzido
            const SizedBox(height: 16),
            const Icon(Icons.access_time, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(event.horaDoEvento ?? 'Sem hora'), // Traduzido
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4D4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatPrice(
              event.valorDaEntrada,
            ), // Usando a função _formatPrice para R$
            style: const TextStyle(
              color: Color(0xFFF26422),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return Row(
      children: [
        const Flexible(
            child: Text(
                "15.7K+ Membros confirmados:")), // Já estava traduzido, mantido
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          height: 30,
          child: Stack(
            children: List.generate(4, (index) {
              return Positioned(
                left: index * 18.0,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/${index % 2 == 0 ? "women" : "men"}/${index + 1}.jpg',
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Implementar lógica de ver todos / convidar
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'VER TODOS / CONVIDAR', // Já estava traduzido, mantido
            style: TextStyle(
              color: Color(0xFFF26422),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerInfo() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/5.jpg',
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: const Text(
        'Tamim Ikram', // Nome do organizador, pode ser dinâmico no futuro
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Organizador do Evento'), // Já estava traduzido
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircularButton(Icons.chat_bubble_outline),
          const SizedBox(width: 8),
          _buildCircularButton(Icons.call_outlined),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      child: Icon(icon, color: Colors.black54, size: 20),
    );
  }

  Widget _buildDescription(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição', // Traduzido
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          event.descricao ?? 'Sem descrição disponível.', // Traduzido
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 20),
        const Text(
          'Combo Especial', // Traduzido
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (event.imagemDoComboUrl != null &&
            event.imagemDoComboUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              event.imagemDoComboUrl!,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      'Falha ao carregar imagem do combo', // Traduzido
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 400,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'Combo não disponível', // Traduzido
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Localização', // Traduzido
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: Image.network(
            'https://picsum.photos/600/300', // Placeholder de mapa
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Text(
                    'Mapa indisponível ou falha de rede', // Traduzido
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildReservationForm(),
      ],
    );
  }

  Widget _buildReservationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantidade de Pessoas', // Traduzido
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<int>(
          value: _pessoas,
          isExpanded: true,
          items: List.generate(20, (index) => index + 1)
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                      '$e Pessoa(s)'), // Traduzido e mantido dinâmico para "pessoa(s)"
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _pessoas = value;
                _calculateMesas();
              });
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Mesas Necessárias (1 mesa para 6 pessoas)', // Traduzido
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text('$_mesas mesa(s)'), // Traduzido e mantido dinâmico para "mesa(s)"
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () {
                // TODO: Implementar lógica de favoritar/salvar evento
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.bookmark_border, color: Colors.black54),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'CONFIRMAR RESERVA', // Traduzido
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
