// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
// ✨ IMPORTAÇÃO CRUCIAL PARA LOCALIZAÇÃO
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProfileProvider()..fetchUserProfile(),
      child: const AgilizaAiApp(),
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
      // ✨ ADICIONE ESTAS PROPRIEDADES PARA SUPORTE A LOCALIZAÇÃO
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglês
        Locale('pt', 'BR'), // Português do Brasil
        // Adicione outros locais que seu aplicativo suporta
      ],
      locale: const Locale('pt', 'BR'), // Define o local padrão da aplicação
      // -------------------------------------------------------------
      home: const SplashScreen(),
    );
  }
}
