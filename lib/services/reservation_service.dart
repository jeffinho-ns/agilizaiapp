// lib/services/reservation_service.dart

import 'dart:convert';
import 'package:agilizaiapp/models/reservation_model.dart';
import 'package:agilizaiapp/models/birthday_reservation_model.dart'; // Adicionar import
import 'package:agilizaiapp/models/user_model.dart'; // Necessário para buscar usuário logado
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
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

  // Método para criar reserva (POST /api/reservas)
  Future<Map<String, dynamic>> createBirthdayReservation(
      Map<String, dynamic> data) async {
    try {
      // CORRIGIDO: Agora usamos o URL completo, combinando o _baseUrl com a rota
      final response = await _dio.post('$_baseUrl/birthday-reservations',
          options: await _getAuthHeaders(), // Restaurada autenticação
          data: data);
      return response.data;
    } on DioException catch (e) {
      print(
          'DioError ao criar reserva de aniversário: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createReservation(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/reservas',
        options: await _getAuthHeaders(),
        data: data,
      );
      print('Resposta de criação de reserva: Status ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print(
          'DioError ao criar reserva: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao criar reserva.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao criar reserva: $e');
      throw Exception('Erro desconhecido ao criar reserva');
    }
  }

  // Método para buscar apenas as reservas do usuário logado
  Future<List<Reservation>> fetchAllUserReservations() async {
    try {
      // Primeiro, obtém o usuário logado
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');

      if (userJson == null) {
        throw Exception('Usuário não logado');
      }

      final user = User.fromJson(jsonDecode(userJson));
      final userEmail = user.email;

      // Busca todas as reservas da API
      final response = await _dio.get(
        '$_baseUrl/reservas',
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservationData = response.data;
        final allReservations =
            reservationData.map((json) => Reservation.fromJson(json)).toList();

        // Filtra apenas as reservas do usuário logado usando email
        final userReservations = allReservations.where((reservation) {
          return reservation.userEmail == userEmail;
        }).toList();

        // Ordena as reservas: primeiro as que têm convidados com status PENDENTE, depois as demais
        userReservations.sort((a, b) {
          // Verifica se a reserva A tem convidados com status PENDENTE
          final aHasPendingGuests = a.convidados
                  ?.any((guest) => guest.status?.toUpperCase() == 'PENDENTE') ??
              false;

          // Verifica se a reserva B tem convidados com status PENDENTE
          final bHasPendingGuests = b.convidados
                  ?.any((guest) => guest.status?.toUpperCase() == 'PENDENTE') ??
              false;

          if (aHasPendingGuests && !bHasPendingGuests)
            return -1; // a vem primeiro
          if (!aHasPendingGuests && bHasPendingGuests)
            return 1; // b vem primeiro
          return 0; // mesma prioridade
        });

        return userReservations;
      } else {
        throw Exception(
            'Falha ao carregar reservas: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar reservas: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar reservas.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar reservas: $e');
      throw Exception('Erro desconhecido ao carregar reservas');
    }
  }

  // Método para buscar detalhes de uma única reserva por ID (GET /api/reservas/:id)
  Future<Reservation> fetchReservationDetails(int reservationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reservas/$reservationId',
        options: await _getAuthHeaders(),
      );

      print('Resposta de detalhes da Reserva: Status ${response.statusCode}');
      // print('Dados de detalhes da Reserva: ${response.data}'); // Descomente para ver o JSON

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
            'Falha ao carregar detalhes da reserva: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar detalhes da reserva: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar detalhes da reserva.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar detalhes da reserva: $e');
      throw Exception('Erro desconhecido ao carregar detalhes da reserva');
    }
  }

  // Método para aprovar reserva (PUT /api/reservas/update-status/:id)
  Future<void> approveReserve(int id) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/reservas/update-status/$id',
        options: await _getAuthHeaders(),
        data: {'status': 'Aprovado'},
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Falha ao aprovar a reserva: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao aprovar reserva: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Erro ao aprovar reserva.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao aprovar reserva: $e');
      throw Exception('Erro desconhecido ao aprovar reserva');
    }
  }

  // Método para reprovar reserva (PATCH /api/reservas/:id/reject)
  Future<void> rejectReserve(int id) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/reservas/${id}/reject',
        options: await _getAuthHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Falha ao reprovar a reserva: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao reprovar reserva: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Erro ao reprovar reserva.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao reprovar reserva: $e');
      throw Exception('Erro desconhecido ao reprovar reserva');
    }
  }

  // Método para buscar reservas de um evento específico (GET /api/events/:id/reservas)
  Future<List<Reservation>> fetchReservationsByEventId(int eventId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/events/$eventId/reservas',
        options: await _getAuthHeaders(),
      );

      print('Resposta de Reservas por Evento: Status ${response.statusCode}');
      // A API retorna um objeto { evento: {}, reservas_associadas: [] }
      if (response.statusCode == 200) {
        final List<dynamic> reservasData =
            response.data['reservas_associadas']; // <<-- PEGA A LISTA DO OBJETO
        return reservasData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception(
            'Falha ao carregar reservas por evento: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar reservas por evento: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar reservas por evento.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar reservas por evento: $e');
      throw Exception('Erro desconhecido ao carregar reservas por evento');
    }
  }

  // Método para buscar apenas as reservas de aniversário do usuário logado
  Future<List<BirthdayReservationModel>> fetchAllBirthdayReservations() async {
    try {
      // Primeiro, obtém o usuário logado
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');

      if (userJson == null) {
        throw Exception('Usuário não logado');
      }

      final user = User.fromJson(jsonDecode(userJson));
      final userId = user.id;
      final userEmail = user.email;

      print('DEBUG - Usuário logado ID: $userId, Email: $userEmail');

      // Busca todas as reservas de aniversário da API
      final response = await _dio.get(
        '$_baseUrl/birthday-reservations',
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservationData = response.data;
        print(
            'DEBUG - Total de reservas de aniversário encontradas: ${reservationData.length}');

        final allReservations = reservationData
            .map((json) => BirthdayReservationModel.fromJson(json))
            .toList();

        // Debug: imprimir todos os userIds das reservas
        for (int i = 0; i < allReservations.length; i++) {
          final reservation = allReservations[i];
          print(
              'DEBUG - Reserva $i: userId=${reservation.userId}, aniversariante=${reservation.aniversarianteNome}');
        }

        // Filtra apenas as reservas de aniversário do usuário logado
        // Verifica tanto por userId quanto por email (dupla verificação)
        final userReservations = allReservations.where((reservation) {
          bool matchesUserId = reservation.userId == userId;
          bool matchesEmail =
              reservation.email != null && reservation.email == userEmail;

          print(
              'DEBUG - Checando reserva: userId=${reservation.userId} == $userId? $matchesUserId, email=${reservation.email} == $userEmail? $matchesEmail');

          return matchesUserId || matchesEmail;
        }).toList();

        print(
            'DEBUG - Reservas filtradas para o usuário: ${userReservations.length}');

        // Ordena as reservas de aniversário: primeiro as pendentes, depois as demais
        userReservations.sort((a, b) {
          final aIsPending = a.status?.toUpperCase() == 'PENDENTE';
          final bIsPending = b.status?.toUpperCase() == 'PENDENTE';

          if (aIsPending && !bIsPending) return -1; // a vem primeiro
          if (!aIsPending && bIsPending) return 1; // b vem primeiro
          return 0; // mesma prioridade
        });

        return userReservations;
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

  // Método para buscar detalhes de uma reserva de aniversário específica (GET /api/birthday-reservations/:id)
  Future<BirthdayReservationModel> fetchBirthdayReservationDetails(
      int reservationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/birthday-reservations/$reservationId',
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return BirthdayReservationModel.fromJson(
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
}
