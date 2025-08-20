import 'package:flutter/material.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/screens/auth/signin_screen.dart'; // Added import for SignInScreen

// Modelo para cada item de interesse
class Interest {
  final String name;
  final String imagePath;
  bool isSelected;

  Interest({
    required this.name,
    required this.imagePath,
    this.isSelected = false,
  });
}

class SelectInterestScreen extends StatefulWidget {
  const SelectInterestScreen({super.key});

  @override
  State<SelectInterestScreen> createState() => _SelectInterestScreenState();
}

class _SelectInterestScreenState extends State<SelectInterestScreen> {
  // Lista de interesses musicais brasileiros
  final List<Interest> _interests = [
    Interest(name: 'Rock', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Pop', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'MPB', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Funk', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Pagode', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Sertanejo', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Eletrônica', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Samba', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Black', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'R&B', imagePath: 'assets/images/interest_music.png'),
  ];

  final AuthService _authService = AuthService();

  Future<void> _handleNext() async {
    // Conta quantos interesses foram selecionados
    final selectedCount =
        _interests.where((interest) => interest.isSelected).length;

    print('🎯 Interesses selecionados: $selectedCount');

    if (selectedCount < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecione pelo menos 3 estilos musicais"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      print('🔍 Buscando usuário atual...');

      // Busca o usuário atual do AuthService
      final currentUser = await _authService.getCurrentUser();

      if (currentUser != null) {
        print('✅ Usuário encontrado:');
        print('   ID: ${currentUser.id}');
        print('   Nome: ${currentUser.name}');
        print('   Email: ${currentUser.email}');

        // Atualiza o provider com o usuário atual
        final userProvider =
            Provider.of<UserProfileProvider>(context, listen: false);
        userProvider.setUser(currentUser);

        print('🔄 Atualizando provider e navegando para home...');

        // Navega para a tela de login após selecionar os interesses
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      } else {
        print('❌ Usuário não encontrado');
        // Se não conseguir recuperar o usuário, mostra erro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao recuperar dados do usuário"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Erro na tela de interesses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar minimalista apenas com o botão de voltar
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecione Seus 3 Estilos Musicais',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha os estilos que mais te interessam',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // A grade de interesses
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colunas
                  crossAxisSpacing: 20, // Espaço horizontal entre os cards
                  mainAxisSpacing: 20, // Espaço vertical entre os cards
                  childAspectRatio:
                      0.85, // Proporção do card (largura / altura)
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Lógica para selecionar/desselecionar
                        interest.isSelected = !interest.isSelected;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        // Borda muda de cor quando o item é selecionado
                        border: Border.all(
                          color: interest.isSelected
                              ? const Color(0xFFF26422)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(interest.imagePath, height: 60),
                          const SizedBox(height: 16),
                          Text(
                            interest.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botão Next
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF242A38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
