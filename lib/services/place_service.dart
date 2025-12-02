// lib/services/place_service.dart

import 'package:agilizaiapp/config/api_config.dart';
import 'package:agilizaiapp/models/place_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PlaceService {
  final String _baseUrl = ApiConfig.apiUrl;
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado. Token JWT ausente ou vazio.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Buscar todos os lugares/bares
  Future<List<Place>> fetchAllPlaces() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/places',
        // options: await _getAuthHeaders(), // Temporariamente comentado para teste
      );

      if (response.statusCode == 200) {
        final List<dynamic> placesData = response.data['data'];
        return placesData
            .map((json) => Place.fromJson(json))
            .where((place) => place.visible == 1 && place.status == 'active')
            .toList();
      } else {
        throw Exception(
            'Falha ao carregar lugares: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar lugares: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar lugares.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('error')) {
        errorMessage = e.response!.data['error'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar lugares: $e');
      throw Exception('Erro desconhecido ao carregar lugares');
    }
  }

  // Buscar um lugar específico por ID
  Future<Place> fetchPlaceById(int placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/places/$placeId',
        options: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return Place.fromJson(response.data['place']);
      } else {
        throw Exception(
            'Falha ao carregar lugar: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar lugar: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar lugar.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('error')) {
        errorMessage = e.response!.data['error'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar lugar: $e');
      throw Exception('Erro desconhecido ao carregar lugar');
    }
  }
}
