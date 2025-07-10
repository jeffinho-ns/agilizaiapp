import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/onboarding/onboarding_screen.dart';
import 'package:agilizaiapp/screens/main_screen.dart'; // Importe a MainScreen
import 'package:agilizaiapp/main.dart'; // Importe para ter acesso ao mainScreenKey se ela estiver lá

// Certifique-se de que mainScreenKey é uma GlobalKey
// Se mainScreenKey não estiver definida globalmente ou em outro arquivo acessível,
// você precisará defini-la, por exemplo, no seu arquivo main.dart ou globalmente.
// Exemplo: final GlobalKey<NavigatorState> mainScreenKey = GlobalKey<NavigatorState>();
// Se for apenas uma key para o widget, o construtor da MainScreen já resolve.
// Por simplicidade e dado o seu código, vou assumir que mainScreenKey já existe e é acessível.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Variável para controlar a visibilidade do GIF
  bool _showGif = false;

  @override
  void initState() {
    super.initState();
    // Inicia o processo para exibir o GIF e checar o status de autenticação
    _initSplash();
  }

  Future<void> _initSplash() async {
    // Primeiro, exibe o GIF instantaneamente
    setState(() {
      _showGif = true;
    });

    // Aguarda um tempo mínimo para que o GIF seja visto (ex: 3 segundos para o GIF + 1 para o delay)
    // O ideal seria que o tempo fosse o da duração do GIF, mas para simplicidade, um valor fixo.
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Tempo de exibição do GIF

    // Agora, verifica o status de autenticação
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    // Após o tempo de exibição do GIF, faz o redirecionamento
    if (token != null) {
      // Se tem token, vai para a Home (MainScreen)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainScreen(
            key: mainScreenKey,
          ), // Garanta que mainScreenKey está definida
        ),
        (route) => false,
      );
    } else {
      // Se não tem token, vai para o Onboarding/Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco para a splash screen
      body: Center(
        child: _showGif
            ? Image.asset(
                'assets/images/logo.gif', // Caminho para o seu GIF
                gaplessPlayback: true, // Garante que o GIF não pisque no loop
              )
            : Container(), // Ou um widget vazio se o GIF não for para ser mostrado inicialmente
      ),
    );
  }
}
