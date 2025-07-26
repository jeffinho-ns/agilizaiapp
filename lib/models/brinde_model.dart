// lib/models/brinde_model.dart

class Brinde {
  final int id;
  final int reservaId;
  final String descricao;
  final String condicaoTipo;
  final int condicaoValor;
  final String status;

  const Brinde({
    required this.id,
    required this.reservaId,
    required this.descricao,
    required this.condicaoTipo,
    required this.condicaoValor,
    required this.status,
  });

  factory Brinde.fromJson(Map<String, dynamic> json) {
    return Brinde(
      id: json['id'],
      reservaId: json['reserva_id'],
      descricao: json['descricao'],
      condicaoTipo: json['condicao_tipo'],
      condicaoValor: json['condicao_valor'],
      status: json['status'],
    );
  }
}
