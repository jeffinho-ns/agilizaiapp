// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get countrySelectionTitle => 'Sprachauswahl';

  @override
  String get findCountryHint => 'Sprache suchen';

  @override
  String get saveButton => 'SPEICHERN';

  @override
  String get hiWelcome => 'Hallo, Willkommen! 👋';

  @override
  String get loading => 'Lädt...';

  @override
  String get currentLocation => 'Aktueller Standort';

  @override
  String get notDefined => 'Nicht definiert';

  @override
  String get findAmazingEvents => 'Finde erstaunliche Events';

  @override
  String get popularEvents => 'Beliebte Events 🔥';

  @override
  String get viewAll => 'ALLE ANSEHEN';

  @override
  String get noPopularEventsFound => 'Keine beliebten Events gefunden.';

  @override
  String get chooseEventType => 'Wähle nach Event-Typ ✨';

  @override
  String get uniqueEvents => 'Einzigartige Events';

  @override
  String get weeklyEvents => 'Wöchentliche Events';

  @override
  String noEventsInCategory(String categoryName) {
    return 'Keine Events in der Kategorie \"$categoryName\".';
  }

  @override
  String get eventDetailsButton => 'DETAILS';

  @override
  String get free => 'Kostenlos';

  @override
  String get notAvailable => 'N/V';

  @override
  String get failToLoadImage => 'Fehler beim Laden des Bildes';

  @override
  String get eventNameUndefined => 'Undefinierter Name';

  @override
  String get locationUndefined => 'Undefinierter Standort';

  @override
  String get dateUndefined => 'Undefiniertes Datum';

  @override
  String get timeUndefined => 'Undefinierte Zeit';

  @override
  String get eventDescription => 'Beschreibung';

  @override
  String get noDescriptionAvailable => 'Keine Beschreibung verfügbar.';

  @override
  String get specialCombo => 'Spezielles Combo';

  @override
  String get comboNotAvailable => 'Combo nicht verfügbar';

  @override
  String get location => 'Standort';

  @override
  String get mapUnavailable => 'Karte nicht verfügbar oder Netzwerkfehler';

  @override
  String get amountOfPeople => 'Anzahl der Personen';

  @override
  String get tablesNeeded => 'Benötigte Tische (1 Tisch für 6 Personen)';

  @override
  String get tableSingular => 'Tisch';

  @override
  String get tablesPlural => 'Tische';

  @override
  String get confirmReservation => 'RESERVIERUNG BESTÄTIGEN';

  @override
  String get membersJoined => 'Beigetretene Mitglieder';

  @override
  String get viewAllInvite => 'ALLE ANSEHEN / EINLADEN';

  @override
  String get eventOrganizer => 'Event-Organisator';

  @override
  String get reservationFeatureToBeImplemented =>
      'Reservierungsfunktion wird implementiert!';

  @override
  String get userNotIdentified =>
      'Benutzer nicht identifiziert. Bitte melden Sie sich erneut an.';

  @override
  String get eventHouseInfoNotFound =>
      'Event-Haus-Informationen nicht gefunden.';

  @override
  String get failedToConfirmReservation =>
      'Fehler beim Bestätigen der Reservierung:';

  @override
  String get reservationConfirmed => 'Reservierung bestätigt!';

  @override
  String get onboardingExploreTitle =>
      'Entdecke Kommende und Nahegelegene Events';

  @override
  String get onboardingExploreSubtitle =>
      'In der Publikation und im Grafikdesign ist Lorem Ipsum ein häufig verwendeter Platzhaltertext.';

  @override
  String get onboardingCreateFindTitle =>
      'Erstelle und Finde Events Einfach an einem Ort';

  @override
  String get onboardingCreateFindSubtitle =>
      'In dieser App können Sie jede Art von Events erstellen und an allen Events teilnehmen.';

  @override
  String get onboardingWatchFreeTitle =>
      'Schauen Sie sich kostenlose Konzerte mit Freunden an';

  @override
  String get onboardingWatchFreeSubtitle =>
      'Finden und buchen Sie Konzertkarten in Ihrer Nähe und laden Sie Ihre Freunde ein, gemeinsam zuzuschauen.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingGetStarted => 'Loslegen';
}
