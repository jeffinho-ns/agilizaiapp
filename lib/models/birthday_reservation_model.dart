// lib/models/birthday_reservation_model.dart

class BirthdayReservation {
  final int id;
  final int userId;
  final String aniversarianteNome;
  final String documento;
  final String whatsapp;
  final String email;
  final DateTime dataAniversario;
  final String barSelecionado;
  final int quantidadeConvidados;
  final String status;
  final String? codigoConvite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Dados de decoração
  final String? decoOpcao;
  final double? decoPreco;
  final String? decoDescricao;

  // Dados do painel
  final String? painelTipo; // 'estoque' ou 'personalizado'
  final String? painelImagem;
  final String? painelTema;
  final String? painelFrase;

  // Dados de bebidas
  final Map<String, int>? bebidasSelecionadas;
  final List<Map<String, dynamic>>? bebidasDetalhes;

  // Dados de comidas
  final Map<String, int>? comidasSelecionadas;
  final List<Map<String, dynamic>>? comidasDetalhes;

  // Dados de presentes
  final List<Map<String, dynamic>>? presentesSelecionados;

  // Valor total
  final double? valorTotal;

  const BirthdayReservation({
    required this.id,
    required this.userId,
    required this.aniversarianteNome,
    required this.documento,
    required this.whatsapp,
    required this.email,
    required this.dataAniversario,
    required this.barSelecionado,
    required this.quantidadeConvidados,
    required this.status,
    this.codigoConvite,
    required this.createdAt,
    this.updatedAt,
    this.decoOpcao,
    this.decoPreco,
    this.decoDescricao,
    this.painelTipo,
    this.painelImagem,
    this.painelTema,
    this.painelFrase,
    this.bebidasSelecionadas,
    this.bebidasDetalhes,
    this.comidasSelecionadas,
    this.comidasDetalhes,
    this.presentesSelecionados,
    this.valorTotal,
  });

