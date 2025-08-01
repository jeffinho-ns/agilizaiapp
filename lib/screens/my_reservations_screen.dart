// lib/screens/my_reservations_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:agilizaiapp/screens/reservation/reservation_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modelo para reservas de aniversário
class BirthdayReservation {
  final String id;
  final String aniversarianteNome;
  final String documento;
  final String whatsapp;
  final String email;
  final String bar;
  final DateTime dataAniversario;
  final int quantidadeConvidados;
  final String? decorationName;
  final double? decorationPrice;
  final String? painelOption;
  final String? painelTema;
  final String? painelFrase;
  final Map<String, int> bebidas;
  final Map<String, int> comidas;
  final List<String> presentes;
  final double valorTotal;
  final String status;
  final String linkConvidados;
  final DateTime dataCriacao;

  BirthdayReservation({
    required this.id,
    required this.aniversarianteNome,
    required this.documento,
    required this.whatsapp,
    required this.email,
    required this.bar,
    required this.dataAniversario,
    required this.quantidadeConvidados,
    this.decorationName,
    this.decorationPrice,
    this.painelOption,
    this.painelTema,
    this.painelFrase,
    required this.bebidas,
    required this.comidas,
    required this.presentes,
    required this.valorTotal,
    required this.status,
    required this.linkConvidados,
    required this.dataCriacao,
  });
}

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Reservation>> _reservationsFuture;
  final ReservationService _reservationService = ReservationService();
  String? _currentUserName;
  late TabController _tabController;

  // Lista mockada de reservas de aniversário (substitua por dados reais da API)
  final List<BirthdayReservation> _birthdayReservations = [
    BirthdayReservation(
      id: '1',
      aniversarianteNome: 'João Silva',
      documento: '123.456.789-00',
      whatsapp: '(11) 99999-9999',
      email: 'joao@email.com',
      bar: 'Justino',
      dataAniversario: DateTime.now().add(const Duration(days: 15)),
      quantidadeConvidados: 25,
      decorationName: 'Opção 3',
      decorationPrice: 220.0,
      painelOption: 'personalizado',
      painelTema: 'Super Heróis',
      painelFrase: 'Feliz Aniversário João!',
      bebidas: {'Balde Budweiser (5 und)': 2, 'Caipirinha': 5},
      comidas: {'Batata Frita': 1, 'X-Burger': 2},
      presentes: ['Kit Whisky', 'Caneca Personalizada', 'Vale Comida (R\$ 50)'],
      valorTotal: 350.0,
      status: 'ATIVA',
      linkConvidados: 'https://agilizaiapp.com/convite/abc123',
      dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUserData();
    _fetchReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserName = prefs.getString('userName');
    });
    print('Nome do usuário logado (MyReservationsScreen): $_currentUserName');
  }

  void _fetchReservations() {
    setState(() {
      _reservationsFuture = _reservationService.fetchAllUserReservations();
    });
    _reservationsFuture.then((reservas) {
      print('Reservas carregadas: $reservas');
    }).catchError((error) {
      print('Erro ao carregar reservas no THEN: $error');
    });
  }

  void _shareInviteLink(String link) {
    // TODO: Implementar compartilhamento real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copiado: $link'),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () {
            // TODO: Implementar cópia para clipboard
          },
        ),
      ),
    );
  }

  void _showBirthdayReservationDetails(BirthdayReservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B3245),
          title: const Text('Detalhes da Reserva de Aniversário',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📋 DADOS DO ANIVERSARIANTE',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text('Nome: ${reservation.aniversarianteNome}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Documento: ${reservation.documento}',
                    style: const TextStyle(color: Colors.white70)),
                Text('WhatsApp: ${reservation.whatsapp}',
                    style: const TextStyle(color: Colors.white70)),
                Text('E-mail: ${reservation.email}',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('🎉 DETALHES DA FESTA',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text('Bar: ${reservation.bar}',
                    style: const TextStyle(color: Colors.white70)),
                Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(reservation.dataAniversario)}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Convidados: ${reservation.quantidadeConvidados} pessoas',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                if (reservation.decorationName != null) ...[
                  const Text('🎨 DECORAÇÃO',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                      '${reservation.decorationName} - R\$ ${reservation.decorationPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                ],
                if (reservation.painelOption == 'personalizado') ...[
                  Text('Painel Personalizado: ${reservation.painelTema}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Frase: ${reservation.painelFrase}',
                      style: const TextStyle(color: Colors.white70)),
                ],
                if (reservation.bebidas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('🥂 BEBIDAS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  ...reservation.bebidas.entries.map((entry) => Text(
                      '${entry.key}: ${entry.value}x',
                      style: const TextStyle(color: Colors.white70))),
                ],
                if (reservation.comidas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('🍽️ COMIDAS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  ...reservation.comidas.entries.map((entry) => Text(
                      '${entry.key}: ${entry.value}x',
                      style: const TextStyle(color: Colors.white70))),
                ],
                if (reservation.presentes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('🎁 PRESENTES ESCOLHIDOS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  ...reservation.presentes.map((presente) => Text(presente,
                      style: const TextStyle(color: Colors.white70))),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF26422).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF26422)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '💰 VALOR TOTAL',
                        style: TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${reservation.valorTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Fechar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareInviteLink(reservation.linkConvidados);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF26422),
                foregroundColor: Colors.white,
              ),
              child: const Text('Compartilhar Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF26422),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF26422),
          tabs: const [
            Tab(text: 'Reservas Gerais'),
            Tab(text: 'Aniversários'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Reservas Gerais
          FutureBuilder<List<Reservation>>(
            future: _reservationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Erro ao carregar reservas: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Você não tem nenhuma reserva.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              } else {
                final reservations = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];

                    String formattedDate = 'N/A';
                    if (reservation.dataDoEvento != null &&
                        reservation.dataDoEvento!.isNotEmpty) {
                      try {
                        formattedDate = DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(reservation.dataDoEvento!));
                      } catch (e) {
                        print(
                            'Erro ao parsear data do evento ${reservation.dataDoEvento}: $e');
                        formattedDate = reservation.dataDoEvento!;
                      }
                    }

                    Color statusColor = Colors.grey;
                    if (reservation.status == 'ATIVA') {
                      statusColor = Colors.green[700]!;
                    } else if (reservation.status == 'CANCELADA') {
                      statusColor = Colors.red[700]!;
                    } else if (reservation.status == 'CONCLUIDA') {
                      statusColor = Colors.blue[700]!;
                    }

                    String creatorDisplayName;
                    if (reservation.creatorName != null &&
                        _currentUserName != null &&
                        reservation.creatorName == _currentUserName) {
                      creatorDisplayName = 'Você';
                    } else {
                      creatorDisplayName = reservation.creatorName ?? 'N/A';
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReservationDetailsScreen(
                                    reservationId: reservation.id,
                                  ),
                                ),
                              )
                              .then((_) => _fetchReservations());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reservation.nomeDoEvento ??
                                              'Evento Sem Nome',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Criado por: $creatorDisplayName',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      reservation.status ?? 'N/A',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Data: $formattedDate às ${reservation.horaDoEvento ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Convidados: ${reservation.quantidadeConvidados}',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),

          // Tab 2: Reservas de Aniversário
          _birthdayReservations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cake,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma reserva de aniversário encontrada',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Crie sua primeira reserva de aniversário!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _birthdayReservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _birthdayReservations[index];

                    Color statusColor = Colors.grey;
                    if (reservation.status == 'ATIVA') {
                      statusColor = Colors.green[700]!;
                    } else if (reservation.status == 'CANCELADA') {
                      statusColor = Colors.red[700]!;
                    } else if (reservation.status == 'CONCLUIDA') {
                      statusColor = Colors.blue[700]!;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () =>
                            _showBirthdayReservationDetails(reservation),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.cake,
                                              color: Color(0xFFF26422),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Aniversário de ${reservation.aniversarianteNome}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Bar: ${reservation.bar}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      reservation.status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Data: ${DateFormat('dd/MM/yyyy').format(reservation.dataAniversario)}',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Convidados: ${reservation.quantidadeConvidados} pessoas',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Valor: R\$ ${reservation.valorTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _shareInviteLink(
                                          reservation.linkConvidados),
                                      icon: const Icon(Icons.share, size: 16),
                                      label: const Text('Compartilhar Link'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFFF26422),
                                        side: const BorderSide(
                                            color: Color(0xFFF26422)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showBirthdayReservationDetails(
                                              reservation),
                                      icon: const Icon(Icons.visibility,
                                          size: 16),
                                      label: const Text('Ver Detalhes'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFF26422),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
