import 'app_localizations.dart';

/// Translations in ENGLISH
class AppLocalizationsEn extends AppLocalizations {
  // =====================================================
  // GENERAL
  // =====================================================
  @override
  String get appName => 'DiscoverNariño';
  
  @override
  String get yes => 'Yes';
  
  @override
  String get no => 'No';
  
  @override
  String get cancel => 'Cancel';
  
  @override
  String get accept => 'Accept';
  
  @override
  String get close => 'Close';
  
  @override
  String get save => 'Save';
  
  @override
  String get delete => 'Delete';
  
  @override
  String get edit => 'Edit';
  
  @override
  String get search => 'Search';
  
  @override
  String get loading => 'Loading';
  
  @override
  String get error => 'Error';
  
  @override
  String get success => 'Success';
  
  @override
  String get confirm => 'Confirm';
  
  @override
  String get send => 'Send';
  
  @override
  String get retry => 'Retry';
  
  @override
  String get understood => 'Understood';

  // =====================================================
  // AUTHENTICATION
  // =====================================================
  @override
  String get welcome => 'Welcome';
  
  @override
  String get discoverEvents => 'Discover amazing events in Nariño';
  
  @override
  String get email => 'Email';
  
  @override
  String get password => 'Password';
  
  @override
  String get confirmPassword => 'Confirm password';
  
  @override
  String get username => 'Username';
  
  @override
  String get forgotPassword => 'Forgot your password?';
  
  @override
  String get login => 'Log In';
  
  @override
  String get register => 'Sign Up';
  
  @override
  String get noAccount => "Don't have an account? ";
  
  @override
  String get alreadyHaveAccount => 'Already have an account? ';
  
  @override
  String get loginNow => 'Log in';
  
  @override
  String get registerNow => 'Sign up';
  
  @override
  String get createAccount => 'Create Account';
  
  @override
  String get joinApp => 'Join DiscoverNariño';
  
  @override
  String get accountType => 'Account type';
  
  @override
  String get user => 'User';
  
  @override
  String get organizer => 'Organizer';
  
  @override
  String get logout => 'Log Out';
  
  // Validations
  @override
  String get enterEmail => 'Enter your email';
  
  @override
  String get invalidEmail => 'Invalid email';
  
  @override
  String get enterPassword => 'Enter your password';
  
  @override
  String get passwordTooShort => 'Minimum 6 characters';
  
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  
  @override
  String get enterUsername => 'Enter your username';
  
  @override
  String get usernameTooShort => 'Minimum 3 characters';
  
  // Messages
  @override
  String get verificationRequired => 'Verification Required';
  
  @override
  String get verificationPending => 'Verification Pending';
  
  @override
  String get emailNotReceived => "Didn't receive the email?";
  
  @override
  String get resendEmail => 'Resend Email';
  
  @override
  String get checkInboxAndSpam => 'Check your inbox and spam folder.';
  
  @override
  String get accountExists => 'Account Exists';
  
  @override
  String get canLoginDirectly => 
      'You can log in directly or recover your password if you forgot it.';
  
  @override
  String get recoverPasswordIfForgot => 'or recover your password if you forgot it';
  
  @override
  String get goToLogin => 'Go to Login';
  
  @override
  String get registrationSuccess => 'Registration Successful!';
  
  @override
  String get accountCreatedSuccessfully => 
      'Your account has been created successfully.';
  
  @override
  String get verifyYourEmail => 'Verify your email';
  
  @override
  String verificationSentTo(String email) => 
      'We have sent a verification email to $email. Please verify your email before logging in.';
  
  @override
  String get verifyBeforeLogin => 'Please verify your email before logging in.';
  
  @override
  String get confirmIdentity => 'Confirm Identity';
  
  @override
  String get enterPasswordToResend => 
      'Please enter your password to resend the verification email.';
  
  @override
  String get recoverPassword => 'Recover Password';
  
  @override
  String get recoverPasswordInstructions => 
      'Enter your email address and we will send you instructions to reset your password.';
  