  factory BirthdayReservation.fromJson(Map<String, dynamic> json) {
    // Extrair dados específicos do aniversário se existirem
    final dadosAniversario = json['dados_aniversario'] as Map<String, dynamic>?;

    return BirthdayReservation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      aniversarianteNome: dadosAniversario?['aniversariante_nome'] as String? ??
          json['aniversariante_nome'] as String? ??
          'N/A',
      documento: dadosAniversario?['aniversariante_documento'] as String? ??
          json['aniversariante_documento'] as String? ??
          'N/A',
      whatsapp: dadosAniversario?['aniversariante_whatsapp'] as String? ??
          json['aniversariante_whatsapp'] as String? ??
          'N/A',
      email: dadosAniversario?['aniversariante_email'] as String? ??
          json['aniversariante_email'] as String? ??
          'N/A',
      dataAniversario: DateTime.parse(json['data_reserva'] as String? ??
          json['data_aniversario'] as String),
      barSelecionado: dadosAniversario?['bar_selecionado'] as String? ??
          json['bar_selecionado'] as String? ??
          'N/A',
      quantidadeConvidados: json['quantidade_convidados'] as int,
      status: json['status'] as String,
      codigoConvite: json['codigo_convite'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,

      // Dados de decoração
      decoOpcao: dadosAniversario?['decoracao']?['opcao'] as String? ??
          json['decoracao']?['opcao'] as String?,
      decoPreco:
          (dadosAniversario?['decoracao']?['preco'] as num?)?.toDouble() ??
              (json['decoracao']?['preco'] as num?)?.toDouble(),
      decoDescricao: dadosAniversario?['decoracao']?['descricao'] as String? ??
          json['decoracao']?['descricao'] as String?,

      // Dados do painel
      painelTipo: dadosAniversario?['painel']?['tipo'] as String? ??
          json['painel']?['tipo'] as String?,
      painelImagem: dadosAniversario?['painel']?['imagem'] as String? ??
          json['painel']?['imagem'] as String?,
      painelTema: dadosAniversario?['painel']?['tema'] as String? ??
          json['painel']?['tema'] as String?,
      painelFrase: dadosAniversario?['painel']?['frase'] as String? ??
          json['painel']?['frase'] as String?,

      // Dados de bebidas
      bebidasSelecionadas: dadosAniversario?['bebidas']?['selecionadas'] != null
          ? Map<String, int>.from(
              dadosAniversario!['bebidas']['selecionadas'] as Map)
          : json['bebidas']?['selecionadas'] != null
              ? Map<String, int>.from(json['bebidas']['selecionadas'] as Map)
              : null,
      bebidasDetalhes: dadosAniversario?['bebidas']?['detalhes'] != null
          ? List<Map<String, dynamic>>.from(
              dadosAniversario!['bebidas']['detalhes'] as List)
          : json['bebidas']?['detalhes'] != null
              ? List<Map<String, dynamic>>.from(
                  json['bebidas']['detalhes'] as List)
              : null,

      // Dados de comidas
      comidasSelecionadas: dadosAniversario?['comidas']?['selecionadas'] != null
          ? Map<String, int>.from(
              dadosAniversario!['comidas']['selecionadas'] as Map)
          : json['comidas']?['selecionadas'] != null
              ? Map<String, int>.from(json['comidas']['selecionadas'] as Map)
              : null,
      comidasDetalhes: dadosAniversario?['comidas']?['detalhes'] != null
          ? List<Map<String, dynamic>>.from(
              dadosAniversario!['comidas']['detalhes'] as List)
          : json['comidas']?['detalhes'] != null
              ? List<Map<String, dynamic>>.from(
                  json['comidas']['detalhes'] as List)
              : null,

      // Dados de presentes
      presentesSelecionados: dadosAniversario?['presentes'] != null
          ? List<Map<String, dynamic>>.from(
              dadosAniversario!['presentes'] as List)
          : json['presentes'] != null
              ? List<Map<String, dynamic>>.from(json['presentes'] as List)
              : null,

      // Valor total
      valorTotal: (dadosAniversario?['valor_total'] as num?)?.toDouble() ??
          (json['valor_total'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'aniversariante_nome': aniversarianteNome,
      'aniversariante_documento': documento,
      'aniversariante_whatsapp': whatsapp,
      'aniversariante_email': email,
      'data_aniversario': dataAniversario.toIso8601String(),
      'bar_selecionado': barSelecionado,
      'quantidade_convidados': quantidadeConvidados,
      'status': status,
      'codigo_convite': codigoConvite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      // Dados de decoração
      'decoracao': {
        'opcao': decoOpcao,
        'preco': decoPreco,
        'descricao': decoDescricao,
      },

      // Dados do painel
      'painel': {
        'tipo': painelTipo,
        'imagem': painelImagem,
        'tema': painelTema,
        'frase': painelFrase,
      },

      // Dados de bebidas
      'bebidas': {
        'selecionadas': bebidasSelecionadas,
        'detalhes': bebidasDetalhes,
      },

      // Dados de comidas
      'comidas': {
        'selecionadas': comidasSelecionadas,
        'detalhes': comidasDetalhes,
      },

      // Dados de presentes
      'presentes': presentesSelecionados,

      // Valor total
      'valor_total': valorTotal,
    };
  }

  // Método para criar uma cópia com alterações
  BirthdayReservation copyWith({
    int? id,
    int? userId,
    String? aniversarianteNome,
    String? documento,
    String? whatsapp,
    String? email,
    DateTime? dataAniversario,
    String? barSelecionado,
    int? quantidadeConvidados,
    String? status,
    String? codigoConvite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? decoOpcao,
    double? decoPreco,
    String? decoDescricao,
    String? painelTipo,
    String? painelImagem,
    String? painelTema,
    String? painelFrase,
    Map<String, int>? bebidasSelecionadas,
    List<Map<String, dynamic>>? bebidasDetalhes,
    Map<String, int>? comidasSelecionadas,
    List<Map<String, dynamic>>? comidasDetalhes,
    List<Map<String, dynamic>>? presentesSelecionados,
    double? valorTotal,
  }) {
    return BirthdayReservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      aniversarianteNome: aniversarianteNome ?? this.aniversarianteNome,
      documento: documento ?? this.documento,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      dataAniversario: dataAniversario ?? this.dataAniversario,
      barSelecionado: barSelecionado ?? this.barSelecionado,
      quantidadeConvidados: quantidadeConvidados ?? this.quantidadeConvidados,
      status: status ?? this.status,
      codigoConvite: codigoConvite ?? this.codigoConvite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      decoOpcao: decoOpcao ?? this.decoOpcao,
      decoPreco: decoPreco ?? this.decoPreco,
      decoDescricao: decoDescricao ?? this.decoDescricao,
      painelTipo: painelTipo ?? this.painelTipo,
      painelImagem: painelImagem ?? this.painelImagem,
      painelTema: painelTema ?? this.painelTema,
      painelFrase: painelFrase ?? this.painelFrase,
      bebidasSelecionadas: bebidasSelecionadas ?? this.bebidasSelecionadas,
      bebidasDetalhes: bebidasDetalhes ?? this.bebidasDetalhes,
      comidasSelecionadas: comidasSelecionadas ?? this.comidasSelecionadas,
      comidasDetalhes: comidasDetalhes ?? this.comidasDetalhes,
      presentesSelecionados:
          presentesSelecionados ?? this.presentesSelecionados,
      valorTotal: valorTotal ?? this.valorTotal,
    );
  }

  @override
  String toString() {
    return 'BirthdayReservation(id: $id, aniversarianteNome: $aniversarianteNome, barSelecionado: $barSelecionado, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayReservation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
