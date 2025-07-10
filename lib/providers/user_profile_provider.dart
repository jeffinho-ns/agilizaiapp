// lib/providers/user_profile_provider.dart
import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false; // Adicionado para gerenciar o estado de carregamento
  String? _errorMessage; // Adicionado para gerenciar mensagens de erro

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading; // Getter para o estado de carregamento
  String? get errorMessage => _errorMessage; // Getter para mensagens de erro

  // Método para definir o usuário logado (pode ser chamado após login ou ao carregar o app)
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Método para atualizar o usuário (usado na tela de edição)
  // Nota: Este método atualiza apenas o estado LOCAL do Provider.
  // Para persistir, a EditProfileScreen chamará a API diretamente e depois
  // chamará fetchUserProfile para re-sincronizar este Provider com a API.
  void updateUser({
    String? name,
    String? email,
    String? fotoPerfil,
    String? aboutMe,
    String? dateOfBirth,
    String? location,
    List<String>? interestedEvents,
  }) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      fotoPerfil: fotoPerfil,
    );
    notifyListeners();
  }

  // --- NOVO MÉTODO: fetchUserProfile para buscar dados da API ---
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null; // Limpa qualquer erro anterior
    notifyListeners(); // Notifica os ouvintes que o carregamento começou

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      _errorMessage = 'Token de autenticação ausente. Faça login novamente.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        _currentUser = User.fromJson(userData);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _errorMessage = 'Sessão expirada ou inválida. Faça login novamente.';
        // Opcional: Você pode querer limpar o token do storage aqui se ele for inválido/expirado
        // await storage.delete(key: 'jwt_token');
      } else {
        _errorMessage = 'Falha ao carregar perfil: ${response.statusCode}.';
        print(
          'Erro API ao carregar perfil no Provider: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      print('Exceção ao carregar perfil no Provider: $e');
    } finally {
      _isLoading = false; // Finaliza o carregamento, sucesso ou falha
      notifyListeners(); // Notifica os ouvintes que o estado mudou
    }
  }

  // Removido o loadMockUser para priorizar a busca real da API.
  // Se ainda precisar de mock para testes específicos, pode mantê-lo,
  // mas certifique-se de que não entre em conflito com a lógica de busca real.
  /*
  void loadMockUser() {
    _currentUser = const User(
      id: 1,
      name: 'MD Rafi Islam',
      email: 'rafi.islam@example.com',
      fotoPerfil:
          'https://randomuser.me/api/portraits/men/75.jpg',
      aboutMe:
          'Pellentesque mattis scelerisque aliquam tincidunt lacus. Convallis aliquam tortor et tincidunt fringilla aliquet amet. Mauris tempus ultrices fermentum aliquet. Justo tortor amet placerat ornare. Gravida non cursus quis sed ullamcorper eu sed sit. Urna tincidunt morbi netus leo. Metus, scelerisque mauris quis risus leo...',
      followers: 1089,
      following: 275,
      eventsCount: 10,
      dateOfBirth: '18 February, 2001',
      location: 'Uttara, Dhaka, Bangladesh',
      interestedEvents: [
        'Design',
        'Art',
        'Sports',
        'Programing',
        'Food',
        'Music',
      ],
    );
    notifyListeners();
  }
  */
}
