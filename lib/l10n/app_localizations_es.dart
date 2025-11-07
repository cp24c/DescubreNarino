import 'app_localizations.dart';

/// Traducciones en ESPAÑOL
class AppLocalizationsEs extends AppLocalizations {
  // =====================================================
  // GENERAL
  // =====================================================
  @override
  String get appName => 'DescubreNariño';
  
  @override
  String get yes => 'Sí';
  
  @override
  String get no => 'No';
  
  @override
  String get cancel => 'Cancelar';
  
  @override
  String get accept => 'Aceptar';
  
  @override
  String get close => 'Cerrar';
  
  @override
  String get save => 'Guardar';
  
  @override
  String get delete => 'Eliminar';
  
  @override
  String get edit => 'Editar';
  
  @override
  String get search => 'Buscar';
  
  @override
  String get loading => 'Cargando';
  
  @override
  String get error => 'Error';
  
  @override
  String get success => 'Éxito';
  
  @override
  String get confirm => 'Confirmar';
  
  @override
  String get send => 'Enviar';
  
  @override
  String get retry => 'Reintentar';
  
  @override
  String get understood => 'Entendido';

  // =====================================================
  // AUTHENTICATION
  // =====================================================
  @override
  String get welcome => 'Bienvenido';
  
  @override
  String get discoverEvents => 'Descubre eventos increíbles en Nariño';
  
  @override
  String get email => 'Correo electrónico';
  
  @override
  String get password => 'Contraseña';
  
  @override
  String get confirmPassword => 'Confirmar contraseña';
  
  @override
  String get username => 'Nombre de usuario';
  
  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';
  
  @override
  String get login => 'Iniciar Sesión';
  
  @override
  String get register => 'Registrarse';
  
  @override
  String get noAccount => '¿No tienes cuenta? ';
  
  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';
  
  @override
  String get loginNow => 'Inicia sesión';
  
  @override
  String get registerNow => 'Regístrate';
  
  @override
  String get createAccount => 'Crear Cuenta';
  
  @override
  String get joinApp => 'Únete a DescubreNariño';
  
  @override
  String get accountType => 'Tipo de cuenta';
  
  @override
  String get user => 'Usuario';
  
  @override
  String get organizer => 'Organizador';
  
  @override
  String get logout => 'Cerrar Sesión';
  
  // Validaciones
  @override
  String get enterEmail => 'Ingresa tu correo';
  
  @override
  String get invalidEmail => 'Correo inválido';
  
  @override
  String get enterPassword => 'Ingresa tu contraseña';
  
  @override
  String get passwordTooShort => 'Mínimo 6 caracteres';
  
  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
  
  @override
  String get enterUsername => 'Ingresa tu nombre de usuario';
  
  @override
  String get usernameTooShort => 'Mínimo 3 caracteres';
  
  // Mensajes
  @override
  String get verificationRequired => 'Verificación Requerida';
  
  @override
  String get verificationPending => 'Verificación Pendiente';
  
  @override
  String get emailNotReceived => '¿No recibiste el correo?';
  
  @override
  String get resendEmail => 'Reenviar Correo';
  
  @override
  String get checkInboxAndSpam => 'Revisa tu bandeja de entrada y spam.';
  
  @override
  String get accountExists => 'Cuenta Existente';
  
  @override
  String get canLoginDirectly => 'Puedes iniciar sesión directamente o recuperar tu contraseña si la olvidaste.';
  
  @override
  String get recoverPasswordIfForgot => 'o recuperar tu contraseña si la olvidaste';
  
  @override
  String get goToLogin => 'Ir a Login';
  
  @override
  String get registrationSuccess => '¡Registro Exitoso!';
  
  @override
  String get accountCreatedSuccessfully => 'Tu cuenta ha sido creada exitosamente.';
  
  @override
  String get verifyYourEmail => 'Verifica tu correo';
  
  @override
  String verificationSentTo(String email) => 
      'Te hemos enviado un correo de verificación a $email. Por favor, verifica tu correo antes de iniciar sesión.';
  
  @override
  String get verifyBeforeLogin => 'Por favor verifica tu correo antes de iniciar sesión.';
  
  @override
  String get confirmIdentity => 'Confirmar Identidad';
  
  @override
  String get enterPasswordToResend => 
      'Por favor ingresa tu contraseña para reenviar el correo de verificación.';
  
  @override
  String get recoverPassword => 'Recuperar Contraseña';
  
  @override
  String get recoverPasswordInstructions => 
      'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.';
  
