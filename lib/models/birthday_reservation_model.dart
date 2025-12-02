// lib/models/birthday_reservation_model.dart

import 'dart:convert';

class BirthdayReservationModel {
  final int? id;
  final int userId;
  final String aniversarianteNome;
  final DateTime dataAniversario;
  final int quantidadeConvidados;
  final dynamic barSelecionado; // Pode ser int ou String

  // Decoração
  final String? decoracaoTipo; // Decoração Pequena 1, Decoração Pequena 2, etc.

  // Painel
  final bool painelPersonalizado;
  final String? painelTema;
  final String? painelFrase;
  final String? painelEstoqueImagemUrl; // Estoque 1, Estoque 2, etc.

  // Bebidas do Bar
  final int itemBarBebida1;
  final int itemBarBebida2;
  final int itemBarBebida3;
  final int itemBarBebida4;
  final int itemBarBebida5;
  final int itemBarBebida6;
  final int itemBarBebida7;
  final int itemBarBebida8;
  final int itemBarBebida9;
  final int itemBarBebida10;

  // Comidas do Bar
  final int itemBarComida1;
  final int itemBarComida2;
  final int itemBarComida3;
  final int itemBarComida4;
  final int itemBarComida5;
  final int itemBarComida6;
  final int itemBarComida7;
  final int itemBarComida8;
  final int itemBarComida9;
  final int itemBarComida10;

  // Lista de Presentes
  final List<String>
      listaPresentes; // Lista-Presente - 1, Lista-Presente - 2, etc.

  // Campos adicionais
  final String? documento;
  final String? whatsapp;
  final String? email;
  final String? status;

  BirthdayReservationModel({
    this.id,
    required this.userId,
    required this.aniversarianteNome,
    required this.dataAniversario,
    required this.quantidadeConvidados,
    this.barSelecionado,
    this.decoracaoTipo,
    required this.painelPersonalizado,
    this.painelTema,
    this.painelFrase,
    this.painelEstoqueImagemUrl,
    this.itemBarBebida1 = 0,
    this.itemBarBebida2 = 0,
    this.itemBarBebida3 = 0,
    this.itemBarBebida4 = 0,
    this.itemBarBebida5 = 0,
    this.itemBarBebida6 = 0,
    this.itemBarBebida7 = 0,
    this.itemBarBebida8 = 0,
    this.itemBarBebida9 = 0,
    this.itemBarBebida10 = 0,
    this.itemBarComida1 = 0,
    this.itemBarComida2 = 0,
    this.itemBarComida3 = 0,
    this.itemBarComida4 = 0,
    this.itemBarComida5 = 0,
    this.itemBarComida6 = 0,
    this.itemBarComida7 = 0,
    this.itemBarComida8 = 0,
    this.itemBarComida9 = 0,
    this.itemBarComida10 = 0,
    this.listaPresentes = const [],
    this.documento,
    this.whatsapp,
    this.email,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'aniversariante_nome': aniversarianteNome,
      'data_aniversario': dataAniversario.toIso8601String(),
      'quantidade_convidados': quantidadeConvidados,
      'id_casa_evento': barSelecionado,
      'decoracao_tipo': decoracaoTipo,
      'painel_personalizado': painelPersonalizado ? 1 : 0,
      'painel_tema': painelTema,
      'painel_frase': painelFrase,
      'painel_estoque_imagem_url': painelEstoqueImagemUrl,
      'item_bar_bebida_1': itemBarBebida1,
      'item_bar_bebida_2': itemBarBebida2,
      'item_bar_bebida_3': itemBarBebida3,
      'item_bar_bebida_4': itemBarBebida4,
      'item_bar_bebida_5': itemBarBebida5,
      'item_bar_bebida_6': itemBarBebida6,
      'item_bar_bebida_7': itemBarBebida7,
      'item_bar_bebida_8': itemBarBebida8,
      'item_bar_bebida_9': itemBarBebida9,
      'item_bar_bebida_10': itemBarBebida10,
      'item_bar_comida_1': itemBarComida1,
      'item_bar_comida_2': itemBarComida2,
      'item_bar_comida_3': itemBarComida3,
      'item_bar_comida_4': itemBarComida4,
      'item_bar_comida_5': itemBarComida5,
      'item_bar_comida_6': itemBarComida6,
      'item_bar_comida_7': itemBarComida7,
      'item_bar_comida_8': itemBarComida8,
      'item_bar_comida_9': itemBarComida9,
      'item_bar_comida_10': itemBarComida10,
      'lista_presentes': listaPresentes,
      'documento': documento,
      'whatsapp': whatsapp,
      'email': email,
      'status': status,
    };
  }

