// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get countrySelectionTitle => 'Selección de Idioma';

  @override
  String get findCountryHint => 'Buscar Idioma';

  @override
  String get saveButton => 'GUARDAR';

  @override
  String get hiWelcome => '¡Hola, Bienvenido! 👋';

  @override
  String get loading => 'Cargando...';

  @override
  String get currentLocation => 'Ubicación actual';

  @override
  String get notDefined => 'No definido';

  @override
  String get findAmazingEvents => 'Encuentra eventos increíbles';

  @override
  String get popularEvents => 'Eventos Populares 🔥';

  @override
  String get viewAll => 'VER TODOS';

  @override
  String get noPopularEventsFound => 'No se encontraron eventos populares.';

  @override
  String get chooseEventType => 'Elige por Tipo de Evento ✨';

  @override
  String get uniqueEvents => 'Eventos Únicos';

  @override
  String get weeklyEvents => 'Eventos Semanales';

  @override
  String noEventsInCategory(String categoryName) {
    return 'No hay eventos en la categoría \"$categoryName\".';
  }

  @override
  String get eventDetailsButton => 'DETALLES';

  @override
  String get free => 'Gratis';

  @override
  String get notAvailable => 'N/D';

  @override
  String get failToLoadImage => 'Error al cargar imagen';

  @override
  String get eventNameUndefined => 'Nombre Indefinido';

  @override
  String get locationUndefined => 'Ubicación Indefinida';

  @override
  String get dateUndefined => 'Fecha Indefinida';

  @override
  String get timeUndefined => 'Hora Indefinida';

  @override
  String get eventDescription => 'Descripción';

  @override
  String get noDescriptionAvailable => 'Sin descripción disponible.';

  @override
  String get specialCombo => 'Combo Especial';

  @override
  String get comboNotAvailable => 'Combo no disponible';

  @override
  String get location => 'Ubicación';

  @override
  String get mapUnavailable => 'Mapa no disponible o fallo de red';

  @override
  String get amountOfPeople => 'Cantidad de Personas';

  @override
  String get tablesNeeded => 'Mesas Necesarias (1 mesa para 6 personas)';

  @override
  String get tableSingular => 'mesa';

  @override
  String get tablesPlural => 'mesas';

  @override
  String get confirmReservation => 'CONFIRMAR RESERVA';

  @override
  String get membersJoined => 'Miembros confirmados';

  @override
  String get viewAllInvite => 'VER TODOS / INVITAR';

  @override
  String get eventOrganizer => 'Organizador del Evento';

  @override
  String get reservationFeatureToBeImplemented =>
      '¡Funcionalidad de Reserva a implementar!';

  @override
  String get userNotIdentified =>
      'Usuario no identificado. Inicia sesión nuevamente.';

  @override
  String get eventHouseInfoNotFound =>
      'Información de la casa del evento no encontrada.';

  @override
  String get failedToConfirmReservation => 'Error al confirmar reserva:';

  @override
  String get reservationConfirmed => '¡Reserva confirmada!';

  @override
  String get onboardingExploreTitle => 'Explora Eventos Próximos y Futuros';

  @override
  String get onboardingExploreSubtitle =>
      'En el mundo de la publicación y el diseño gráfico, Lorem Ipsum es un texto de relleno comúnmente usado.';

  @override
  String get onboardingCreateFindTitle =>
      'Crea y Encuentra Eventos Fácilmente en un Solo Lugar';

  @override
  String get onboardingCreateFindSubtitle =>
      'En esta aplicación puedes crear cualquier tipo de evento y participar en todos los eventos.';

  @override
  String get onboardingWatchFreeTitle => 'Mira Conciertos Gratuitos con Amigos';

  @override
  String get onboardingWatchFreeSubtitle =>
      'Encuentra y reserva entradas para conciertos cerca de ti e invita a tus amigos a ver juntos.';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';
}
