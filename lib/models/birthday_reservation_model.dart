// lib/models/birthday_reservation_model.dart

class BirthdayReservationModel {
  final int? id;
  final int userId;
  final String aniversarianteNome;
  final DateTime dataAniversario;
  final int quantidadeConvidados;
  final String? barSelecionado;
  final String decoracaoTipo;
  final bool painelPersonalizado;
  final String? painelTema;
  final String? painelFrase;
  final String? painelEstoqueImagemUrl;
  final int bebidaBaldeBudweiser;
  final int bebidaBaldeCorona;
  final int bebidaBaldeHeineken;
  final int bebidaComboGin142;
  final int bebidaLicorRufus;

  BirthdayReservationModel({
    this.id,
    required this.userId,
    required this.aniversarianteNome,
    required this.dataAniversario,
    required this.quantidadeConvidados,
    this.barSelecionado,
    required this.decoracaoTipo,
    required this.painelPersonalizado,
    this.painelTema,
    this.painelFrase,
    this.painelEstoqueImagemUrl,
    this.bebidaBaldeBudweiser = 0,
    this.bebidaBaldeCorona = 0,
    this.bebidaBaldeHeineken = 0,
    this.bebidaComboGin142 = 0,
    this.bebidaLicorRufus = 0,
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
      'bebida_balde_budweiser': bebidaBaldeBudweiser,
      'bebida_balde_corona': bebidaBaldeCorona,
      'bebida_balde_heineken': bebidaBaldeHeineken,
      'bebida_combo_gin_142': bebidaComboGin142,
      'bebida_licor_rufus': bebidaLicorRufus,
    };
  }

  factory BirthdayReservationModel.fromJson(Map<String, dynamic> json) {
    return BirthdayReservationModel(
      id: json['id'],
      userId: json['user_id'],
      aniversarianteNome: json['aniversariante_nome'],
      dataAniversario: DateTime.parse(json['data_aniversario']),
      quantidadeConvidados: json['quantidade_convidados'],
      barSelecionado: json['id_casa_evento'],
      decoracaoTipo: json['decoracao_tipo'],
      painelPersonalizado: json['painel_personalizado'] == 1,
      painelTema: json['painel_tema'],
      painelFrase: json['painel_frase'],
      painelEstoqueImagemUrl: json['painel_estoque_imagem_url'],
      bebidaBaldeBudweiser: json['bebida_balde_budweiser'] ?? 0,
      bebidaBaldeCorona: json['bebida_balde_corona'] ?? 0,
      bebidaBaldeHeineken: json['bebida_balde_heineken'] ?? 0,
      bebidaComboGin142: json['bebida_combo_gin_142'] ?? 0,
      bebidaLicorRufus: json['bebida_licor_rufus'] ?? 0,
    );
  }
}