  factory BirthdayReservationModel.fromJson(Map<String, dynamic> json) {
    // Debug para verificar o userId sendo recebido
    print(
        'DEBUG - JSON userId: ${json['user_id']} (tipo: ${json['user_id'].runtimeType})');

    // Conversão mais robusta do userId
    int parseUserId() {
      final userIdValue = json['user_id'];
      if (userIdValue == null) return 0;

      if (userIdValue is int) return userIdValue;
      if (userIdValue is double) return userIdValue.toInt();
      if (userIdValue is String) {
        final parsed = int.tryParse(userIdValue);
        return parsed ?? 0;
      }
      return 0;
    }

    final userId = parseUserId();
    print('DEBUG - userId convertido: $userId');

    // Função auxiliar para converter ID nullable de string ou int para int?
    int? parseIdNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return BirthdayReservationModel(
      id: parseIdNullable(json['id']),
      userId: userId,
      aniversarianteNome: json['aniversariante_nome'] ?? '',
      dataAniversario: DateTime.parse(json['data_aniversario']),
      quantidadeConvidados:
          (json['quantidade_convidados'] as num?)?.toInt() ?? 1,
      barSelecionado: json['id_casa_evento'],
      decoracaoTipo: json['decoracao_tipo'],
      painelPersonalizado: json['painel_personalizado'] == 1,
      painelTema: json['painel_tema'],
      painelFrase: json['painel_frase'],
      painelEstoqueImagemUrl: json['painel_estoque_imagem_url'],
      itemBarBebida1: json['item_bar_bebida_1'] ?? 0,
      itemBarBebida2: json['item_bar_bebida_2'] ?? 0,
      itemBarBebida3: json['item_bar_bebida_3'] ?? 0,
      itemBarBebida4: json['item_bar_bebida_4'] ?? 0,
      itemBarBebida5: json['item_bar_bebida_5'] ?? 0,
      itemBarBebida6: json['item_bar_bebida_6'] ?? 0,
      itemBarBebida7: json['item_bar_bebida_7'] ?? 0,
      itemBarBebida8: json['item_bar_bebida_8'] ?? 0,
      itemBarBebida9: json['item_bar_bebida_9'] ?? 0,
      itemBarBebida10: json['item_bar_bebida_10'] ?? 0,
      itemBarComida1: json['item_bar_comida_1'] ?? 0,
      itemBarComida2: json['item_bar_comida_2'] ?? 0,
      itemBarComida3: json['item_bar_comida_3'] ?? 0,
      itemBarComida4: json['item_bar_comida_4'] ?? 0,
      itemBarComida5: json['item_bar_comida_5'] ?? 0,
      itemBarComida6: json['item_bar_comida_6'] ?? 0,
      itemBarComida7: json['item_bar_comida_7'] ?? 0,
      itemBarComida8: json['item_bar_comida_8'] ?? 0,
      itemBarComida9: json['item_bar_comida_9'] ?? 0,
      itemBarComida10: json['item_bar_comida_10'] ?? 0,
      listaPresentes: _parseListaPresentes(json['lista_presentes']),
      documento: json['documento'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      status: json['status'],
    );
  }

  // Método auxiliar para parsear a lista de presentes
  static List<String> _parseListaPresentes(dynamic value) {
    if (value == null) return [];

    if (value is String) {
      try {
        // Se for uma string JSON, tenta fazer o parse
        final List<dynamic> parsed = jsonDecode(value);
        return parsed.map((item) => item.toString()).toList();
      } catch (e) {
        // Se falhar o parse, retorna lista vazia
        return [];
      }
    } else if (value is List) {
      // Se já for uma lista, converte para List<String>
      return value.map((item) => item.toString()).toList();
    }

    return [];
  }
}
