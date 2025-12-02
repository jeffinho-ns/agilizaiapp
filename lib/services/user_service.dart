// lib/services/user_service.dart

import 'dart:convert';
import 'package:agilizaiapp/config/api_config.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = ApiConfig.usersEndpoint;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('Token JWT não encontrado. Usuário não autenticado.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Método para buscar o usuário logado (pode ser pelo ID ou um endpoint /me)
  Future<User> fetchCurrentUser() async {
    // Para simplificar, vou assumir que você tem um endpoint que retorna o usuário logado
    // ou que o ID do usuário pode ser extraído do token JWT.
    // Por enquanto, vamos buscar o ID do token e depois buscar o usuário.
    final userId = await _storage.read(
        key: 'user_id'); // Supondo que você armazena o user_id
    if (userId == null) {
      throw Exception('ID do usuário não encontrado no armazenamento seguro.');
    }

    return fetchUserById(int.parse(userId));
  }

  // Método para buscar um usuário pelo ID
  Future<User> fetchUserById(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(
                '$_baseUrl/$userId'), // Endpoint para buscar usuário por ID
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Token inválido ou expirado.');
      } else if (response.statusCode == 404) {
        throw Exception('Usuário não encontrado com ID: $userId');
      } else {
        throw Exception('Falha ao carregar usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar usuário pelo ID $userId: $e');
      rethrow;
    }
  }
}
