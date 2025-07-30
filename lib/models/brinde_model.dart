// lib/models/brinde_model.dart

import 'package:flutter/material.dart';

class Brinde {
  final int id;
  final int reservaId;
  final String? descricao;
  final String? condicaoTipo;
  final int? condicaoValor; // Agora pode ser nulo
  final String? status;

  const Brinde({
    required this.id,
    required this.reservaId,
    this.descricao,
    this.condicaoTipo,
    this.condicaoValor,
    this.status,
  });

  factory Brinde.fromJson(Map<String, dynamic> json) {
    return Brinde(
      id: (json['id'] as num?)?.toInt() ??
          0, // <<--- CORRIGIDO: Tratamento seguro para int
      reservaId: (json['reserva_id'] as num?)?.toInt() ??
          0, // <<--- CORRIGIDO: Tratamento seguro para int
      descricao: json['descricao'] as String?,
      condicaoTipo: json['condicao_tipo'] as String?,
      condicaoValor: (json['condicao_valor'] as num?)
          ?.toInt(), // <<--- CORRIGIDO: Tratamento seguro para int (pode ser nulo)
      status: json['status'] as String?,
    );
  }
}
