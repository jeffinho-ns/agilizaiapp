// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get countrySelectionTitle => 'Country Selection';

  @override
  String get findCountryHint => 'Find Country';

  @override
  String get saveButton => 'SAVE';

  @override
  String get hiWelcome => 'Hi Welcome 👋';

  @override
  String get loading => 'Loading...';

  @override
  String get currentLocation => 'Current location';

  @override
  String get notDefined => 'Not defined';

  @override
  String get findAmazingEvents => 'Find amazing events';

  @override
  String get popularEvents => 'Popular Events 🔥';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get noPopularEventsFound => 'No popular events found.';

  @override
  String get chooseEventType => 'Choose by Event Type ✨';

  @override
  String get uniqueEvents => 'Unique Events';

  @override
  String get weeklyEvents => 'Weekly Events';

  @override
  String noEventsInCategory(String categoryName) {
    return 'No events in category \"$categoryName\".';
  }

  @override
  String get eventDetailsButton => 'DETAILS';

  @override
  String get free => 'Free';

  @override
  String get notAvailable => 'N/A';

  @override
  String get failToLoadImage => 'Failed to load image';

  @override
  String get eventNameUndefined => 'Undefined Name';

  @override
  String get locationUndefined => 'Undefined Location';

  @override
  String get dateUndefined => 'Undefined Date';

  @override
  String get timeUndefined => 'Undefined Time';

  @override
  String get eventDescription => 'Description';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get specialCombo => 'Special Combo';

  @override
  String get comboNotAvailable => 'Combo not available';

  @override
  String get location => 'Location';

  @override
  String get mapUnavailable => 'Map unavailable or network failure';

  @override
  String get amountOfPeople => 'Amount of People';

  @override
  String get tablesNeeded => 'Tables Needed (1 table per 6 people)';

  @override
  String get tableSingular => 'table';

  @override
  String get tablesPlural => 'tables';

  @override
  String get confirmReservation => 'CONFIRM RESERVATION';

  @override
  String get membersJoined => 'Members joined';

  @override
  String get viewAllInvite => 'VIEW ALL / INVITE';

  @override
  String get eventOrganizer => 'Event Organiser';

  @override
  String get reservationFeatureToBeImplemented =>
      'Reservation feature to be implemented!';

  @override
  String get userNotIdentified => 'User not identified. Please log in again.';

  @override
  String get eventHouseInfoNotFound => 'Event house information not found.';

  @override
  String get failedToConfirmReservation => 'Failed to confirm reservation:';

  @override
  String get reservationConfirmed => 'Reservation confirmed!';

  @override
  String get onboardingExploreTitle => 'Explore Upcoming and Nearby Events';

  @override
  String get onboardingExploreSubtitle =>
      'In publishing and graphic design, Lorem is a placeholder text commonly';

  @override
  String get onboardingCreateFindTitle =>
      'Create and Find Events Easily in One Place';

  @override
  String get onboardingCreateFindSubtitle =>
      'In this app you can create any kind of events and you can join all events.';

  @override
  String get onboardingWatchFreeTitle => 'Watching Free Concerts with Friends';

  @override
  String get onboardingWatchFreeSubtitle =>
      'Find and booking concert tickets near your invite your friends to watch together';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';
}
