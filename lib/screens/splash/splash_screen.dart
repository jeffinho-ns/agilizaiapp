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

    // Tempo mínimo para a splash screen (3 segundos)
    final Future<void> splashDuration = Future.delayed(
      const Duration(seconds: 3),
    );

    // Timeout para o GIF (máximo 2 segundos)
    final Future<void> gifTimeout = Future.delayed(
      const Duration(seconds: 2),
    ).then((_) {
      if (!_gifCompleter.isCompleted) {
        _gifCompleter.complete();
      }
    });

    // Aguarda o carregamento do GIF com timeout
    try {
      await Future.any([
        _gifCompleter.future,
        gifTimeout,
      ]);
    } catch (e) {
      print('Erro ao aguardar GIF: $e');
      if (!_gifCompleter.isCompleted) {
        _gifCompleter.complete();
      }
    }

    // Aguarda o tempo mínimo da splash
    await splashDuration;

    // Agora, verifica o status de autenticação e navega.
    if (mounted) {
      _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainScreen(key: mainScreenKey)),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      print('Erro ao verificar autenticação: $e');
      if (!mounted) return;
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
                errorBuilder: (context, error, stackTrace) {
                  // Se o GIF não carregar, mostra um placeholder e continua
                  print('Erro ao carregar GIF: $error');
                  if (!_gifCompleter.isCompleted) {
                    _gifCompleter.complete();
                  }
                  return const Icon(
                    Icons.restaurant_menu,
                    size: 100,
                    color: Color(0xFFF26422),
                  );
                },
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
            : const CircularProgressIndicator(
                color: Color(0xFFF26422),
              ),
      ),
    );
  }
}
