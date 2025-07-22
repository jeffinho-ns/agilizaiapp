// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import necessário para initializeDateFormatting

void main() async {
  // Mantenha apenas UMA função main e torne-a assíncrona
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que o Flutter Binding esteja inicializado
  await initializeDateFormatting(
      'pt_BR', null); // ✨ Inicializa os dados para português do Brasil

  runApp(
    // Envolve toda a aplicação com o provedor de perfil
    ChangeNotifierProvider(
      create: (context) => UserProfileProvider()
        ..fetchUserProfile(), // Inicia a busca do perfil na criação
      child: const AgilizaAiApp(), // Sua aplicação principal
    ),
  );
}

class AgilizaAiApp extends StatefulWidget {
  const AgilizaAiApp({super.key});

  @override
  State<AgilizaAiApp> createState() => _AgilizaAiAppState();
}

class _AgilizaAiAppState extends State<AgilizaAiApp> {
  @override
  void initState() {
    super.initState();
    // A chamada a fetchUserProfile já foi movida para o 'create' do ChangeNotifierProvider,
    // então não é mais necessário chamá-la aqui.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agilizaí App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
