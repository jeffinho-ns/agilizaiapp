import 'package:flutter/material.dart';
import 'package:agilizaiapp/services/phone_service.dart';
import 'package:agilizaiapp/screens/auth/verification_screen.dart';
import 'package:agilizaiapp/services/auth_service.dart';
import 'package:agilizaiapp/screens/interests/select_interest_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isVerifying = false;

  // Instancie o nosso novo serviço centralizado
  final AuthService _authService = AuthService();
  final PhoneService _phoneService = PhoneService();

  // Função _handleSignUp agora está limpa e chama o serviço
  Future<void> _handleSignUp() async {
    // Validações básicas
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, digite seu nome completo"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, digite seu email"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_cpfController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, digite seu CPF"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_telefoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, digite seu WhatsApp"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!_phoneService.isValidPhone(_telefoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, digite um número de telefone válido"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("As senhas não coincidem!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      print('🚀 Iniciando processo de cadastro...');

      // DADOS MOCKADOS PARA TESTE - REMOVER EM PRODUÇÃO
      final mockName = _nameController.text.isNotEmpty
          ? _nameController.text
          : "Usuário Teste";
      final mockEmail = _emailController.text.isNotEmpty
          ? _emailController.text
          : "teste@email.com";
      final mockCpf =
          _cpfController.text.isNotEmpty ? _cpfController.text : "12345678901";
      final mockTelefone = _telefoneController.text.isNotEmpty
          ? _telefoneController.text
          : "11999999999";
      final mockPassword = _passwordController.text.isNotEmpty
          ? _passwordController.text
          : "123456";

      print('📝 Dados para cadastro:');
      print('   Nome: $mockName');
      print('   Email: $mockEmail');
      print('   CPF: $mockCpf');
      print('   Telefone: $mockTelefone');

      // Envia código de verificação via telefone (mockado)
      await _phoneService.sendVerificationCode(mockTelefone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Código de verificação enviado para seu WhatsApp!"),
            backgroundColor: Colors.green,
          ),
        );

        print('🔄 Navegando para tela de verificação...');

        // Navega para a tela de verificação
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              telefone: mockTelefone,
              userData: {
                'name': mockName,
                'email': mockEmail,
                'cpf': mockCpf,
                'telefone': mockTelefone,
                'password': mockPassword,
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erro no cadastro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro ao enviar código: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A UI (código do build) continua exatamente a mesma.
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
              'Cadastro',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie sua conta e aproveite todos os serviços',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Digite seu nome completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Digite seu email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(
                labelText: 'Digite seu CPF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _telefoneController,
              decoration: InputDecoration(
                labelText: 'Digite seu telefone (WhatsApp)',
                hintText: '(11) 99999-9999',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.green),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Digite sua senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirme sua senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF242A38),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CADASTRAR',
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
                    'ou continue com',
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
                const Text("Já tem uma conta?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Entrar',
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
