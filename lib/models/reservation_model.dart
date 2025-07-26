// lib/models/reservation_model.dart

import 'brinde_model.dart';
import 'guest_model.dart';

class Reservation {
  final int id;
  final int userId;
  final int? eventoId;
  final String tipoReserva;
  final String nomeLista;
  final String dataReserva;
  final String status;

  // --- NOVOS CAMPOS ADICIONADOS ---
  final int quantidadeConvidados;
  final String? codigoConvite;

  // --- Listas de Objetos Relacionados ---
  final List<Guest> convidados;
  final List<Brinde> brindes;

  const Reservation({
    required this.id,
    required this.userId,
    this.eventoId,
    required this.tipoReserva,
    required this.nomeLista,
    required this.dataReserva,
    required this.status,
    required this.quantidadeConvidados, // Adicionado ao construtor
    this.codigoConvite, // Adicionado ao construtor
    required this.convidados,
    required this.brindes,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    var convidadosList = <Guest>[];
    if (json['convidados'] != null) {
      convidadosList =
          (json['convidados'] as List).map((i) => Guest.fromJson(i)).toList();
    }

    var brindesList = <Brinde>[];
    if (json['brindes'] != null) {
      brindesList =
          (json['brindes'] as List).map((i) => Brinde.fromJson(i)).toList();
    }

    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      eventoId: json['evento_id'],
      tipoReserva: json['tipo_reserva'],
      nomeLista: json['nome_lista'],
      dataReserva: json['data_reserva'],
      status: json['status'],
      // Mapeando os novos campos do JSON
      quantidadeConvidados: json['quantidade_convidados'] ?? 1,
      codigoConvite: json['codigo_convite'],
      convidados: convidadosList,
      brindes: brindesList,
    );
  }
}
