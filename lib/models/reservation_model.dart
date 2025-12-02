// lib/models/reservation_model.dart

import 'package:agilizaiapp/models/brinde_model.dart'; // Assumindo que BrindeRule agora é Brinde
import 'package:agilizaiapp/models/guest_model.dart';

class Reservation {
  final int id;
  final int userId;
  final int? eventId;
  final String? tipoReserva;
  final String? nomeLista;
  final String? dataReserva;
  final String? status;
  final String? creatorName; // Campo para o nome do criador
  final int quantidadeConvidados;
  final String? codigoConvite; // ÚNICA declaração para o código do convite
  final String? mesas;

  // Campos de usuário (se vierem junto na mesma requisição de reserva)
  final String? userName; // Renomeado para evitar conflito com nomeDoEvento
  final String? userEmail;
  final String? userTelefone;
  final String? userFotoPerfil;

  // Campos do evento (se vierem junto na mesma requisição de reserva)
  final String? nomeDoEvento;
  final String? dataDoEvento;
  final String? horaDoEvento;
  final String? imagemDoEvento;
  final String? casaDoEvento;
  final String? localDoEvento;

  final List<Guest>? convidados;
  final List<Brinde>? brindes; // Assumindo que BrindeRule agora é Brinde

  const Reservation({
    required this.id,
    required this.userId,
    this.eventId,
    this.tipoReserva,
    this.nomeLista,
    this.dataReserva,
    this.status,
    required this.quantidadeConvidados,
    this.codigoConvite,
    this.mesas,
    this.userName, // Ajuste o nome aqui
    this.userEmail,
    this.userTelefone,
    this.userFotoPerfil,
    this.nomeDoEvento,
    this.dataDoEvento,
    this.horaDoEvento,
    this.imagemDoEvento,
    this.casaDoEvento,
    this.localDoEvento,
    this.convidados,
    this.brindes,
    this.creatorName, // Inclua no construtor
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Função auxiliar para converter int nullable de string ou int para int?
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    List<Guest>? parsedGuests;
    if (json['convidados'] != null) {
      parsedGuests = (json['convidados'] as List<dynamic>)
          .map((guestJson) => Guest.fromJson(guestJson as Map<String, dynamic>))
          .toList();
    }

    List<Brinde>? parsedBrindes; // Assumindo que BrindeRule agora é Brinde
    if (json['brindes'] != null) {
      parsedBrindes = (json['brindes'] as List<dynamic>)
          .map((brindeJson) =>
              Brinde.fromJson(brindeJson as Map<String, dynamic>))
          .toList();
    }

    return Reservation(
      id: parseId(json['id']),
      userId: parseId(json['user_id'] ?? json['userId']),
      eventId: parseIntNullable(json['evento_id'] ?? json['eventId']),
      tipoReserva:
          json['brinde'] as String?, // API retorna 'brinde' para tipo_reserva
      nomeLista: json['nome_lista'] as String?,
      dataReserva: json['data_reserva'] as String?,
      status: json['status'] as String?,
      quantidadeConvidados: parseIntNullable(json['quantidade_convidados']) ?? 1,
      codigoConvite: json['codigo_convite'] as String?,
      mesas: json['mesas'] as String?,
      userName: json['name'] as String?, // Nome do usuário criador
      userEmail: json['email'] as String?,
      userTelefone: json['telefone'] as String?,
      userFotoPerfil: json['foto_perfil'] as String?,
      nomeDoEvento: json['nome_do_evento'] as String?,
      dataDoEvento: json['data_do_evento'] as String?,
      horaDoEvento: json['hora_do_evento'] as String?,
      imagemDoEvento: json['imagem_do_evento'] as String?,
      casaDoEvento: json['casa_do_evento'] as String?,
      localDoEvento: json['local_do_evento'] as String?,
      convidados: parsedGuests,
      brindes: parsedBrindes,
      creatorName: json['creatorName'] as String?, // <--- ESSA LINHA É CRUCIAL!
    );
  }
}
