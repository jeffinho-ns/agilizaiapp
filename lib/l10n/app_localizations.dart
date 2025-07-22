import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @countrySelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Country Selection'**
  String get countrySelectionTitle;

  /// No description provided for @findCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Find Country'**
  String get findCountryHint;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveButton;

  /// No description provided for @hiWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi Welcome 👋'**
  String get hiWelcome;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @notDefined.
  ///
  /// In en, this message translates to:
  /// **'Not defined'**
  String get notDefined;

  /// No description provided for @findAmazingEvents.
  ///
  /// In en, this message translates to:
  /// **'Find amazing events'**
  String get findAmazingEvents;

  /// No description provided for @popularEvents.
  ///
  /// In en, this message translates to:
  /// **'Popular Events 🔥'**
  String get popularEvents;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @noPopularEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No popular events found.'**
  String get noPopularEventsFound;

  /// No description provided for @chooseEventType.
  ///
  /// In en, this message translates to:
  /// **'Choose by Event Type ✨'**
  String get chooseEventType;

  /// No description provided for @uniqueEvents.
  ///
  /// In en, this message translates to:
  /// **'Unique Events'**
  String get uniqueEvents;

  /// No description provided for @weeklyEvents.
  ///
  /// In en, this message translates to:
  /// **'Weekly Events'**
  String get weeklyEvents;

  /// No description provided for @noEventsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No events in category \"{categoryName}\".'**
  String noEventsInCategory(String categoryName);

  /// No description provided for @eventDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get eventDetailsButton;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @failToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failToLoadImage;

  /// No description provided for @eventNameUndefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined Name'**
  String get eventNameUndefined;

  /// No description provided for @locationUndefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined Location'**
  String get locationUndefined;

  /// No description provided for @dateUndefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined Date'**
  String get dateUndefined;

  /// No description provided for @timeUndefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined Time'**
  String get timeUndefined;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescription;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @specialCombo.
  ///
  /// In en, this message translates to:
  /// **'Special Combo'**
  String get specialCombo;

  /// No description provided for @comboNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Combo not available'**
  String get comboNotAvailable;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @mapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map unavailable or network failure'**
  String get mapUnavailable;

  /// No description provided for @amountOfPeople.
  ///
  /// In en, this message translates to:
  /// **'Amount of People'**
  String get amountOfPeople;

  /// No description provided for @tablesNeeded.
  ///
  /// In en, this message translates to:
  /// **'Tables Needed (1 table per 6 people)'**
  String get tablesNeeded;

  /// No description provided for @tableSingular.
  ///
  /// In en, this message translates to:
  /// **'table'**
  String get tableSingular;

  /// No description provided for @tablesPlural.
  ///
  /// In en, this message translates to:
  /// **'tables'**
  String get tablesPlural;

  /// No description provided for @confirmReservation.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM RESERVATION'**
  String get confirmReservation;

  /// No description provided for @membersJoined.
  ///
  /// In en, this message translates to:
  /// **'Members joined'**
  String get membersJoined;

  /// No description provided for @viewAllInvite.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL / INVITE'**
  String get viewAllInvite;

  /// No description provided for @eventOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Event Organiser'**
  String get eventOrganizer;

  /// No description provided for @reservationFeatureToBeImplemented.
  ///
  /// In en, this message translates to:
  /// **'Reservation feature to be implemented!'**
  String get reservationFeatureToBeImplemented;

  /// No description provided for @userNotIdentified.
  ///
  /// In en, this message translates to:
  /// **'User not identified. Please log in again.'**
  String get userNotIdentified;

  /// No description provided for @eventHouseInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event house information not found.'**
  String get eventHouseInfoNotFound;

  /// No description provided for @failedToConfirmReservation.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm reservation:'**
  String get failedToConfirmReservation;

  /// No description provided for @reservationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed!'**
  String get reservationConfirmed;

  /// No description provided for @onboardingExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Upcoming and Nearby Events'**
  String get onboardingExploreTitle;

  /// No description provided for @onboardingExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'In publishing and graphic design, Lorem is a placeholder text commonly'**
  String get onboardingExploreSubtitle;

  /// No description provided for @onboardingCreateFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Create and Find Events Easily in One Place'**
  String get onboardingCreateFindTitle;

  /// No description provided for @onboardingCreateFindSubtitle.
  ///
  /// In en, this message translates to:
  /// **'In this app you can create any kind of events and you can join all events.'**
  String get onboardingCreateFindSubtitle;

  /// No description provided for @onboardingWatchFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Watching Free Concerts with Friends'**
  String get onboardingWatchFreeTitle;

  /// No description provided for @onboardingWatchFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find and booking concert tickets near your invite your friends to watch together'**
  String get onboardingWatchFreeSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
