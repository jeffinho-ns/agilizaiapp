// lib/models/reservation_model.dart
class Reservation {
  final int id;
  final int userId; // Mapeia para user_id no backend
  final int?
  eventId; // Mapeia para event_id no backend (pode ser null para place-reservation)
  final int quantidadePessoas;
  final String mesas;
  final String dataDaReserva;
  final String casaDaReserva;
  final String statusDaReserva; // e.g., 'Aguardando', 'Aprovado', 'Rejeitado'
  final String? qrcodeUrl; // URL do QR Code, pode ser nulo se não aprovado

  // NOVO: Adicionado para a imagem do evento/local
  final String? imagemDoEvento; // Mapeia para imagem_do_evento no backend

  // Adicione mais campos aqui conforme necessário se sua reserva retornar mais dados
  // Ex: nome, email, telefone do usuário (se relevante aqui), nome_do_evento, etc.
  final String?
  nomeDoEvento; // Opcional, se a reserva também carregar o nome do evento

  Reservation({
    required this.id,
    required this.userId,
    this.eventId, // Tornar nullável
    required this.quantidadePessoas,
    required this.mesas,
    required this.dataDaReserva,
    required this.casaDaReserva,
    required this.statusDaReserva,
    this.qrcodeUrl,
    this.imagemDoEvento, // NOVO
    this.nomeDoEvento, // NOVO
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      userId: json['user_id'] as int, // Corresponde ao `user_id` do seu banco
      eventId:
          json['event_id']
              as int?, // `event_id` pode ser null para reservas de local
      quantidadePessoas: json['quantidade_pessoas'] as int,
      mesas: json['mesas'] as String,
      dataDaReserva: json['data_da_reserva'] as String,
      casaDaReserva: json['casa_da_reserva'] as String,
      statusDaReserva:
          json['status'] as String, // Corresponde ao `status` do seu banco
      qrcodeUrl: json['qrcode_url'] as String?,
      imagemDoEvento:
          json['imagem_do_evento']
              as String?, // NOVO: Mapear o nome do arquivo da imagem
      nomeDoEvento:
          json['nome_do_evento']
              as String?, // NOVO: Mapear o nome do evento da reserva
    );
  }
}
