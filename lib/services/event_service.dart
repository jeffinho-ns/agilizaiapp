// lib/services/event_service.dart

import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/rule_model.dart';
import 'package:agilizaiapp/models/guest_model.dart'; // <--- NOVO: Importe Guest para tipagem
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EventService {
  final String _baseUrl = 'https://vamos-comemorar-api.onrender.com/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      print('Erro de autenticação: Token JWT ausente ou vazio.');
      throw Exception('Usuário não autenticado. Token JWT ausente ou vazio.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Busca todos os eventos. Pode ser filtrado por tipo ('unico' ou 'semanal').
  Future<List<Event>> fetchAllEvents({String? tipo}) async {
    try {
      String url = '$_baseUrl/events';
      if (tipo != null) {
        url += '?tipo=$tipo';
      }

      print('Requisição de eventos para: $url');
      final response = await _dio.get(url, options: await _getAuthHeaders());
      print('Resposta da API de eventos: Status ${response.statusCode}');
      // print('Dados da resposta de eventos: ${response.data}'); // Descomente para ver o JSON completo

      if (response.statusCode == 200) {
        final List<dynamic> eventData = response.data;
        return eventData.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception(
            'Falha ao carregar eventos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar eventos: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar eventos.';
      if (e.response != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      } else if (e.response != null && e.response!.data is String) {
        errorMessage = e.response!.data;
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar eventos: $e');
      throw Exception('Erro desconhecido ao carregar eventos');
    }
  }

  /// Busca eventos onde o usuário logado é promoter
  Future<List<Event>> fetchPromoterEvents() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/events/promoter',
        options: await _getAuthHeaders(),
      );

      print(
          'Resposta da API de eventos do promoter: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> eventData = response.data;
        return eventData.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception(
            'Falha ao carregar eventos do promoter: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar eventos do promoter: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar eventos do promoter.';
      if (e.response != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      } else if (e.response != null && e.response!.data is String) {
        errorMessage = e.response!.data;
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar eventos do promoter: $e');
      throw Exception('Erro desconhecido ao carregar eventos do promoter');
    }
  }

  /// Verifica se o usuário logado é promoter de um evento específico
  Future<bool> isUserPromoterOfEvent(int eventId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/events/$eventId/promoter-check',
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return response.data['isPromoter'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro ao verificar se usuário é promoter: $e');
      return false;
    }
  }

  /// Busca as regras públicas e ativas para um evento específico.
  Future<List<EventRule>> fetchEventRules(int eventId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/events/$eventId/rules/public',
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rulesData = response.data;
        return rulesData.map((json) => EventRule.fromJson(json)).toList();
      } else {
        throw Exception(
            'Falha ao carregar as regras do evento: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar regras do evento: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar as regras do evento.';
      if (e.response != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar regras do evento: $e');
      throw Exception('Erro desconhecido ao carregar as regras do evento');
    }
  }

  // =======================================================================
  // ---- NOVO MÉTODO: Realizar Self Check-in de um Convidado por Localização ----
  Future<Map<String, dynamic>> selfCheckInGuest(
      int guestId, double latitude, double longitude) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/convidados/$guestId/self-check-in', // Endpoint no backend
        options: await _getAuthHeaders(),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Falha no self check-in: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError no self check-in: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha no self check-in.';
      if (e.response != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado no self check-in: $e');
      throw Exception('Erro desconhecido no self check-in');
    }
  }
}