  @override
  String get changePassword => 'Change Password';
  
  @override
  String get currentPassword => 'Current password';
  
  @override
  String get newPassword => 'New password';
  
  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';
  
  @override
  String get minCharacters => 'Minimum 6 characters';
  
  @override
  String get fieldRequired => 'Required field';

  // =====================================================
  // HOME / EVENTS
  // =====================================================
  @override
  String helloUser(String username) => 'Hello, $username!';
  
  @override
  String get manageYourEvents => 'Manage your events';
  
  @override
  String get discoverAmazingEvents => 'Discover amazing events';
  
  @override
  String get notifications => 'Notifications';
  
  @override
  String get notificationsComingSoon => 'Notifications coming soon';
  
  @override
  String get searchEvents => 'Search events...';
  
  @override
  String get filtersComingSoon => 'Filters coming soon';
  
  @override
  String get featuredEvents => 'Featured Events';
  
  @override
  String get viewAll => 'View all';
  
  @override
  String get viewAllComingSoon => 'View all coming soon';
  
  @override
  String get noEventsAvailable => 'No events available';
  
  @override
  String get tapPlusToCreate => 'Tap the + button to create one';
  
  @override
  String get errorLoadingEvents => 'Error loading events';
  
  @override
  String get savedEvents => 'Saved Events';
  
  @override
  String get noSavedEvents => 'You have no saved events';
  
  @override
  String get saveEventsByTappingBookmark => 
      'Save events by tapping the bookmark icon';
  
  @override
  String get eventRemovedFromFavorites => 'Event removed from favorites';
  
  @override
  String get eventSavedToFavorites => 'Event saved to favorites';
  
  @override
  String get errorUpdatingFavorites => 'Error updating favorites';

  // =====================================================
  // EVENT CATEGORIES
  // =====================================================
  @override
  String get all => 'All';
  
  @override
  String get culture => 'Culture';
  
  @override
  String get music => 'Music';
  
  @override
  String get sports => 'Sports';
  
  @override
  String get gastronomy => 'Gastronomy';
  
  @override
  String get technology => 'Technology';
  
  @override
  String get education => 'Education';
  
  @override
  String get others => 'Others';

  // =====================================================
  // CREATE EVENT
  // =====================================================
  @override
  String get createEvent => 'Create Event';
  
  @override
  String get addEventImage => 'Add event image';
  
  @override
  String get eventTitle => 'Event title';
  
  @override
  String get enterEventTitle => 'Enter the event title';
  
  @override
  String get description => 'Description';
  
  @override
  String get enterDescription => 'Enter a description';
  
  @override
  String get date => 'Date';
  
  @override
  String get selectDate => 'Select';
  
  @override
  String get time => 'Time';
  
  @override
  String get selectTime => 'Select';
  
  @override
  String get searchEventPlace => 'Search event location';
  
  @override
  String get examplePlace => 'E.g: Nariño Park, Pasto';
  
  @override
  String get category => 'Category';
  
  
  @override
  String get freeEvent => 'Free event';
  
  @override
  String get priceInPesos => 'Price in pesos';
  
  @override
  String get enterPrice => 'Enter the price';
  
  @override
  String get privacy => 'Privacy';
  
  @override
  String get public => 'Public';
  
  @override
  String get private => 'Private';
  
  @override
  String get eventCreated => 'Event Created!';
  
  @override
  String get eventCreatedSuccessfully => 
      'Your event has been created successfully and is now visible to all users.';
  
  @override
  String get selectPlaceFromDropdown => 
      'Please select a location from the dropdown';
  
  @override
  String get mustSelectPlaceFromSuggestions => 
      'You must select a location from the suggestions';
  
  @override
  String get locationSelectedCorrectly => 'Location selected correctly';
  
  @override
  String get noPlacesFound => 
      'No places found. Try another name.';
  
  @override
  String get errorSearchingPlaces => 
      'Error searching for places. Check your connection.';
  
