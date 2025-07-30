// lib/models/guest_model.dart

class Guest {
  final int id;
  final int reservaId;
  final String nome;
  final String qrCode;
  final String? status; // 'PENDENTE' ou 'CHECK-IN'
  final String? dataCheckin;
  final String? email;
  final String? telefone;
  final String? documento; // Adicionado de volta

  // Novos campos para check-in de localização
  final String? geoCheckinStatus;
  final String? geoCheckinTimestamp;
  final double? latitudeCheckin;
  final double? longitudeCheckin;

  // Campos adicionais que podem vir de JOINs no backend
  final String? nomeLista;
  final String? nomeDoCriadorDaLista;

  const Guest({
    required this.id,
    required this.reservaId,
    required this.nome,
    required this.qrCode,
    this.status,
    this.dataCheckin,
    this.email,
    this.telefone,
    this.documento, // Adicionado de volta
    this.geoCheckinStatus,
    this.geoCheckinTimestamp,
    this.latitudeCheckin,
    this.longitudeCheckin,
    this.nomeLista,
    this.nomeDoCriadorDaLista,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para parsear double de forma segura
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Guest(
      id: (json['id'] as num?)?.toInt() ??
          0, // <<--- CORRIGIDO: Tratamento seguro para int
      reservaId: (json['reserva_id'] as num?)?.toInt() ??
          0, // <<--- CORRIGIDO: Tratamento seguro para int
      nome: json['nome'] as String,
      qrCode: json['qr_code'] as String,
      status: json['status'] as String?,
      dataCheckin: json['data_checkin'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      documento: json['documento'] as String?, // Mapeado como String?

      geoCheckinStatus: json['geo_checkin_status'] as String?,
      geoCheckinTimestamp: json['geo_checkin_timestamp'] as String?,
      latitudeCheckin: parseToDouble(json['latitude_checkin']),
      longitudeCheckin: parseToDouble(json['longitude_checkin']),

      nomeLista: json['nome_lista'] as String?,
      nomeDoCriadorDaLista: json['nome_do_criador_da_lista'] as String?,
    );
  }
}
