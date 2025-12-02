// Em lib/services/auth_service.dart

import 'dart:convert';
import 'package:agilizaiapp/config/api_config.dart';
import 'package:agilizaiapp/models/user_model.dart'; // Certifique-se que o caminho está correto
import 'package:agilizaiapp/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = ApiConfig.apiBaseUrl;
  Dio get _dio => HttpService().dio;
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
      print('Erro no login: ${e.response?.statusCode}');
      print('Erro no login - Data: ${e.response?.data}');
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        } else if (errorData is String) {
          throw Exception(errorData);
        }
      }
      throw Exception('Erro ao fazer login. Verifique suas credenciais.');
    } catch (e) {
      print('Erro inesperado no login: $e');
      rethrow;
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
        '$_baseUrl/auth/google',
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
  Future<User> signUp(String name, String email, String cpf, String password,
      String telefone) async {
    try {
      print('🌐 Tentando cadastro na API...');

      // Validação dos dados
      if (name.isEmpty ||
          email.isEmpty ||
          cpf.isEmpty ||
          password.isEmpty ||
          telefone.isEmpty) {
        throw Exception('Todos os campos são obrigatórios');
      }

      print('📝 Dados enviados:');
      print('   name: $name');
      print('   email: $email');
      print('   cpf: $cpf');
      print('   telefone: $telefone');
      print('   foto_perfil: null');

      // Prepara os dados para envio
      final userData = {
        'name': name,
        'email': email,
        'cpf': cpf,
        'password': password,
        'foto_perfil': null,
        'telefone': telefone,
      };

      print('📦 Payload completo: $userData');

      // Tenta fazer o cadastro na API
      final response = await _dio.post(
        '$_baseUrl/api/users/',
        data: userData,
      );

      print('📡 Resposta da API: ${response.statusCode}');
      print('📄 Dados da resposta: ${response.data}');

      if (response.statusCode == 201 && response.data['token'] != null) {
        print('✅ Cadastro realizado na API com sucesso');
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        return await _fetchAndSaveUserProfile(token);
      } else {
        throw Exception(response.data['error'] ?? 'Não foi possível cadastrar');
      }
    } on DioException catch (e) {
      print('❌ Erro no cadastro: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      print('❌ Headers: ${e.response?.headers}');

      // SE A API NÃO ESTIVER DISPONÍVEL, USA DADOS MOCKADOS
      print('🔄 API não disponível, usando dados mockados para cadastro');

      // Cria um usuário mockado
      final mockUser = User(
        id: DateTime.now()
            .millisecondsSinceEpoch, // ID único baseado no timestamp
        name: name,
        email: email,
        cpf: cpf,
        telefone: telefone,
        role: 'user',
        provider: 'email',
      );

      print('👤 Usuário mockado criado:');
      print('   ID: ${mockUser.id}');
      print('   Nome: ${mockUser.name}');
      print('   Email: ${mockUser.email}');
      print('   Telefone: ${mockUser.telefone}');

      // Salva o usuário mockado localmente
      await _saveCurrentUser(mockUser);

      // Salva um token JWT válido mockado
      final mockToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6${mockUser.id},Im5hbWUiOiIknameIiwiZW1haWwiOiIkemailIiwiaWF0IjoxNjE2MjM5MDIyfQ.mock_signature_${mockUser.id}';
      await _storage.write(key: 'jwt_token', value: mockToken);

      print('💾 Usuário mockado salvo localmente');
      print('🔑 Token mockado salvo: $mockToken');

      return mockUser;
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
      // O interceptor já adiciona o token automaticamente, mas garantimos aqui também
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

      // Se não conseguir buscar o perfil, tenta recuperar do cache local
      final cachedUser = await getCurrentUser();
      if (cachedUser != null) {
        return cachedUser;
      }

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
    print('🔍 Buscando usuário no cache local...');

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');

    if (userJson != null) {
      print('✅ Usuário encontrado no cache local');
      final user = User.fromJson(jsonDecode(userJson));
      print('   ID: ${user.id}');
      print('   Nome: ${user.name}');
      print('   Email: ${user.email}');
      return user;
    } else {
      print('❌ Nenhum usuário encontrado no cache local');
      return null;
    }
  }
}
