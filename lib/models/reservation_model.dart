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
    this.eventId,
    this.userName,
    this.userEmail,
    this.userTelefone,
    this.userFotoPerfil,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      casaDaReserva: json['casa_do_evento'] as String,
      dataDaReserva: json['data_do_evento'] as String?, // Cast para String?
      imagemDoEvento: json['imagem_do_evento'] as String?,
      statusDaReserva: json['status'] as String,
      userId: json['user_id'] as int,
      mesas: json['mesas'] as String?, // Cast para String?
      qrcodeUrl:
          json['qrcodeUrl'] as String?, // Se sua API retornar 'qrcodeUrl'
      quantidadePessoas: json['quantidade_pessoas'] as int?, // Cast para int?
      nomeDoEvento: json['nome_do_evento'] as String?, // Cast para String?
      horaDoEvento: json['hora_do_evento'] as String?, // NOVO: Campo da API
      localDoEvento: json['local_do_evento'] as String?, // NOVO: Campo da API
      brinde: json['brinde'] as String?, // NOVO: Campo da API
      eventId: json['event_id'] as int?, // NOVO: Campo da API
      // Campos do usuário que são copiados para a tabela de reservas
      userName: json['name'] as String?, // 'name' do user
      userEmail: json['email'] as String?, // 'email' do user
      userTelefone: json['telefone'] as String?, // 'telefone' do user
      userFotoPerfil: json['foto_perfil'] as String?, // 'foto_perfil' do user
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
      'event_id': eventId,
      'name': userName,
      'email': userEmail,
      'telefone': userTelefone,
      'foto_perfil': userFotoPerfil,
    };
  }
}
