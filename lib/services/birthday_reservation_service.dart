// lib/services/birthday_reservation_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/models/birthday_reservation_model.dart';

class BirthdayReservationService {
  final String _baseUrl = 'https://vamos-comemorar-api.onrender.com/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado. Token JWT ausente ou vazio.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Método para criar reserva de aniversário com todos os dados
  Future<Map<String, dynamic>> createBirthdayReservation({
    required String aniversarianteNome,
    required String documento,
    required String whatsapp,
    required String email,
    required DateTime dataAniversario,
    required String barSelecionado,
    required int quantidadeConvidados,

    // Dados de decoração
    String? decoOpcao,
    double? decoPreco,
    String? decoDescricao,

    // Dados do painel
    String? painelTipo, // 'estoque' ou 'personalizado'
    String? painelImagem,
    String? painelTema,
    String? painelFrase,

    // Dados de bebidas
    Map<String, int>? bebidasSelecionadas,
    List<Map<String, dynamic>>? bebidasDetalhes,

    // Dados de comidas
    Map<String, int>? comidasSelecionadas,
    List<Map<String, dynamic>>? comidasDetalhes,

    // Dados de presentes
    List<Map<String, dynamic>>? presentesSelecionados,

    // Valor total
    double? valorTotal,
  }) async {
    try {
      // Preparar dados para envio usando o endpoint de reservas existente
      final Map<String, dynamic> reservationData = {
        'tipo_reserva': 'aniversario',
        'nome_lista': 'Reserva de Aniversário - $aniversarianteNome',
        'data_reserva': dataAniversario.toIso8601String(),
        'quantidade_convidados': quantidadeConvidados,
        'status': 'PENDENTE',

        // Dados específicos do aniversário (como dados extras)
        'dados_aniversario': {
          'aniversariante_nome': aniversarianteNome,
          'aniversariante_documento': documento,
          'aniversariante_whatsapp': whatsapp,
          'aniversariante_email': email,
          'bar_selecionado': barSelecionado,

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
        },
      };

      final response = await _dio.post(
        '$_baseUrl/reservas', // Usar endpoint existente
        options: await _getAuthHeaders(),
        data: reservationData,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            'Falha ao criar reserva de aniversário: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao criar reserva de aniversário: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao criar reserva de aniversário.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao criar reserva de aniversário: $e');
      throw Exception('Erro desconhecido ao criar reserva de aniversário');
    }
  }

  // Método para buscar reservas de aniversário do usuário
  Future<List<BirthdayReservation>> fetchBirthdayReservations() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reservas', // Usar endpoint existente
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservations = response.data;
        // Filtrar apenas reservas de aniversário
        final birthdayReservations = reservations.where((reservation) {
          return reservation['tipo_reserva'] == 'aniversario' ||
              reservation['nome_lista']?.toString().contains('Aniversário') ==
                  true;
        }).toList();

        return birthdayReservations
            .map((json) =>
                BirthdayReservation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Falha ao carregar reservas de aniversário: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar reservas de aniversário: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar reservas de aniversário.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar reservas de aniversário: $e');
      throw Exception('Erro desconhecido ao carregar reservas de aniversário');
    }
  }

  // Método para buscar detalhes de uma reserva de aniversário específica
  Future<BirthdayReservation> fetchBirthdayReservationDetails(
      int reservationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reservas/$reservationId', // Usar endpoint existente
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return BirthdayReservation.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw Exception(
            'Falha ao carregar detalhes da reserva de aniversário: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar detalhes da reserva de aniversário: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage =
          'Falha ao carregar detalhes da reserva de aniversário.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar detalhes da reserva de aniversário: $e');
      throw Exception(
          'Erro desconhecido ao carregar detalhes da reserva de aniversário');
    }
  }

  // Método para atualizar uma reserva de aniversário
  Future<BirthdayReservation> updateBirthdayReservation(
    int reservationId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/reservas/$reservationId', // Usar endpoint existente
        options: await _getAuthHeaders(),
        data: updateData,
      );

      if (response.statusCode == 200) {
        return BirthdayReservation.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw Exception(
            'Falha ao atualizar reserva de aniversário: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao atualizar reserva de aniversário: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao atualizar reserva de aniversário.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao atualizar reserva de aniversário: $e');
      throw Exception('Erro desconhecido ao atualizar reserva de aniversário');
    }
  }

  // Método para cancelar uma reserva de aniversário
  Future<void> cancelBirthdayReservation(int reservationId) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/reservas/$reservationId/reject', // Usar endpoint existente
        options: await _getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Falha ao cancelar reserva de aniversário: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao cancelar reserva de aniversário: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao cancelar reserva de aniversário.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao cancelar reserva de aniversário: $e');
      throw Exception('Erro desconhecido ao cancelar reserva de aniversário');
    }
  }
}
