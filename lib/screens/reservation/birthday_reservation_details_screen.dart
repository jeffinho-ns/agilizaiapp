// lib/screens/reservation/birthday_reservation_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agilizaiapp/models/birthday_reservation_model.dart';
import 'package:agilizaiapp/services/birthday_reservation_service.dart';

class BirthdayReservationDetailsScreen extends StatefulWidget {
  final int reservationId;

  const BirthdayReservationDetailsScreen(
      {super.key, required this.reservationId});

  @override
  State<BirthdayReservationDetailsScreen> createState() =>
      _BirthdayReservationDetailsScreenState();
}

class _BirthdayReservationDetailsScreenState
    extends State<BirthdayReservationDetailsScreen> {
  late Future<BirthdayReservation> _reservationDetailsFuture;
  final BirthdayReservationService _birthdayService =
      BirthdayReservationService();

  @override
  void initState() {
    super.initState();
    _fetchReservationDetails();
  }

  void _fetchReservationDetails() {
    setState(() {
      _reservationDetailsFuture = _birthdayService
          .fetchBirthdayReservationDetails(widget.reservationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalhes da Reserva de Aniversário'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF26422),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<BirthdayReservation>(
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

          final BirthdayReservation reservation = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card principal com informações básicas
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cake,
                                size: 30, color: const Color(0xFFF26422)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Reserva de Aniversário',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF26422),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Status da reserva
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(reservation.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _getStatusColor(reservation.status)),
                          ),
                          child: Text(
                            'Status: ${reservation.status}',
                            style: TextStyle(
                              color: _getStatusColor(reservation.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Informações do aniversariante
                        _buildInfoSection(
                          '🎂 Dados do Aniversariante',
                          [
                            _buildInfoRow(
                                'Nome', reservation.aniversarianteNome),
                            _buildInfoRow('Documento', reservation.documento),
                            _buildInfoRow('WhatsApp', reservation.whatsapp),
                            _buildInfoRow('E-mail', reservation.email),
                            _buildInfoRow(
                                'Data do Aniversário',
                                DateFormat('dd/MM/yyyy')
                                    .format(reservation.dataAniversario)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Informações do evento
                        _buildInfoSection(
                          '🎉 Detalhes do Evento',
                          [
                            _buildInfoRow(
                                'Bar Selecionado', reservation.barSelecionado),
                            _buildInfoRow('Quantidade de Convidados',
                                '${reservation.quantidadeConvidados} pessoas'),
                            _buildInfoRow(
                                'Data de Criação',
                                DateFormat('dd/MM/yyyy HH:mm')
                                    .format(reservation.createdAt)),
                            if (reservation.codigoConvite != null)
                              _buildInfoRow('Código do Convite',
                                  reservation.codigoConvite!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção de Decoração
                if (reservation.decoOpcao != null) ...[
                  _buildDecorationSection(reservation),
                  const SizedBox(height: 20),
                ],

                // Seção de Painel
                if (reservation.painelTipo != null) ...[
                  _buildPanelSection(reservation),
                  const SizedBox(height: 20),
                ],

                // Seção de Bebidas
                if (reservation.bebidasSelecionadas != null &&
                    reservation.bebidasSelecionadas!.isNotEmpty) ...[
                  _buildBeveragesSection(reservation),
                  const SizedBox(height: 20),
                ],

                // Seção de Comidas
                if (reservation.comidasSelecionadas != null &&
                    reservation.comidasSelecionadas!.isNotEmpty) ...[
                  _buildFoodSection(reservation),
                  const SizedBox(height: 20),
                ],

                // Seção de Presentes
                if (reservation.presentesSelecionados != null &&
                    reservation.presentesSelecionados!.isNotEmpty) ...[
                  _buildGiftsSection(reservation),
                  const SizedBox(height: 20),
                ],

                // Seção de Valor Total
                if (reservation.valorTotal != null) ...[
                  _buildTotalValueSection(reservation),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF26422),
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationSection(BirthdayReservation reservation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.celebration, color: const Color(0xFFF26422)),
                const SizedBox(width: 8),
                const Text(
                  '🎨 Decoração',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF26422),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Opção', reservation.decoOpcao!),
            if (reservation.decoPreco != null)
              _buildInfoRow(
                  'Preço', 'R\$ ${reservation.decoPreco!.toStringAsFixed(2)}'),
            if (reservation.decoDescricao != null)
              _buildInfoRow('Descrição', reservation.decoDescricao!),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelSection(BirthdayReservation reservation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: const Color(0xFFF26422)),
                const SizedBox(width: 8),
                const Text(
                  '🖼️ Painel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF26422),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Tipo', reservation.painelTipo!),
            if (reservation.painelTema != null)
              _buildInfoRow('Tema', reservation.painelTema!),
            if (reservation.painelFrase != null)
              _buildInfoRow('Frase', reservation.painelFrase!),
          ],
        ),
      ),
    );
  }

  Widget _buildBeveragesSection(BirthdayReservation reservation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_bar, color: const Color(0xFFF26422)),
                const SizedBox(width: 8),
                const Text(
                  '🥂 Bebidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF26422),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reservation.bebidasDetalhes != null)
              ...reservation.bebidasDetalhes!.map((bebida) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${bebida['nome']} (${bebida['quantidade']}x)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          'R\$ ${(bebida['preco'] * bebida['quantidade']).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF26422),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSection(BirthdayReservation reservation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: const Color(0xFFF26422)),
                const SizedBox(width: 8),
                const Text(
                  '🍽️ Comidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF26422),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reservation.comidasDetalhes != null)
              ...reservation.comidasDetalhes!.map((comida) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${comida['nome']} (${comida['quantidade']}x)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          'R\$ ${(comida['preco'] * comida['quantidade']).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF26422),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftsSection(BirthdayReservation reservation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: const Color(0xFFF26422)),
                const SizedBox(width: 8),
                const Text(
                  '🎁 Presentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF26422),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reservation.presentesSelecionados != null)
              ...reservation.presentesSelecionados!.map((presente) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            presente['nome'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          'R\$ ${presente['preco'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF26422),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalValueSection(BirthdayReservation reservation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF26422), Color(0xFFFF8A65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              '💰 VALOR TOTAL DA RESERVA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'R\$ ${reservation.valorTotal!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Este valor será adicionado à sua comanda no bar selecionado.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE':
        return Colors.orange;
      case 'APROVADA':
      case 'ATIVA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'CONCLUIDA':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
