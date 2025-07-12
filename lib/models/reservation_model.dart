// lib/models/reservation_model.dart

class Reservation {
  final int id;
  final String? mesas; // AGORA DEFINITIVAMENTE ANULÁVEL (String?)
  final String casaDaReserva; // Assumimos que 'casa_do_evento' nunca é null
  final String? dataDaReserva; // Pode ser null (place-reservation passa null)
  final String? imagemDoEvento; // Já estava como String?
  final String statusDaReserva; // Assumimos que 'status' nunca é null
  final int userId; // Assumimos que 'user_id' nunca é null
  final String? qrcodeUrl; // Pode ser null
  final int? quantidadePessoas; // Pode ser null

  // Novos campos que podem vir da API de 'reservas' (da query SELECT *)
  final String?
  nomeDoEvento; // Pode ser null se for reserva de local, por exemplo
  final String? horaDoEvento; // Pode ser null
  final String? localDoEvento; // Pode ser null
  final String? brinde; // Pode ser null
  final int? eventId; // Pode ser null (para reserva de local)

  // Campos do User que são copiados para a reserva
  final String? userName; // 'name' do user
  final String? userEmail; // 'email' do user
  final String? userTelefone; // 'telefone' do user
  final String? userFotoPerfil; // 'foto_perfil' do user

  const Reservation({
    required this.id,
    this.mesas,
    required this.casaDaReserva,
    this.dataDaReserva,
    this.imagemDoEvento,
    required this.statusDaReserva,
    required this.userId,
    this.qrcodeUrl,
    this.quantidadePessoas,
    this.nomeDoEvento,
    this.horaDoEvento,
    this.localDoEvento,
    this.brinde,
    this.eventId, // Incluído aqui
    this.userName,
    this.userEmail,
    this.userTelefone,
    this.userFotoPerfil,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Helper function para parsear int de forma segura.
    // Retorna 0 se o valor for nulo, não for um int, ou não puder ser parseado de uma string.
    int _parseInt(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    // Helper function para parsear int anulável de forma segura.
    // Retorna null se o valor for nulo, não for um int, ou não puder ser parseado de uma string.
    int? _parseIntNullable(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value);
      }
      return null; // Retorna null para null ou outros tipos não esperados
    }

    return Reservation(
      // Usando _parseInt para campos 'required' que esperamos que sejam int
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      statusDaReserva:
          json['status'] as String, // Assume que status é sempre String
      casaDaReserva:
          json['casa_do_evento']
              as String, // Assume que casa_do_evento é sempre String
      // Usando _parseIntNullable para eventId, que é anulável no modelo
      eventId: _parseIntNullable(
        json['event_id'],
      ), // ADICIONADO E USANDO PARSE SEGURO
      // Para os demais campos que já são anuláveis (String? ou int?),
      // o 'as Tipo?' já lida com o null se a chave não existir ou o valor for null.
      mesas: json['mesas'] as String?,
      dataDaReserva: json['data_do_evento'] as String?,
      imagemDoEvento: json['imagem_do_evento'] as String?,
      qrcodeUrl: json['qrcode'] as String?,
      quantidadePessoas: json['quantidade_pessoas'] as int?,
      nomeDoEvento: json['nome_do_evento'] as String?,
      horaDoEvento: json['hora_do_evento'] as String?,
      localDoEvento: json['local_do_evento'] as String?,
      brinde: json['brinde'] as String?,
      userName: json['name'] as String?,
      userEmail: json['email'] as String?,
      userTelefone: json['telefone'] as String?,
      userFotoPerfil: json['foto_perfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mesas': mesas,
      'casa_do_evento': casaDaReserva,
      'data_do_evento': dataDaReserva,
      'imagem_do_evento': imagemDoEvento,
      'status': statusDaReserva,
      'user_id': userId,
      'qrcodeUrl': qrcodeUrl,
      'quantidade_pessoas': quantidadePessoas,
      'nome_do_evento': nomeDoEvento,
      'hora_do_evento': horaDoEvento,
      'local_do_evento': localDoEvento,
      'brinde': brinde,
      'event_id': eventId, // Incluído aqui
      'name': userName,
      'email': userEmail,
      'telefone': userTelefone,
      'foto_perfil': userFotoPerfil,
    };
  }
}