  @override
  String get checkYourConnection => 'Check your connection';
  
  @override
  String get errorSelectingImage => 'Error selecting image';

  // =====================================================
  // EVENT DETAILS
  // =====================================================
  @override
  String organizedBy(String organizer) => 'Organized by $organizer';
  
  @override
  String get howToGetThere => 'How to get there';
  
  @override
  String get free => 'Free';
  
  @override
  String price(double amount) => '\$${amount.toStringAsFixed(0)}';

  // =====================================================
  // MAP / DISCOVER
  // =====================================================
  @override
  String get gettingYourLocation => 'Getting your location...';
  
  @override
  String get activatingRealTimeTracking => 'Activating real-time tracking';
  
  @override
  String get couldNotGetLocation => 'Could not get your location';
  
  @override
  String get unknownError => 'Unknown error';
  
  @override
  String get continueWithoutLocation => 'Continue without my location';
  
  @override
  String get followingYourLocationRealTime => 
      'Following your location in real-time';
  
  @override
  String get eventsOnMap => 'Events on Map';
  
  @override
  String get locationUpdatedRealTime => 'Location updated in real-time';
  
  @override
  String eventsAvailable(int count) => '$count events available';
  
  @override
  String accuracy(String meters) => 'Accuracy: $meters';
  
  @override
  String get trackingDeactivated => 'Tracking deactivated';
  
  @override
  String get trackingActivated => 'Tracking activated';
  
  @override
  String get eventsUpdated => 'Events updated';
  
  @override
  String get calculatingBestRoute => 'Calculating the best route...';
  
  @override
  String routeCalculatedTo(String eventTitle) => 'Route calculated to $eventTitle';
  
  @override
  String get hide => 'Hide';
  
  @override
  String get showingStraightLine => 
      'Showing straight line (route service unavailable)';
  
  @override
  String get routeServiceUnavailable => 'Route service unavailable';
  
  @override
  String eventAtLocation(int count) => 
      '$count event${count > 1 ? 's' : ''} at this location';

  // =====================================================
  // PROFILE
  // =====================================================
  @override
  String get profile => 'Profile';
  
  @override
  String get account => 'Account';
  
  @override
  String get myEvents => 'My Events';
  
  @override
  String get noEventsCreatedYet => "You haven't created any events yet";
  
  @override
  String get active => 'Active';
  
  @override
  String get inactive => 'Inactive';
  
  @override
  String attendees(int count) => '$count attendees';
  
  @override
  String get deleteEvent => 'Delete Event';
  
  @override
  String get areYouSureDeleteEvent => 
      'Are you sure you want to delete this event?';
  
  @override
  String get eventDeletedSuccessfully => 'Event deleted successfully';
  
  @override
  String get errorDeletingEvent => 'Error deleting event';
  
  @override
  String get closingSession => 'Log Out';
  
  @override
  String get areYouSureLogout => 'Are you sure you want to log out?';

  // =====================================================
  // THEME
  // =====================================================
  @override
  String get lightMode => 'Light Mode';
  
  @override
  String get darkMode => 'Dark Mode';
  
  @override
  String get systemTheme => 'System Theme';
  
  @override
  String themeChangedTo(String theme) => 'Theme changed to: $theme';

  // =====================================================
  // NAVIGATION
  // =====================================================
  @override
  String get home => 'Home';
  
  @override
  String get saved => 'Saved';
  
  @override
  String get discover => 'Discover';

  // =====================================================
  // DAYS OF THE WEEK
  // =====================================================
  @override
  String get monday => 'Monday';
  
  @override
  String get tuesday => 'Tuesday';
  
  @override
  String get wednesday => 'Wednesday';
  
  @override
  String get thursday => 'Thursday';
  
  @override
  String get friday => 'Friday';
  
  @override
  String get saturday => 'Saturday';
  
  @override
  String get sunday => 'Sunday';

  @override
  String get priceLabel => 'Price';
}