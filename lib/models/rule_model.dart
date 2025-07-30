// lib/models/rule_model.dart

class EventRule {
  final int id;
  final int eventoId;
  final String tipoRegra;
  final String valorRegra;
  final String descricao;
  final String? valorExtra;
  final String status;

  const EventRule({
    required this.id,
    required this.eventoId,
    required this.tipoRegra,
    required this.valorRegra,
    required this.descricao,
    this.valorExtra,
    required this.status,
  });

  factory EventRule.fromJson(Map<String, dynamic> json) {
    return EventRule(
      id: json['id'],
      eventoId: json['evento_id'],
      tipoRegra: json['tipo_regra'],
      valorRegra: json['valor_regra'],
      descricao: json['descricao'],
      valorExtra: json['valor_extra'],
      status: json['status'],
    );
  }
}
