import 'dart:convert';
import 'package:agilizaiapp/models/user_model.dart'; // Importe seu User model
import 'package:agilizaiapp/screens/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/auth/signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _accessController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  // Função para salvar o usuário completo no SharedPreferences
  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('currentUser', userJson);
    // LINHA CRÍTICA ADICIONADA: Salva o ID do usuário separadamente como uma String
    await prefs.setString('userId', user.id.toString());
    print(
      'DEBUG: Usuário completo e userId (${user.id}) salvos no SharedPreferences.',
    );
  }

  // Função para buscar o perfil do usuário com o token e salvar
  Future<bool> _fetchAndSaveUserProfile(String token) async {
    try {
      // ATENÇÃO: Verifique se a URL do perfil está correta!
      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Envia o token para autenticação
        },
      );
      print('DEBUG: Resposta da API de perfil: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        print('DEBUG: Dados do perfil recebidos: $userData');
        final user = User.fromJson(userData);
        await _saveCurrentUser(
          user,
        ); // Chama _saveCurrentUser que agora salva o userId também
        print('DEBUG: Usuário salvo com sucesso no SharedPreferences!');
        return true;
      } else {
        print('DEBUG: Falha ao buscar perfil. Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('DEBUG: Exceção ao buscar perfil: $e');
      return false;
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'access': _accessController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];

        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: token);

          // Chama a função para buscar e salvar o perfil, que agora salva o userId
          final profileFetched = await _fetchAndSaveUserProfile(token);

          if (profileFetched && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login realizado com sucesso!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainScreen()),
              (route) => false,
            );
          } else {
            throw Exception('Não foi possível carregar os dados do usuário.');
          }
        }
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['error'] ?? 'Credenciais inválidas');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _accessController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Sign in',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Give credential to sign in your account',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Campo de Email/CPF com controller
            TextField(
              controller: _accessController,
              decoration: InputDecoration(
                labelText: 'Type your email or CPF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Campo de Senha com controller
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Type your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.visibility_off_outlined),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Row do Remember Me e Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                      activeColor: const Color(0xFFF26422),
                    ),
                    const Text('Remember Me'),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFFF26422)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Botão de Sign In
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF242A38),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'or continue with',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(icon: Icons.facebook, onPressed: () {}),
                const SizedBox(width: 20),
                _socialButton(icon: Icons.g_mobiledata, onPressed: () {}),
                const SizedBox(width: 20),
                _socialButton(icon: Icons.apple, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color(0xFFF26422),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.black, size: 28),
    );
  }
}
