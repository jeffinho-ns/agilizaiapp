import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
    Locale('es'),
    Locale('de')
  ];

  /// No description provided for @countrySelectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seleção de País'**
  String get countrySelectionTitle;

  /// No description provided for @findCountryHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar País'**
  String get findCountryHint;

  /// No description provided for @saveButton.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get saveButton;

  /// No description provided for @hiWelcome.
  ///
  /// In pt, this message translates to:
  /// **'Olá, Bem-vindo(a) 👋'**
  String get hiWelcome;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @currentLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização atual'**
  String get currentLocation;

  /// No description provided for @notDefined.
  ///
  /// In pt, this message translates to:
  /// **'Não definida'**
  String get notDefined;

  /// No description provided for @findAmazingEvents.
  ///
  /// In pt, this message translates to:
  /// **'Encontre eventos incríveis'**
  String get findAmazingEvents;

  /// No description provided for @popularEvents.
  ///
  /// In pt, this message translates to:
  /// **'Eventos Populares 🔥'**
  String get popularEvents;

  /// No description provided for @viewAll.
  ///
  /// In pt, this message translates to:
  /// **'VER TODOS'**
  String get viewAll;

  /// No description provided for @noPopularEventsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento popular encontrado.'**
  String get noPopularEventsFound;

  /// No description provided for @chooseEventType.
  ///
  /// In pt, this message translates to:
  /// **'Escolha por Tipo de Evento ✨'**
  String get chooseEventType;

  /// No description provided for @uniqueEvents.
  ///
  /// In pt, this message translates to:
  /// **'Eventos Únicos'**
  String get uniqueEvents;

  /// No description provided for @weeklyEvents.
  ///
  /// In pt, this message translates to:
  /// **'Eventos Semanais'**
  String get weeklyEvents;

  /// No description provided for @noEventsInCategory.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento na categoria \"{categoryName}\".'**
  String noEventsInCategory(String categoryName);

  /// No description provided for @eventDetailsButton.
  ///
  /// In pt, this message translates to:
  /// **'DETALHES'**
  String get eventDetailsButton;

  /// No description provided for @free.
  ///
  /// In pt, this message translates to:
  /// **'Grátis'**
  String get free;

  /// No description provided for @notAvailable.
  ///
  /// In pt, this message translates to:
  /// **'N/D'**
  String get notAvailable;

  /// No description provided for @failToLoadImage.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar imagem'**
  String get failToLoadImage;

  /// No description provided for @eventNameUndefined.
  ///
  /// In pt, this message translates to:
  /// **'Nome Indefinido'**
  String get eventNameUndefined;

  /// No description provided for @locationUndefined.
  ///
  /// In pt, this message translates to:
  /// **'Local Indefinido'**
  String get locationUndefined;

  /// No description provided for @dateUndefined.
  ///
  /// In pt, this message translates to:
  /// **'Data Indefinida'**
  String get dateUndefined;

  /// No description provided for @timeUndefined.
  ///
  /// In pt, this message translates to:
  /// **'Hora Indefinida'**
  String get timeUndefined;

  /// No description provided for @eventDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get eventDescription;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Sem descrição disponível.'**
  String get noDescriptionAvailable;

  /// No description provided for @specialCombo.
  ///
  /// In pt, this message translates to:
  /// **'Combo Especial'**
  String get specialCombo;

  /// No description provided for @comboNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Combo não disponível'**
  String get comboNotAvailable;

  /// No description provided for @location.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get location;

  /// No description provided for @mapUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Mapa indisponível ou falha de rede'**
  String get mapUnavailable;

  /// No description provided for @amountOfPeople.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade de Pessoas'**
  String get amountOfPeople;

  /// No description provided for @tablesNeeded.
  ///
  /// In pt, this message translates to:
  /// **'Mesas Necessárias (1 mesa para 6 pessoas)'**
  String get tablesNeeded;

  /// No description provided for @tableSingular.
  ///
  /// In pt, this message translates to:
  /// **'mesa'**
  String get tableSingular;

  /// No description provided for @tablesPlural.
  ///
  /// In pt, this message translates to:
  /// **'mesas'**
  String get tablesPlural;

  /// No description provided for @confirmReservation.
  ///
  /// In pt, this message translates to:
  /// **'CONFIRMAR RESERVA'**
  String get confirmReservation;

  /// No description provided for @membersJoined.
  ///
  /// In pt, this message translates to:
  /// **'Membros confirmados'**
  String get membersJoined;

  /// No description provided for @viewAllInvite.
  ///
  /// In pt, this message translates to:
  /// **'VER TODOS / CONVIDAR'**
  String get viewAllInvite;

  /// No description provided for @eventOrganizer.
  ///
  /// In pt, this message translates to:
  /// **'Organizador do Evento'**
  String get eventOrganizer;

  /// No description provided for @reservationFeatureToBeImplemented.
  ///
  /// In pt, this message translates to:
  /// **'Funcionalidade de Reserva a ser implementada!'**
  String get reservationFeatureToBeImplemented;

  /// No description provided for @userNotIdentified.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não identificado. Faça login novamente.'**
  String get userNotIdentified;

  /// No description provided for @eventHouseInfoNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Informação da casa do evento não encontrada.'**
  String get eventHouseInfoNotFound;

  /// No description provided for @failedToConfirmReservation.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao confirmar reserva:'**
  String get failedToConfirmReservation;

  /// No description provided for @reservationConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Reserva confirmada!'**
  String get reservationConfirmed;

  /// No description provided for @onboardingExploreTitle.
  ///
  /// In pt, this message translates to:
  /// **'Explore Eventos Próximos e Futuros'**
  String get onboardingExploreTitle;

  /// No description provided for @onboardingExploreSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'No mundo da publicação e do design gráfico, Lorem Ipsum é um texto de preenchimento comumente usado.'**
  String get onboardingExploreSubtitle;

  /// No description provided for @onboardingCreateFindTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie e Encontre Eventos Facilmente em um Só Lugar'**
  String get onboardingCreateFindTitle;

  /// No description provided for @onboardingCreateFindSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Neste aplicativo você pode criar qualquer tipo de evento e participar de todos os eventos.'**
  String get onboardingCreateFindSubtitle;

  /// No description provided for @onboardingWatchFreeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Assista a Shows Gratuitos com Amigos'**
  String get onboardingWatchFreeTitle;

  /// No description provided for @onboardingWatchFreeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Encontre e reserve ingressos para shows perto de você e convide seus amigos para assistirem juntos.'**
  String get onboardingWatchFreeSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onboardingGetStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
