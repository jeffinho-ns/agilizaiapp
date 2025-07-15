// lib/models/guest_model.dart

import 'dart:convert'; // <<< Correto: Mantém o import para jsonDecode
import 'package:flutter/material.dart'; // Mantido para Amenity, mas pode ser removido se não for usado aqui.

class Guest {
  final int id;
  final int eventId;
  final String nome;
  final String? documento;
  final String lista; // 'Geral', 'VIP', 'Camarote', etc.
  final int adicionadoPor; // ID do promotor
  final int? usuarioClienteId; // NOVO: ID do cliente que se adicionou
  final String? creatorId; // <--- CORRETO: Propriedade adicionada
  final String? creatorName; // <--- CORRETO: Propriedade adicionada
  final List<Map<String, dynamic>>?
      combosSelecionados; // NOVO: Combos selecionados

  Guest({
    required this.id,
    required this.eventId,
    required this.nome,
    this.documento,
    required this.lista,
    required this.adicionadoPor,
    this.usuarioClienteId,
    this.combosSelecionados,
    this.creatorId, // <--- CORRETO: No construtor
    this.creatorName, // <--- CORRETO: No construtor
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as int,
      eventId: json['event_id'] as int,
      nome: json['nome'] as String,
      documento: json['documento'] as String?,
      lista: json['lista'] as String,
      adicionadoPor: json['adicionado_por'] as int,
      usuarioClienteId: json['usuario_cliente_id'] as int?,
      creatorId: json['creatorId'] as String?, // <--- CORRETO: No fromJson
      creatorName: json['creatorName'] as String?, // <--- CORRETO: No fromJson
      combosSelecionados: (json['combos_selecionados'] as String?) != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(json['combos_selecionados'])) // Correto
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'nome': nome,
      'documento': documento,
      'lista': lista,
      'adicionado_por': adicionadoPor,
      'usuario_cliente_id': usuarioClienteId,
      'creatorId': creatorId, // <--- CORRETO: No toJson
      'creatorName': creatorName, // <--- CORRETO: No toJson
      'combos_selecionados': combosSelecionados != null
          ? jsonEncode(combosSelecionados)
          : null, // Correto
    };
  }

  // (Você pode adicionar o copyWith aqui se ainda não o tem, como no exemplo anterior)
  /*
  Guest copyWith({
    String? nome,
    String? lista,
    String? documento,
    String? status, // Se 'status' ainda for parte do seu Guest
    String? creatorId,
    String? creatorName,
    int? adicionadoPor,
    int? usuarioClienteId,
    List<Map<String, dynamic>>? combosSelecionados,
  }) {
    return Guest(
      id: id,
      eventId: eventId,
      nome: nome ?? this.nome,
      documento: documento ?? this.documento,
      lista: lista ?? this.lista,
      adicionadoPor: adicionadoPor ?? this.adicionadoPor,
      usuarioClienteId: usuarioClienteId ?? this.usuarioClienteId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      combosSelecionados: combosSelecionados ?? this.combosSelecionados,
    );
  }
  */
}

class GuestCount {
  final String lista;
  final int total;

  GuestCount({required this.lista, required this.total});

  factory GuestCount.fromJson(Map<String, dynamic> json) {
    return GuestCount(
      lista: json['lista'] as String,
      total: json['total'] as int,
    );
  }
}
