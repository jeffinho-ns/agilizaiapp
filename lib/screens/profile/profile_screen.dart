// lib/screens/profile/profile_screen.dart

import 'package:agilizaiapp/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/screens/profile/edit_profile_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/home/home_screen.dart';
import 'package:agilizaiapp/screens/main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    print('--- Iniciando busca do usuário na ProfileScreen ---');
    print('Token encontrado no storage (ProfileScreen): $token');

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage =
            'Token de autenticação ausente. Por favor, faça login novamente.';
        _isLoading = false;
      });
      // Opcional: Redirecionar para a tela de login se não houver token
      // Navigator.of(context).pushReplacementNamed('/login');
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

      print(
        'Buscando usuário na ProfileScreen... Status Code: ${response.statusCode}',
      );
      print(
        'Buscando usuário na ProfileScreen... Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        if (mounted) {
          print(
            'Sucesso! Atualizando o estado com os dados do usuário na ProfileScreen.',
          );
          final Map<String, dynamic> userData = json.decode(response.body);
          setState(() {
            _currentUser = User.fromJson(userData);
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print(
          'Erro de autenticação (401/403) na ProfileScreen. Token inválido ou expirado.',
        );
        setState(() {
          _errorMessage =
              'Sessão expirada ou inválida. Por favor, faça login novamente.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Falha ao carregar perfil: ${response.statusCode}. Tente novamente.';
          _isLoading = false;
        });
        print(
          'Erro API ao carregar perfil: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erro de conexão: Não foi possível conectar ao servidor. ($e)';
        _isLoading = false;
      });
      print('Exceção ao carregar perfil: $e');
    }
  }

  // Helper para formatar o endereço
  String _formatAddress(User user) {
    List<String> parts = [];
    if (user.endereco != null && user.endereco!.isNotEmpty) {
      parts.add(user.endereco!);
    }
    if (user.numero != null && user.numero!.isNotEmpty) parts.add(user.numero!);
    if (user.bairro != null && user.bairro!.isNotEmpty) parts.add(user.bairro!);
    if (user.cidade != null && user.cidade!.isNotEmpty) parts.add(user.cidade!);
    if (user.estado != null && user.estado!.isNotEmpty) parts.add(user.estado!);
    if (user.cep != null && user.cep!.isNotEmpty) parts.add(user.cep!);
    if (user.complemento != null && user.complemento!.isNotEmpty) {
      parts.add('Comp: ${user.complemento!}');
    }

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCurrentUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26422),
                ),
                child: const Text(
                  'Tentar Novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
        body: const Center(child: Text('Nenhum dado de usuário disponível.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil', // Traduzido de 'Profile'
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  )
                  .then(
                    (_) => _fetchCurrentUser(),
                  ); // Recarrega os dados ao retornar da edição
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _currentUser?.fotoPerfil != null &&
                          _currentUser!.fotoPerfil!.isNotEmpty
                      ? NetworkImage(
                          _currentUser!.fotoPerfil!,
                        ) // Se houver URL válida
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider<Object>, // Fallback para asset
                  onBackgroundImageError: (exception, stackTrace) {
                    print(
                      'Erro ao carregar imagem de perfil (NetworkImage): $exception',
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF26422),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser!.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações de Contato', // Traduzido de 'Contact Information'
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email, 'Email:', _currentUser!.email),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.phone,
                    'Telefone:', // Traduzido de 'Phone'
                    _currentUser!.telefone ?? 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalhes Pessoais', // Traduzido de 'Personal Details'
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Data de Nascimento:', // Traduzido de 'Date of Birth'
                    _currentUser!.dataNascimento ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person,
                    'Gênero:', // Traduzido de 'Gender'
                    _currentUser!.sexo ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.credit_card,
                    'CPF:',
                    _currentUser!.cpf ?? 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endereço', // Traduzido de 'Address'
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on,
                    'Endereço Completo:', // Traduzido de 'Full Address'
                    _formatAddress(_currentUser!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalhes da Conta', // Traduzido de 'Account Details'
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Função:', // Traduzido de 'Role'
                    _currentUser!.role ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.cloud,
                    'Provedor:', // Traduzido de 'Provider'
                    _currentUser!.provider ?? 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Text(
          '$title ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
