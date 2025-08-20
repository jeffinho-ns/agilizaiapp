import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/onboarding/onboarding_screen.dart';
import 'package:agilizaiapp/screens/main_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showGif = false;
  final Completer<void> _gifCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    setState(() {
      _showGif = true;
    });

    // Tempo mínimo para a splash screen, que agora será a duração do GIF (5 segundos).
    final Future<void> gifAnimationDuration = Future.delayed(
      const Duration(seconds: 5),
    ); // Ajustado para 5 segundos

    // Aguarda tanto o carregamento do GIF quanto a duração total da animação.
    await Future.wait([
      _gifCompleter.future, // Aguarda o sinal de que o GIF carregou
      gifAnimationDuration, // Aguarda a duração total da animação do GIF
    ]);

    // Agora, verifica o status de autenticação e navega.
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainScreen(key: mainScreenKey)),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _showGif
            ? Image.asset(
                'assets/images/logo.gif',
                gaplessPlayback: true,
                frameBuilder: (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    if (!_gifCompleter.isCompleted) {
                      _gifCompleter.complete();
                    }
                  }
                  return child;
                },
              )
            : Container(),
      ),
    );
  }
}
