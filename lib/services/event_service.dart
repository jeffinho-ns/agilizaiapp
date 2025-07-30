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

      print(
          'Resposta do Self Check-in: Status ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>; // Sucesso
      } else {
        // Dio já lança DioException para !200, mas esta é uma verificação extra
        throw Exception(
            'Falha no self check-in: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError no self check-in: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao realizar check-in por localização.';
      if (e.response != null) {
        if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data is String && e.response!.data.isNotEmpty) {
          errorMessage = e.response!.data;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado no self check-in: $e');
      throw Exception('Erro desconhecido ao realizar check-in por localização');
    }
  }
  // =======================================================================
}
