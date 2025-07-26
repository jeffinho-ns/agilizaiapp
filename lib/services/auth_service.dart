// Em lib/services/auth_service.dart

import 'dart:convert';
import 'package:agilizaiapp/models/user_model.dart'; // Certifique-se que o caminho está correto
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl =
      'https://vamos-comemorar-api.onrender.com'; // Sua URL base
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // --- MÉTODOS DE LOGIN ---

  /// Realiza o login tradicional e retorna o usuário logado.
  Future<User> signInWithEmail(String emailOrCpf, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/users/login',
        data: {'access': emailOrCpf, 'password': password},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);

        // Após salvar o token, busca e salva o perfil completo
        return await _fetchAndSaveUserProfile(token);
      } else {
        throw Exception(response.data['error'] ?? 'Credenciais inválidas');
      }
    } on DioException catch (e) {
      print('Erro no login: ${e.response?.data}');
      throw Exception(e.response?.data['error'] ?? 'Erro ao fazer login.');
    }
  }

  /// Realiza o login com Google e retorna o usuário logado.
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login com Google cancelado pelo usuário.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Token de ID do Google não encontrado.');
      }

      // Envia o idToken para o seu backend
      final response = await _dio.post(
        '$_baseUrl/auth/google', // Verifique se este é o endpoint correto no seu backend
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        return await _fetchAndSaveUserProfile(token);
      } else {
        throw Exception(
            response.data['error'] ?? 'Falha no login com Google no backend.');
      }
    } on DioException catch (e) {
      print('Erro no login com Google: ${e.response?.data}');
      throw Exception(
          e.response?.data['error'] ?? 'Erro ao fazer login com Google.');
    }
  }

  // --- MÉTODOS DE CADASTRO E LOGOUT ---

  /// Cadastra um novo usuário e já o loga.
  Future<User> signUp(
      String name, String email, String cpf, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/users/',
        data: {'name': name, 'email': email, 'cpf': cpf, 'password': password},
      );

      if (response.statusCode == 201 && response.data['token'] != null) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        return await _fetchAndSaveUserProfile(token);
      } else {
        throw Exception(response.data['error'] ?? 'Não foi possível cadastrar');
      }
    } on DioException catch (e) {
      print('Erro no cadastro: ${e.response?.data}');
      throw Exception(e.response?.data['error'] ?? 'Erro ao cadastrar.');
    }
  }

  /// Desloga o usuário, limpando os dados armazenados.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- MÉTODOS AUXILIARES ---

  /// Busca o perfil do usuário no endpoint /me e salva localmente.
  Future<User> _fetchAndSaveUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        await _saveCurrentUser(user); // Salva o usuário completo
        return user;
      } else {
        throw Exception('Não foi possível carregar os dados do usuário.');
      }
    } on DioException catch (e) {
      print('Erro ao buscar perfil: ${e.response?.data}');
      throw Exception('Falha ao buscar perfil do usuário.');
    }
  }

  /// Salva o objeto User completo e o userId separadamente para fácil acesso.
  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('currentUser', userJson);
    await prefs.setString('userId', user.id.toString());
  }

  /// Pega o usuário logado do SharedPreferences sem precisar de uma chamada de API.
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}