  @override
  String get changePassword => 'Cambiar Contraseña';
  
  @override
  String get currentPassword => 'Contraseña actual';
  
  @override
  String get newPassword => 'Nueva contraseña';
  
  @override
  String get passwordUpdatedSuccessfully => 'Contraseña actualizada exitosamente';
  
  @override
  String get minCharacters => 'Mínimo 6 caracteres';
  
  @override
  String get fieldRequired => 'Campo requerido';

  // =====================================================
  // HOME / EVENTS
  // =====================================================
  @override
  String helloUser(String username) => '¡Hola, $username!';
  
  @override
  String get manageYourEvents => 'Gestiona tus eventos';
  
  @override
  String get discoverAmazingEvents => 'Descubre eventos increíbles';
  
  @override
  String get notifications => 'Notificaciones';
  
  @override
  String get notificationsComingSoon => 'Notificaciones próximamente';
  
  @override
  String get searchEvents => 'Buscar eventos...';
  
  @override
  String get filtersComingSoon => 'Filtros próximamente';
  
  @override
  String get featuredEvents => 'Eventos Destacados';
  
  @override
  String get viewAll => 'Ver todos';
  
  @override
  String get viewAllComingSoon => 'Ver todos próximamente';
  
  @override
  String get noEventsAvailable => 'No hay eventos disponibles';
  
  @override
  String get tapPlusToCreate => 'Toca el botón + para crear uno';
  
  @override
  String get errorLoadingEvents => 'Error al cargar eventos';
  
  @override
  String get savedEvents => 'Eventos Guardados';
  
  @override
  String get noSavedEvents => 'No tienes eventos guardados';
  
  @override
  String get saveEventsByTappingBookmark => 
      'Guarda eventos tocando el ícono de marcador';
  
  @override
  String get eventRemovedFromFavorites => 'Evento eliminado de favoritos';
  
  @override
  String get eventSavedToFavorites => 'Evento guardado en favoritos';
  
  @override
  String get errorUpdatingFavorites => 'Error al actualizar favoritos';

  // =====================================================
  // EVENT CATEGORIES
  // =====================================================
  @override
  String get all => 'Todos';
  
  @override
  String get culture => 'Cultura';
  
  @override
  String get music => 'Música';
  
  @override
  String get sports => 'Deportes';
  
  @override
  String get gastronomy => 'Gastronomía';
  
  @override
  String get technology => 'Tecnología';
  
  @override
  String get education => 'Educación';
  
  @override
  String get others => 'Otros';

  @override
  String get priceLabel => 'Precio';

  // =====================================================
  // CREATE EVENT
  // =====================================================
  @override
  String get createEvent => 'Crear Evento';
  
  @override
  String get addEventImage => 'Agregar imagen del evento';
  
  @override
  String get eventTitle => 'Título del evento';
  
  @override
  String get enterEventTitle => 'Ingresa el título del evento';
  
  @override
  String get description => 'Descripción';
  
  @override
  String get enterDescription => 'Ingresa una descripción';
  
  @override
  String get date => 'Fecha';
  
  @override
  String get selectDate => 'Seleccionar';
  
  @override
  String get time => 'Hora';
  
  @override
  String get selectTime => 'Seleccionar';
  
  @override
  String get searchEventPlace => 'Buscar lugar del evento';
  
  @override
  String get examplePlace => 'Ej: Parque Nariño, Pasto';
  
  @override
  String get category => 'Categoría';
  
  @override
  String price(double amount) => 'Precio: \$${amount.toStringAsFixed(0)}';
  
  @override
  String get freeEvent => 'Evento gratuito';
  
  @override
  String get priceInPesos => 'Precio en pesos';
  
  @override
  String get enterPrice => 'Ingresa el precio';
  
  @override
  String get privacy => 'Privacidad';
  
  @override
  String get public => 'Público';
  
  @override
  String get private => 'Privado';
  
  @override
  String get eventCreated => '¡Evento Creado!';
  
  @override
  String get eventCreatedSuccessfully => 
      'Tu evento ha sido creado exitosamente y ahora es visible para todos los usuarios.';
  
  @override
  String get selectPlaceFromDropdown => 
      'Por favor selecciona un lugar del desplegable';
  
  @override
  String get mustSelectPlaceFromSuggestions => 
      'Debes seleccionar un lugar de las sugerencias';
  
  @override
  String get locationSelectedCorrectly => 'Ubicación seleccionada correctamente';
  
