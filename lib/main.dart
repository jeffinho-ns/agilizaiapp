import 'package:agilizaiapp/screens/auth/signin_screen.dart';
import 'package:agilizaiapp/screens/auth/signup_screen.dart';
import 'package:agilizaiapp/screens/event/event_booked_screen.dart';
import 'package:agilizaiapp/screens/event_participation/event_participation_form_screen.dart';
import 'package:agilizaiapp/screens/home/home_screen.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:agilizaiapp/l10n/app_localizations.dart'; // Não utilizado
import 'package:agilizaiapp/screens/event/event_details_screen.dart';
import 'package:agilizaiapp/screens/main_screen.dart';
import 'package:agilizaiapp/screens/profile/profile_screen.dart';
// import 'package:agilizaiapp/screens/guests/promoter_event_selection_screen.dart'; // Não utilizado
import 'package:agilizaiapp/screens/guests/guest_list_management_screen.dart';
import 'package:agilizaiapp/screens/my_reservations_screen.dart';
import 'package:agilizaiapp/screens/reservation/reservation_details_screen.dart';
import 'package:agilizaiapp/screens/event/see_all_events_screen.dart';
import 'package:agilizaiapp/screens/event/upcoming_events_screen.dart';
import 'package:agilizaiapp/screens/search/search_screen.dart';
import 'package:agilizaiapp/screens/calendar/calendar_screen.dart';
import 'package:agilizaiapp/screens/bar/bar_details_screen.dart';
import 'package:agilizaiapp/screens/bar/bar_menu_screen.dart';
import 'package:agilizaiapp/screens/profile/edit_profile_screen.dart';
import 'package:agilizaiapp/screens/filter/filter_screen.dart';
import 'package:agilizaiapp/screens/interests/select_interest_screen.dart';
import 'package:agilizaiapp/screens/location/select_location_screen.dart';
import 'package:agilizaiapp/screens/country/country_selection_screen.dart';
import 'package:agilizaiapp/screens/onboarding/onboarding_screen.dart';
import 'package:agilizaiapp/screens/auth/reset_password_screen.dart';
import 'package:agilizaiapp/screens/auth/verification_screen.dart';
import 'package:agilizaiapp/screens/reservation/birthday_reservation_screen.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart'; // Importe UserProfileProvider
import 'package:provider/provider.dart'; // Importe Provider

// DEFINIÇÃO GLOBAL DA CHAVE DO NAVEGADOR
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          UserProfileProvider(), // Cria uma instância do seu provider
      child: const AgilizaAiApp(), // NOME DO SEU APP
    ),
  );
}

class AgilizaAiApp extends StatelessWidget {
  // NOME DO SEU APP
  const AgilizaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // A chave global do navegador
      title: 'Agilizai App', // Título do seu app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF26422)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        // Delegados para localização e internacionalização
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        // Locales suportados pelo seu app
        Locale('en'),
        Locale('pt'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Lógica para resolver o locale do usuário
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/', // Rota inicial do seu app
      routes: {
        // TODAS AS SUAS ROTAS NOMEADAS ESTÃO AQUI!
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/country-selection': (context) => const CountrySelectionScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        // '/verification': (context) => const VerificationScreen(), // Removido pois agora requer parâmetros
        '/main': (context) => MainScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/filter': (context) => const FilterScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/see-all-events': (context) => const SeeAllEventsScreen(),
        '/upcoming-events': (context) => const UpcomingEventsScreen(),
        '/select-interest': (context) => const SelectInterestScreen(),
        '/select-location': (context) => const SelectLocationScreen(),
        '/my-reservations': (context) => const MyReservationsScreen(),
        '/birthday-reservation': (context) => const BirthdayReservationScreen(),
      },
      onGenerateRoute: (settings) {
        // Rotas com argumentos
        switch (settings.name) {
          case '/event-details':
            final args = settings.arguments as Map<String, dynamic>?;
            final event = args?['event'] as Event?;
            if (event != null) {
              return MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Erro: Evento não fornecido.')),
              ),
            );

          case '/event-participation-form':
            final args = settings.arguments as Map<String, dynamic>?;
            final event = args?['event'] as Event?;
            if (event != null) {
              return MaterialPageRoute(
                builder: (context) =>
                    EventParticipationFormScreen(event: event),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                    child: Text(
                        'Erro: Evento não fornecido para formulário de participação.')),
              ),
            );

          case '/bar-details':
            final args = settings.arguments as Map<String, dynamic>?;
            final bar = args?['bar'] as Bar?;
            if (bar != null) {
              return MaterialPageRoute(
                builder: (context) => BarDetailsScreen(bar: bar),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Erro: Bar não fornecido.')),
              ),
            );

          case '/bar-menu':
            final args = settings.arguments as Map<String, dynamic>?;
            final barId = args?['barId'] as int?; // barId é int
            if (barId != null) {
              return MaterialPageRoute(
                builder: (context) =>
                    BarMenuScreen(barId: barId), // Passa barId
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Erro: ID do Bar não fornecido.')),
              ),
            );

          case '/guest-list-management':
            final args = settings.arguments as Map<String, dynamic>?;
            final event = args?['event'] as Event?;
            if (event != null) {
              return MaterialPageRoute(
                builder: (context) => GuestListManagementScreen(event: event),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                    child: Text(
                        'Erro: Evento não fornecido para gerenciamento de convidados.')),
              ),
            );

          case '/event-booked':
            final args = settings.arguments as Map<String, dynamic>?;
            final reservaId = args?['reservaId'] as int?;
            if (reservaId != null) {
              return MaterialPageRoute(
                builder: (context) => EventBookedScreen(reservaId: reservaId),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                    child: Text(
                        'Erro: ID da Reserva não fornecido para tela de reserva confirmada.')),
              ),
            );

          case '/verification':
            final args = settings.arguments as Map<String, dynamic>?;
            final telefone = args?['telefone'] as String?;
            final userData = args?['userData'] as Map<String, String>?;
            if (telefone != null && userData != null) {
              return MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  telefone: telefone,
                  userData: userData,
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                    child: Text('Erro: Dados de verificação não fornecidos.')),
              ),
            );

          case '/reservation-details':
            final args = settings.arguments as Map<String, dynamic>?;
            final reservationId = args?['reservationId'] as int?;
            if (reservationId != null) {
              return MaterialPageRoute(
                builder: (context) =>
                    ReservationDetailsScreen(reservationId: reservationId),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                    child: Text(
                        'Erro: ID da Reserva não fornecido para detalhes da reserva.')),
              ),
            );

          default:
            return null; // Rotas não encontradas
        }
      },
    );
  }
}
