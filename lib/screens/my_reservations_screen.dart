// lib/screens/my_reservations_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/models/birthday_reservation_model.dart'; // Usar modelo real
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:agilizaiapp/screens/reservation/reservation_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Reservation>> _reservationsFuture;
  late Future<List<BirthdayReservationModel>>
      _birthdayReservationsFuture; // Future para dados reais
  final ReservationService _reservationService = ReservationService();
  String? _currentUserName;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUserData();
    _fetchReservations();
    _fetchBirthdayReservations(); // Buscar reservas de aniversário reais
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
  }

  void _fetchBirthdayReservations() {
    setState(() {
      _birthdayReservationsFuture =
          _reservationService.fetchAllBirthdayReservations();
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

  // Função para calcular o valor total da reserva
  double _calculateTotalValue(BirthdayReservationModel reservation) {
    double total = 0.0;

    // Preços das decorações (baseado nos nomes)
    if (reservation.decoracaoTipo != null) {
      if (reservation.decoracaoTipo!.contains('Pequena')) {
        total += 150.0;
      } else if (reservation.decoracaoTipo!.contains('Media')) {
        total += 200.0;
      } else if (reservation.decoracaoTipo!.contains('Grande')) {
        total += 250.0;
      }
    }

    // Preços dos itens do bar (bebidas)
    final bebidaPrices = [
      25.0,
      30.0,
      35.0,
      40.0,
      45.0,
      50.0,
      55.0,
      60.0,
      65.0,
      70.0
    ];
    total += reservation.itemBarBebida1 * bebidaPrices[0];
    total += reservation.itemBarBebida2 * bebidaPrices[1];
    total += reservation.itemBarBebida3 * bebidaPrices[2];
    total += reservation.itemBarBebida4 * bebidaPrices[3];
    total += reservation.itemBarBebida5 * bebidaPrices[4];
    total += reservation.itemBarBebida6 * bebidaPrices[5];
    total += reservation.itemBarBebida7 * bebidaPrices[6];
    total += reservation.itemBarBebida8 * bebidaPrices[7];
    total += reservation.itemBarBebida9 * bebidaPrices[8];
    total += reservation.itemBarBebida10 * bebidaPrices[9];

    // Preços dos itens do bar (comidas)
    final comidaPrices = [
      20.0,
      25.0,
      30.0,
      35.0,
      40.0,
      45.0,
      50.0,
      55.0,
      60.0,
      65.0
    ];
    total += reservation.itemBarComida1 * comidaPrices[0];
    total += reservation.itemBarComida2 * comidaPrices[1];
    total += reservation.itemBarComida3 * comidaPrices[2];
    total += reservation.itemBarComida4 * comidaPrices[3];
    total += reservation.itemBarComida5 * comidaPrices[4];
    total += reservation.itemBarComida6 * comidaPrices[5];
    total += reservation.itemBarComida7 * comidaPrices[6];
    total += reservation.itemBarComida8 * comidaPrices[7];
    total += reservation.itemBarComida9 * comidaPrices[8];
    total += reservation.itemBarComida10 * comidaPrices[9];

    return total;
  }

  // Função para obter nome do bar baseado no ID
  String _getBarName(dynamic barId) {
    if (barId == null) return 'Bar não especificado';

    final barIdStr = barId.toString();
    switch (barIdStr) {
      case '1':
        return 'Seu Justino';
      case '2':
        return 'Oh Fregues';
      case '3':
        return 'HighLine';
      case '4':
        return 'Pracinha do Seu Justino';
      case '5':
        return 'Reserva Rooftop';
      default:
        return 'Bar não especificado';
    }
  }

  void _showBirthdayReservationDetails(BirthdayReservationModel reservation) {
    final valorTotal = _calculateTotalValue(reservation);

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
                if (reservation.documento != null)
                  Text('Documento: ${reservation.documento}',
                      style: const TextStyle(color: Colors.white70)),
                if (reservation.whatsapp != null)
                  Text('WhatsApp: ${reservation.whatsapp}',
                      style: const TextStyle(color: Colors.white70)),
                if (reservation.email != null)
                  Text('E-mail: ${reservation.email}',
                      style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('🎉 DETALHES DA FESTA',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text('Bar: ${_getBarName(reservation.barSelecionado)}',
                    style: const TextStyle(color: Colors.white70)),
                Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(reservation.dataAniversario)}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Convidados: ${reservation.quantidadeConvidados} pessoas',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                if (reservation.decoracaoTipo != null &&
                    reservation.decoracaoTipo!.isNotEmpty) ...[
                  const Text('🎨 DECORAÇÃO',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${reservation.decoracaoTipo}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                ],
                if (reservation.painelPersonalizado) ...[
                  const Text('🎭 PAINEL PERSONALIZADO',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  if (reservation.painelTema != null)
                    Text('Tema: ${reservation.painelTema}',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.painelFrase != null)
                    Text('Frase: ${reservation.painelFrase}',
                        style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                ] else if (reservation.painelEstoqueImagemUrl != null) ...[
                  const Text('🎭 PAINEL EM ESTOQUE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Painel: ${reservation.painelEstoqueImagemUrl}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                ],

                // Bebidas selecionadas
                if ([
                  reservation.itemBarBebida1,
                  reservation.itemBarBebida2,
                  reservation.itemBarBebida3,
                  reservation.itemBarBebida4,
                  reservation.itemBarBebida5,
                  reservation.itemBarBebida6,
                  reservation.itemBarBebida7,
                  reservation.itemBarBebida8,
                  reservation.itemBarBebida9,
                  reservation.itemBarBebida10
                ].any((qty) => qty > 0)) ...[
                  const SizedBox(height: 12),
                  const Text('🥂 BEBIDAS SELECIONADAS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  if (reservation.itemBarBebida1 > 0)
                    Text('Item-bar-Bebida - 1: ${reservation.itemBarBebida1}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida2 > 0)
                    Text('Item-bar-Bebida - 2: ${reservation.itemBarBebida2}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida3 > 0)
                    Text('Item-bar-Bebida - 3: ${reservation.itemBarBebida3}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida4 > 0)
                    Text('Item-bar-Bebida - 4: ${reservation.itemBarBebida4}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida5 > 0)
                    Text('Item-bar-Bebida - 5: ${reservation.itemBarBebida5}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida6 > 0)
                    Text('Item-bar-Bebida - 6: ${reservation.itemBarBebida6}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida7 > 0)
                    Text('Item-bar-Bebida - 7: ${reservation.itemBarBebida7}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida8 > 0)
                    Text('Item-bar-Bebida - 8: ${reservation.itemBarBebida8}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida9 > 0)
                    Text('Item-bar-Bebida - 9: ${reservation.itemBarBebida9}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarBebida10 > 0)
                    Text(
                        'Item-bar-Bebida - 10: ${reservation.itemBarBebida10}x',
                        style: const TextStyle(color: Colors.white70)),
                ],

                // Comidas selecionadas
                if ([
                  reservation.itemBarComida1,
                  reservation.itemBarComida2,
                  reservation.itemBarComida3,
                  reservation.itemBarComida4,
                  reservation.itemBarComida5,
                  reservation.itemBarComida6,
                  reservation.itemBarComida7,
                  reservation.itemBarComida8,
                  reservation.itemBarComida9,
                  reservation.itemBarComida10
                ].any((qty) => qty > 0)) ...[
                  const SizedBox(height: 12),
                  const Text('🍽️ COMIDAS SELECIONADAS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  if (reservation.itemBarComida1 > 0)
                    Text('Item-bar-Comida - 1: ${reservation.itemBarComida1}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida2 > 0)
                    Text('Item-bar-Comida - 2: ${reservation.itemBarComida2}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida3 > 0)
                    Text('Item-bar-Comida - 3: ${reservation.itemBarComida3}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida4 > 0)
                    Text('Item-bar-Comida - 4: ${reservation.itemBarComida4}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida5 > 0)
                    Text('Item-bar-Comida - 5: ${reservation.itemBarComida5}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida6 > 0)
                    Text('Item-bar-Comida - 6: ${reservation.itemBarComida6}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida7 > 0)
                    Text('Item-bar-Comida - 7: ${reservation.itemBarComida7}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida8 > 0)
                    Text('Item-bar-Comida - 8: ${reservation.itemBarComida8}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida9 > 0)
                    Text('Item-bar-Comida - 9: ${reservation.itemBarComida9}x',
                        style: const TextStyle(color: Colors.white70)),
                  if (reservation.itemBarComida10 > 0)
                    Text(
                        'Item-bar-Comida - 10: ${reservation.itemBarComida10}x',
                        style: const TextStyle(color: Colors.white70)),
                ],

                if (reservation.listaPresentes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('🎁 PRESENTES ESCOLHIDOS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  ...reservation.listaPresentes.map((presente) => Text(presente,
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
                        'R\$ ${valorTotal.toStringAsFixed(2)}',
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
                _shareInviteLink(
                    'https://agilizaiapp.com/convite/${reservation.id}');
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
                              builder: (context) => ReservationDetailsScreen(
                                reservationId: reservation.id,
                              ),
                            ),
                          )
                              .then((_) {
                            _fetchReservations();
                            _fetchBirthdayReservations();
                          });
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
          FutureBuilder<List<BirthdayReservationModel>>(
            future: _birthdayReservationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Erro ao carregar reservas de aniversário: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma reserva de aniversário encontrada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              } else {
                final reservations = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];

                    Color statusColor = Colors.grey;
                    final status = reservation.status ?? 'pendente';
                    if (status == 'ATIVA' || status == 'pendente') {
                      statusColor = Colors.green[700]!;
                    } else if (status == 'CANCELADA') {
                      statusColor = Colors.red[700]!;
                    } else if (status == 'CONCLUIDA') {
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
                                          'Bar: ${_getBarName(reservation.barSelecionado)}',
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
                                      reservation.status ?? 'pendente',
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
                                      'Valor: R\$ ${_calculateTotalValue(reservation).toStringAsFixed(2)}',
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
                                          'https://agilizaiapp.com/convite/${reservation.id}'),
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
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
