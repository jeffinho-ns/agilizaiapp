// lib/models/event_model.dart

class Event {
  final int id;
  final String? casaDoEvento;
  final String? nomeDoEvento;
  final String? localDoEvento;
  final String? dataDoEvento;
  final String horaDoEvento;
  final String? categoria;
  final String? tipoEvento;
  final double? valorDaEntrada; // <-- Alterado para double?
  final String? descricao;

  final String? imagemDoEventoUrl;
  final String? imagemDoComboUrl;

  final String? criadoEm;
  final int? mesas;
  final double? valorDaMesa; // <-- Já é double?, mas o parse precisa ser seguro
  final String? brinde;
  final int? numeroDeConvidados;
  final String? observacao;
  final int? diaDaSemana;

  Event({
    required this.id,
    this.casaDoEvento,
    this.nomeDoEvento,
    this.localDoEvento,
    this.dataDoEvento,
    required this.horaDoEvento,
    this.categoria,
    this.tipoEvento,
    this.valorDaEntrada,
    this.descricao,
    this.imagemDoEventoUrl,
    this.imagemDoComboUrl,
    this.criadoEm,
    this.mesas,
    this.valorDaMesa,
    this.brinde,
    this.numeroDeConvidados,
    this.observacao,
    this.diaDaSemana,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para parsear valores numéricos de forma segura
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Função auxiliar para converter int nullable de string ou int para int?
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Event(
      id: parseId(json['id']),
      casaDoEvento: json['casa_do_evento'] as String?,
      nomeDoEvento: json['nome_do_evento'] as String?,
      localDoEvento: json['local_do_evento'] as String?,
      dataDoEvento: json['data_do_evento'] as String?,
      horaDoEvento: json['hora_do_evento'] as String,
      categoria: json['categoria'] as String?,
      // Aceita tanto tipoEvento (camelCase) quanto tipo_evento (snake_case)
      tipoEvento: json['tipoEvento'] as String? ?? json['tipo_evento'] as String?,
      valorDaEntrada:
          parseToDouble(json['valor_da_entrada']), // <--- APLICA PARSE SEGURO
      descricao: json['descricao'] as String?,

      imagemDoEventoUrl: json['imagem_do_evento_url'] as String?,
      imagemDoComboUrl: json['imagem_do_combo_url'] as String?,

      criadoEm: json['criado_em'] as String?,
      mesas: parseIntNullable(json['mesas']),
      valorDaMesa:
          parseToDouble(json['valor_da_mesa']), // <--- APLICA PARSE SEGURO
      brinde: json['brinde'] as String?,
      numeroDeConvidados: parseIntNullable(json['numero_de_convidados']),
      observacao: json['observacao'] as String?,
      diaDaSemana: parseIntNullable(json['dia_da_semana']),
    );
  }
}
