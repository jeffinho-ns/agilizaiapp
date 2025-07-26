// lib/models/guest_model.dart

class Guest {
  final int id;
  final int reservaId;
  final String nome;
  final String qrCode; // O TEXTO do QR Code, não a imagem
  final String status; // 'PENDENTE' ou 'CHECK-IN'
  final String? dataCheckin;

  const Guest({
    required this.id,
    required this.reservaId,
    required this.nome,
    required this.qrCode,
    required this.status,
    this.dataCheckin,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      // reserva_id não vem na lista de convidados aninhada, mas é bom ter no modelo
      // para outras ocasiões. Se vier nulo, usamos um valor padrão.
      reservaId: json['reserva_id'] ?? 0,
      nome: json['nome'],
      qrCode: json['qr_code'],
      status: json['status'],
      dataCheckin: json['data_checkin'],
    );
  }
}
