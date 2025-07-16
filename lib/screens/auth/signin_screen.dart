import 'dart:convert';
import 'package:agilizaiapp/models/user_model.dart'; // Importe seu User model
import 'package:agilizaiapp/screens/auth/reset_password_screen.dart'; // CORRIGIDO: Removido '..'
import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/auth/signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart'; // Importe o pacote do Google Sign-In
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importe o pacote Font Awesome

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _accessController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading =
      false; // Controla o estado de carregamento para todos os logins

  // Instância do GoogleSignIn com escopos definidos
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email', // Solicita acesso ao endereço de e-mail do usuário
      // Adicione outros escopos aqui, se necessário, por exemplo:
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

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

  // Função para lidar com o login tradicional (e-mail/CPF e senha)
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

  // Nova função para lidar com o login via Google
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O usuário cancelou o login
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Token de ID do Google não encontrado.');
      }

      // Envia o ID Token do Google para o seu backend para autenticação
      final response = await http.post(
        Uri.parse(
            'https://vamos-comemorar-api.onrender.com/auth/google'), // Endpoint do seu backend
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'idToken': idToken, // Envia o ID Token do Google
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody[
            'token']; // Assume que o backend retorna um 'token' JWT

        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: token);

          // Busca e salva o perfil do usuário usando o token JWT da sua aplicação
          final profileFetched = await _fetchAndSaveUserProfile(token);

          if (profileFetched && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login com Google realizado com sucesso!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainScreen()),
              (route) => false,
            );
          } else {
            throw Exception(
                'Não foi possível carregar os dados do usuário após login com Google.');
          }
        } else {
          throw Exception(
              'Token JWT não recebido do backend após login com Google.');
        }
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(
            responseBody['error'] ?? 'Falha no login com Google no backend.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao fazer login com Google: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('DEBUG: Erro no login com Google: $e');
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
              'Entrar', // Traduzido
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Informe suas credenciais para acessar sua conta', // Traduzido
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Campo de Email/CPF com controller
            TextField(
              controller: _accessController,
              decoration: InputDecoration(
                labelText: 'Digite seu e-mail ou CPF', // Traduzido
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
                labelText: 'Digite sua senha', // Traduzido
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
                    const Text('Lembrar-me'), // Traduzido
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
                    'Esqueceu a senha?', // Traduzido
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
                        'ENTRAR', // Traduzido
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
                    'ou continue com', // Traduzido
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
                // Botão do Google
                _socialButton(
                  icon: FontAwesomeIcons.google,
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                ),
                const SizedBox(width: 20),
                // Botão do Facebook (ainda sem implementação)
                _socialButton(
                    icon: FontAwesomeIcons.facebook,
                    onPressed: _isLoading
                        ? null
                        : () {
                            // TODO: Implementar login com Facebook
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Login com Facebook ainda não implementado."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }),
                const SizedBox(width: 20),
                // Botão da Apple (ainda sem implementação)
                _socialButton(
                    icon: FontAwesomeIcons.apple,
                    onPressed: _isLoading
                        ? null
                        : () {
                            // TODO: Implementar login com Apple
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Login com Apple ainda não implementado."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Não tem uma conta?"), // Traduzido
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    'Cadastre-se', // Traduzido
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

  // Corrigido: onPressed agora aceita um VoidCallback? (pode ser nulo)
  Widget _socialButton({
    required IconData icon,
    VoidCallback? onPressed, // <--- AQUI ESTÁ A MUDANÇA CRÍTICA!
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
