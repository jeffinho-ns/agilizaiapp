// lib/services/reservation_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// =====> A LINHA QUE FALTAVA ESTÁ AQUI <=====
import 'package:agilizaiapp/models/reservation_model.dart';

class ReservationService {
  final String _baseUrl = 'https://vamos-comemorar-api.onrender.com/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('Usuário não autenticado.');
    }
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  Future<Map<String, dynamic>> createReservation(
      Map<String, dynamic> reservationData) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/reservas',
        data: reservationData,
        options: await _getAuthHeaders(),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Falha ao criar reserva: ${e.response?.data['message']}');
    }
  }

  /// Busca os detalhes completos de uma reserva e JÁ RETORNA O OBJETO PRONTO.
  Future<Reservation> getReservationDetails(int reservaId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reservas/$reservaId',
        options: await _getAuthHeaders(),
      );
      // Agora o Dart sabe o que é 'Reservation' por causa do import que adicionamos.
      return Reservation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Falha ao buscar detalhes da reserva: ${e.response?.data['message']}');
    }
  }

  /// Busca todas as reservas criadas por um usuário específico.
  Future<List<dynamic>> getMyReservations(int userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users/$userId/reservas',
        options: await _getAuthHeaders(),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          'Falha ao buscar minhas reservas: ${e.response?.data['message']}');
    }
  }

  /// Busca todas as reservas de um evento específico.
  Future<List<dynamic>> getReservationsForEvent(int eventId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/events/$eventId/reservas',
        options: await _getAuthHeaders(),
      );
      return response.data['reservas_associadas'];
    } on DioException catch (e) {
      throw Exception(
          'Falha ao buscar as listas do evento: ${e.response?.data['message']}');
    }
  }

  Future<void> deleteGuest(int guestId) async {
    try {
      await _dio.delete(
        '$_baseUrl/convidados/$guestId',
        options: await _getAuthHeaders(),
      );
    } on DioException catch (e) {
      throw Exception(
          'Falha ao deletar convidado: ${e.response?.data['message']}');
    }
  }

  Future<void> updateGuest(int guestId, String newName) async {
    try {
      await _dio.put(
        '$_baseUrl/convidados/$guestId',
        data: {'nome': newName},
        options: await _getAuthHeaders(),
      );
    } on DioException catch (e) {
      throw Exception(
          'Falha ao atualizar convidado: ${e.response?.data['message']}');
    }
  }
}
