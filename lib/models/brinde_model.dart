// lib/models/brinde_model.dart


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

    return Brinde(
      id: parseId(json['id']),
      reservaId: parseId(json['reserva_id']),
      descricao: json['descricao'] as String?,
      condicaoTipo: json['condicao_tipo'] as String?,
      condicaoValor: parseIntNullable(json['condicao_valor']),
      status: json['status'] as String?,
    );
  }
}
