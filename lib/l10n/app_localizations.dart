import 'package:flutter/material.dart';
import 'app_localizations_es.dart';
import 'app_localizations_en.dart';

/// Clase abstracta que define todas las traducciones de la app
/// Esta clase es la base para las traducciones en español e inglés
abstract class AppLocalizations {
  // Método estático para obtener las traducciones según el contexto
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // =====================================================
  // GENERAL
  // =====================================================
  String get appName;
  String get yes;
  String get no;
  String get cancel;
  String get accept;
  String get close;
  String get save;
  String get delete;
  String get edit;
  String get search;
  String get loading;
  String get error;
  String get success;
  String get confirm;
  String get send;
  String get retry;
  String get understood;

  // =====================================================
  // AUTHENTICATION (Login/Register)
  // =====================================================
  String get welcome;
  String get discoverEvents;
  String get email;
  String get password;
  String get confirmPassword;
  String get username;
  String get forgotPassword;
  String get login;
  String get register;
  String get noAccount;
  String get alreadyHaveAccount;
  String get loginNow;
  String get registerNow;
  String get createAccount;
  String get joinApp;
  String get accountType;
  String get user;
  String get organizer;
  String get logout;
  
  // Validaciones
  String get enterEmail;
  String get invalidEmail;
  String get enterPassword;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get enterUsername;
  String get usernameTooShort;
  
  // Mensajes
  String get verificationRequired;
  String get verificationPending;
  String get emailNotReceived;
  String get resendEmail;
  String get checkInboxAndSpam;
  String get accountExists;
  String get canLoginDirectly;
  String get recoverPasswordIfForgot;
  String get goToLogin;
  String get registrationSuccess;
  String get accountCreatedSuccessfully;
  String get verifyYourEmail;
  String verificationSentTo(String email);
  String get verifyBeforeLogin;
  String get confirmIdentity;
  String get enterPasswordToResend;
  String get recoverPassword;
  String get recoverPasswordInstructions;
  String get changePassword;
  String get currentPassword;
  String get newPassword;
  String get passwordUpdatedSuccessfully;
  String get minCharacters;
  String get fieldRequired;

  // =====================================================
  // HOME / EVENTS
  // =====================================================
  String helloUser(String username);
  String get manageYourEvents;
  String get discoverAmazingEvents;
  String get notifications;
  String get notificationsComingSoon;
  String get searchEvents;
  String get filtersComingSoon;
  String get featuredEvents;
  String get viewAll;
  String get viewAllComingSoon;
  String get noEventsAvailable;
  String get tapPlusToCreate;
  String get errorLoadingEvents;
  String get savedEvents;
  String get noSavedEvents;
  String get saveEventsByTappingBookmark;
  String get eventRemovedFromFavorites;
  String get eventSavedToFavorites;
  String get errorUpdatingFavorites;

  // =====================================================
  // EVENT CATEGORIES
  // =====================================================
  String get all;
  String get culture;
  String get music;
  String get sports;
  String get gastronomy;
  String get technology;
  String get education;
  String get others;

  // =====================================================
  // CREATE EVENT
  // =====================================================
  String get createEvent;
  String get addEventImage;
  String get eventTitle;
  String get enterEventTitle;
  String get description;
  String get enterDescription;
  String get date;
  String get selectDate;
  String get time;
  String get selectTime;
  String get searchEventPlace;
  String get examplePlace;
  String get category;
  String get priceLabel;
  String get freeEvent;
  String get priceInPesos;
  String get enterPrice;
  String get privacy;
  String get public;
  String get private;
  String get eventCreated;
  String get eventCreatedSuccessfully;
  String get selectPlaceFromDropdown;
  String get mustSelectPlaceFromSuggestions;
  String get locationSelectedCorrectly;
  String get noPlacesFound;
  String get errorSearchingPlaces;
  String get checkYourConnection;
  String get errorSelectingImage;

  // =====================================================
  // EVENT DETAILS
  // =====================================================
  String organizedBy(String organizer);
  String get howToGetThere;
  String get free;
  String price(double amount);

  // =====================================================
  // MAP / DISCOVER
  // =====================================================
  String get gettingYourLocation;
  String get activatingRealTimeTracking;
  String get couldNotGetLocation;
  String get unknownError;
  String get continueWithoutLocation;
  String get followingYourLocationRealTime;
  String get eventsOnMap;
  String get locationUpdatedRealTime;
  String eventsAvailable(int count);
  String accuracy(String meters);
  String get trackingDeactivated;
  String get trackingActivated;
  String get eventsUpdated;
  String get calculatingBestRoute;
  String routeCalculatedTo(String eventTitle);
  String get hide;
  String get showingStraightLine;
  String get routeServiceUnavailable;
  String eventAtLocation(int count);

  // =====================================================
  // PROFILE
  // =====================================================
  String get profile;
  String get account;
  String get myEvents;
  String get noEventsCreatedYet;
  String get active;
  String get inactive;
  String attendees(int count);
  String get deleteEvent;
  String get areYouSureDeleteEvent;
  String get eventDeletedSuccessfully;
  String get errorDeletingEvent;
  String get closingSession;
  String get areYouSureLogout;

  // =====================================================
  // THEME
  // =====================================================
  String get lightMode;
  String get darkMode;
  String get systemTheme;
  String themeChangedTo(String theme);

  // =====================================================
  // NAVIGATION
  // =====================================================
  String get home;
  String get saved;
  String get discover;

  // =====================================================
  // DÍAS DE LA SEMANA (para formateo de fechas)
  // =====================================================
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;
}

/// Delegate que gestiona la carga de las traducciones
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'es':
      default:
        return AppLocalizationsEs();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}