// lib/models/event_model.dart

class Event {
  // --- CAMPOS ESSENCIAIS PARA A TELA DE DETALHES ---

  final int id; // Essencial para qualquer operação (reserva, etc.)
  final String? casaDoEvento; // Essencial para criar a reserva
  final String? nomeDoEvento; // Usado no cabeçalho
  final String? localDoEvento; // Usado no cabeçalho
  final String? dataDoEvento; // Usado no cabeçalho
  final String? horaDoEvento; // Usado no cabeçalho
  final String? categoria;
  final dynamic
  valorDaEntrada; // Usado no cabeçalho (dynamic para ser flexível)
  final String? descricao; // Usado na seção de descrição

  // URLs de imagem que já vêm prontas da sua API
  final String? imagemDoEventoUrl;
  final String? imagemDoComboUrl;

  Event({
    required this.id,
    this.casaDoEvento,
    this.nomeDoEvento,
    this.localDoEvento,
    this.dataDoEvento,
    this.horaDoEvento,
    this.categoria,
    this.valorDaEntrada,
    this.descricao,
    this.imagemDoEventoUrl,
    this.imagemDoComboUrl,
  });

  // Factory minimalista e segura para criar um Event a partir de JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      // Campos obrigatórios para a tela funcionar
      id: json['id'] as int,
      casaDoEvento: json['casa_do_evento'] as String?,
      nomeDoEvento: json['nome_do_evento'] as String?,
      localDoEvento: json['local_do_evento'] as String?,
      dataDoEvento: json['data_do_evento'] as String?,
      horaDoEvento: json['hora_do_evento'] as String?,
      categoria: json['categoria'] as String?,
      valorDaEntrada:
          json['valor_da_entrada'], // Deixado como dynamic para evitar erros de tipo
      descricao: json['descricao'] as String?,

      // URLs que a API já fornece prontas
      imagemDoEventoUrl: json['imagem_do_evento_url'] as String?,
      imagemDoComboUrl: json['imagem_do_combo_url'] as String?,
    );
  }
}