  @override
  String get noPlacesFound => 
      'No se encontraron lugares. Intenta con otro nombre.';
  
  @override
  String get errorSearchingPlaces => 
      'Error al buscar lugares. Verifica tu conexión.';
  
  @override
  String get checkYourConnection => 'Verifica tu conexión';
  
  @override
  String get errorSelectingImage => 'Error al seleccionar imagen';

  // =====================================================
  // EVENT DETAILS
  // =====================================================
  @override
  String organizedBy(String organizer) => 'Organizado por $organizer';
  
  @override
  String get howToGetThere => 'Cómo llegar';
  
  @override
  String get free => 'Gratis';
  
  @override
  String priceFormatted(double amount) => '\$${amount.toStringAsFixed(0)}';

  // =====================================================
  // MAP / DISCOVER
  // =====================================================
  @override
  String get gettingYourLocation => 'Obteniendo tu ubicación...';
  
  @override
  String get activatingRealTimeTracking => 'Activando seguimiento en tiempo real';
  
  @override
  String get couldNotGetLocation => 'No se pudo obtener tu ubicación';
  
  @override
  String get unknownError => 'Error desconocido';
  
  @override
  String get continueWithoutLocation => 'Continuar sin mi ubicación';
  
  @override
  String get followingYourLocationRealTime => 
      'Siguiendo tu ubicación en tiempo real';
  
  @override
  String get eventsOnMap => 'Eventos en el Mapa';
  
  @override
  String get locationUpdatedRealTime => 'Ubicación actualizada en tiempo real';
  
  @override
  String eventsAvailable(int count) => '$count eventos disponibles';
  
  @override
  String accuracy(String meters) => 'Precisión: $meters';
  
  @override
  String get trackingDeactivated => 'Seguimiento desactivado';
  
  @override
  String get trackingActivated => 'Seguimiento activado';
  
  @override
  String get eventsUpdated => 'Eventos actualizados';
  
  @override
  String get calculatingBestRoute => 'Calculando la mejor ruta...';
  
  @override
  String routeCalculatedTo(String eventTitle) => 'Ruta calculada hacia $eventTitle';
  
  @override
  String get hide => 'Ocultar';
  
  @override
  String get showingStraightLine => 
      'Mostrando línea directa (servicio de rutas no disponible)';
  
  @override
  String get routeServiceUnavailable => 'Servicio de rutas no disponible';
  
  @override
  String eventAtLocation(int count) => 
      '$count evento${count > 1 ? 's' : ''} en esta ubicación';

  // =====================================================
  // PROFILE
  // =====================================================
  @override
  String get profile => 'Perfil';
  
  @override
  String get account => 'Cuenta';
  
  @override
  String get myEvents => 'Mis Eventos';
  
  @override
  String get noEventsCreatedYet => 'No has creado eventos aún';
  
  @override
  String get active => 'Activo';
  
  @override
  String get inactive => 'Inactivo';
  
  @override
  String attendees(int count) => '$count asistentes';
  
  @override
  String get deleteEvent => 'Eliminar Evento';
  
  @override
  String get areYouSureDeleteEvent => 
      '¿Estás seguro que deseas eliminar este evento?';
  
  @override
  String get eventDeletedSuccessfully => 'Evento eliminado exitosamente';
  
  @override
  String get errorDeletingEvent => 'Error al eliminar evento';
  
  @override
  String get closingSession => 'Cerrar Sesión';
  
  @override
  String get areYouSureLogout => '¿Estás seguro que deseas cerrar sesión?';

  // =====================================================
  // THEME
  // =====================================================
  @override
  String get lightMode => 'Modo Claro';
  
  @override
  String get darkMode => 'Modo Oscuro';
  
  @override
  String get systemTheme => 'Tema del Sistema';
  
  @override
  String themeChangedTo(String theme) => 'Tema cambiado a: $theme';

  // =====================================================
  // NAVIGATION
  // =====================================================
  @override
  String get home => 'Inicio';
  
  @override
  String get saved => 'Guardados';
  
  @override
  String get discover => 'Descubrir';

  // =====================================================
  // DÍAS DE LA SEMANA
  // =====================================================
  @override
  String get monday => 'lunes';
  
  @override
  String get tuesday => 'martes';
  
  @override
  String get wednesday => 'miércoles';
  
  @override
  String get thursday => 'jueves';
  
  @override
  String get friday => 'viernes';
  
  @override
  String get saturday => 'sábado';
  
  @override
  String get sunday => 'domingo';
}