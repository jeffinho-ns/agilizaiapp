// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get countrySelectionTitle => 'Seleção de País';

  @override
  String get findCountryHint => 'Buscar País';

  @override
  String get saveButton => 'SALVAR';

  @override
  String get hiWelcome => 'Olá, Bem-vindo(a) 👋';

  @override
  String get loading => 'Carregando...';

  @override
  String get currentLocation => 'Localização atual';

  @override
  String get notDefined => 'Não definida';

  @override
  String get findAmazingEvents => 'Encontre eventos incríveis';

  @override
  String get popularEvents => 'Eventos Populares 🔥';

  @override
  String get viewAll => 'VER TODOS';

  @override
  String get noPopularEventsFound => 'Nenhum evento popular encontrado.';

  @override
  String get chooseEventType => 'Escolha por Tipo de Evento ✨';

  @override
  String get uniqueEvents => 'Eventos Únicos';

  @override
  String get weeklyEvents => 'Eventos Semanais';

  @override
  String noEventsInCategory(String categoryName) {
    return 'Nenhum evento na categoria \"$categoryName\".';
  }

  @override
  String get eventDetailsButton => 'DETALHES';

  @override
  String get free => 'Grátis';

  @override
  String get notAvailable => 'N/D';

  @override
  String get failToLoadImage => 'Falha ao carregar imagem';

  @override
  String get eventNameUndefined => 'Nome Indefinido';

  @override
  String get locationUndefined => 'Local Indefinido';

  @override
  String get dateUndefined => 'Data Indefinida';

  @override
  String get timeUndefined => 'Hora Indefinida';

  @override
  String get eventDescription => 'Descrição';

  @override
  String get noDescriptionAvailable => 'Sem descrição disponível.';

  @override
  String get specialCombo => 'Combo Especial';

  @override
  String get comboNotAvailable => 'Combo não disponível';

  @override
  String get location => 'Localização';

  @override
  String get mapUnavailable => 'Mapa indisponível ou falha de rede';

  @override
  String get amountOfPeople => 'Quantidade de Pessoas';

  @override
  String get tablesNeeded => 'Mesas Necessárias (1 mesa para 6 pessoas)';

  @override
  String get tableSingular => 'mesa';

  @override
  String get tablesPlural => 'mesas';

  @override
  String get confirmReservation => 'CONFIRMAR RESERVA';

  @override
  String get membersJoined => 'Membros confirmados';

  @override
  String get viewAllInvite => 'VER TODOS / CONVIDAR';

  @override
  String get eventOrganizer => 'Organizador do Evento';

  @override
  String get reservationFeatureToBeImplemented =>
      'Funcionalidade de Reserva a ser implementada!';

  @override
  String get userNotIdentified =>
      'Usuário não identificado. Faça login novamente.';

  @override
  String get eventHouseInfoNotFound =>
      'Informação da casa do evento não encontrada.';

  @override
  String get failedToConfirmReservation => 'Falha ao confirmar reserva:';

  @override
  String get reservationConfirmed => 'Reserva confirmada!';

  @override
  String get onboardingExploreTitle => 'Explore Eventos Próximos e Futuros';

  @override
  String get onboardingExploreSubtitle =>
      'No mundo da publicação e do design gráfico, Lorem Ipsum é um texto de preenchimento comumente usado.';

  @override
  String get onboardingCreateFindTitle =>
      'Crie e Encontre Eventos Facilmente em um Só Lugar';

  @override
  String get onboardingCreateFindSubtitle =>
      'Neste aplicativo você pode criar qualquer tipo de evento e participar de todos os eventos.';

  @override
  String get onboardingWatchFreeTitle => 'Assista a Shows Gratuitos com Amigos';

  @override
  String get onboardingWatchFreeSubtitle =>
      'Encontre e reserve ingressos para shows perto de você e convide seus amigos para assistirem juntos.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingGetStarted => 'Começar';
}
