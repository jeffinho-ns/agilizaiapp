// lib/services/event_service.dart

import 'package:agilizaiapp/models/event_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EventService {
  final String _baseUrl = 'https://vamos-comemorar-api.onrender.com/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('Usuário não autenticado.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Busca todos os eventos. Pode ser filtrado por tipo ('unico' ou 'semanal').
  Future<List<Event>> fetchAllEvents({String? tipo}) async {
    try {
      String url = '$_baseUrl/events';
      if (tipo != null) {
        url += '?tipo=$tipo';
      }

      final response = await _dio.get(url, options: await _getAuthHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> eventData = response.data;
        return eventData.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar eventos');
      }
    } on DioException catch (e) {
      print('Erro ao buscar eventos: ${e.response?.data}');
      throw Exception('Falha ao carregar eventos');
    }
  }
}
