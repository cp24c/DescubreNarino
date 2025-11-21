import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/event_model.dart';

/// Servicio para gestionar notificaciones locales
///
/// Funcionalidades:
/// - Notificaciones recordatorias de eventos guardados
/// - 3 tipos de recordatorios: 1 día antes, 2 horas antes, al momento
/// - Cancelación automática al desmarcar eventos
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Singleton global para acceso desde cualquier parte
  static NotificationService get instance => _instance;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('✅ NotificationService ya estaba inicializado');
      return;
    }

    debugPrint('🔧 Inicializando NotificationService...');

    // Inicializar zonas horarias
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    // Configuración Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('✅ NotificationService inicializado correctamente');
  }

  /// Maneja el tap en la notificación
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navegar al detalle del evento usando el payload (eventId)
    debugPrint('📱 Notificación tocada: ${response.payload}');
  }

  /// Solicita permisos de notificación (especialmente para iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Android 13+ también requiere permisos
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final granted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? true;
  }

  /// Programa todas las notificaciones para un evento guardado
  ///
  /// Crea 3 notificaciones:
  /// - 1 día antes a las 9:00 AM
  /// - 2 horas antes del evento
  /// - Al momento del evento
  Future<void> scheduleEventNotifications(EventModel event) async {
    if (!_initialized) {
      debugPrint(
          '⚠️ NotificationService no inicializado, inicializando ahora...');
      await initialize();
    }

    final now = DateTime.now();
    final eventDateTime = _getEventDateTime(event);

    debugPrint('📅 Programando notificaciones para: ${event.title}');
    debugPrint('   📍 Fecha del evento: $eventDateTime');
    debugPrint('   ⏰ Fecha actual: $now');
    debugPrint('   🕐 Diferencia: ${eventDateTime.difference(now)}');

    // No programar si el evento ya pasó
    if (eventDateTime.isBefore(now)) {
      debugPrint('   ⚠️ Evento ya pasó, no se programarán notificaciones');
      return;
    }

    // Cancelar notificaciones previas del mismo evento
    await cancelEventNotifications(event.id);

    int notificationsScheduled = 0;

    try {
      // 1️⃣ Notificación 1 día antes (9:00 AM)
      final oneDayBefore = eventDateTime.subtract(const Duration(days: 1));
      final oneDayBeforeAt9AM = DateTime(
        oneDayBefore.year,
        oneDayBefore.month,
        oneDayBefore.day,
      );

      if (oneDayBeforeAt9AM.isAfter(now)) {
        try {
          await _scheduleNotification(
            id: _getNotificationId(event.id, 1),
            title: '📅 Evento mañana: ${event.title}',
            body: '${event.title} es mañana a las ${event.hour}',
            scheduledDate: oneDayBeforeAt9AM,
            payload: event.id,
            eventImage: event.img,
          );
          notificationsScheduled++;
          debugPrint(
              '   ✅ Notificación 1 día antes programada para: $oneDayBeforeAt9AM');
          debugPrint('      ID: ${_getNotificationId(event.id, 1)}');
        } catch (e) {
          debugPrint('   ❌ Error programando notificación 1 día antes: $e');
        }
      } else {
        debugPrint(
            '   ⏭️ Notificación 1 día antes omitida (ya pasó: $oneDayBeforeAt9AM)');
      }

      // 2️⃣ Notificación 2 horas antes
      final twoHoursBefore = eventDateTime.subtract(const Duration(hours: 2));

      if (twoHoursBefore.isAfter(now)) {
        try {
          await _scheduleNotification(
            id: _getNotificationId(event.id, 2),
            title: '⏰ En 2 horas: ${event.title}',
            body: 'El evento comienza a las ${event.hour} en ${event.place}',
            scheduledDate: twoHoursBefore,
            payload: event.id,
            eventImage: event.img,
          );
          notificationsScheduled++;
          debugPrint(
              '   ✅ Notificación 2 horas antes programada para: $twoHoursBefore');
          debugPrint('      ID: ${_getNotificationId(event.id, 2)}');
        } catch (e) {
          debugPrint('   ❌ Error programando notificación 2 horas antes: $e');
        }
      } else {
        debugPrint(
            '   ⏭️ Notificación 2 horas antes omitida (ya pasó: $twoHoursBefore)');
      }

      // 3️⃣ Notificación al momento del evento
      if (eventDateTime.isAfter(now)) {
        try {
          await _scheduleNotification(
            id: _getNotificationId(event.id, 3),
            title: '🎉 ¡${event.title} comienza ahora!',
            body:
                'El evento está en ${event.place}. ${event.isFree ? 'Entrada gratis' : 'Precio: ${event.formattedPrice}'}',
            scheduledDate: eventDateTime,
            payload: event.id,
            eventImage: event.img,
          );
          notificationsScheduled++;
          debugPrint(
              '   ✅ Notificación al momento programada para: $eventDateTime');
          debugPrint('      ID: ${_getNotificationId(event.id, 3)}');
        } catch (e) {
          debugPrint('   ❌ Error programando notificación al momento: $e');
        }
      } else {
        debugPrint('   ⏭️ Notificación al momento omitida (ya pasó)');
      }

      debugPrint(
          '✅ Total de notificaciones programadas: $notificationsScheduled para "${event.title}"');

      // Verificar notificaciones pendientes
      final pending = await getPendingNotifications();
      debugPrint(
          '📋 Total de notificaciones pendientes en el sistema: ${pending.length}');
      for (var notification in pending) {
        if (notification.payload == event.id) {
          debugPrint('   🔔 ID: ${notification.id} - ${notification.title}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error general al programar notificaciones: $e');
      rethrow;
    }
  }

  /// Programa una notificación individual
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? eventImage,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    // Estilo de notificación para Android (SIN sonido personalizado)
    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Recordatorios de Eventos',
      channelDescription: 'Notificaciones para recordar eventos guardados',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      // ❌ REMOVIDO: sound: const RawResourceAndroidNotificationSound('notification'),
      // ✅ Usar sonido por defecto del sistema
      playSound: true,
      enableVibration: true,
    );

    // Estilo para iOS
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancela todas las notificaciones de un evento
  Future<void> cancelEventNotifications(String eventId) async {
    await _notifications.cancel(_getNotificationId(eventId, 1));
    await _notifications.cancel(_getNotificationId(eventId, 2));
    await _notifications.cancel(_getNotificationId(eventId, 3));
    debugPrint('🗑️ Notificaciones canceladas para evento: $eventId');
  }

  /// Cancela todas las notificaciones pendientes
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🗑️ Todas las notificaciones canceladas');
  }

  /// Obtiene las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Muestra una notificación inmediata (para pruebas)
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Notificaciones de Prueba',
      channelDescription: 'Canal para probar notificaciones',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      '🔔 Notificación de Prueba',
      'Las notificaciones están funcionando correctamente',
      notificationDetails,
    );
  }

  // ============================================
  // MÉTODOS AUXILIARES
  // ============================================

  /// Genera un ID único para cada notificación
  /// Combina el hash del eventId con el tipo para garantizar IDs únicos
  int _getNotificationId(String eventId, int type) {
    // Generar hash del eventId
    final hashCode = eventId.hashCode.abs();

    // Limitar a 8 dígitos para dejar espacio al tipo
    final baseId = hashCode % 100000000; // Máximo 8 dígitos

    // Agregar el tipo al final (último dígito)
    final uniqueId = baseId * 10 + type;

    debugPrint('   🔢 ID generado: $uniqueId (base: $baseId, tipo: $type)');
    return uniqueId;
  }

  /// Convierte la fecha y hora del evento a DateTime
  DateTime _getEventDateTime(EventModel event) {
    try {
      // Parsear la hora (formato: "18:00" o "6:00 PM")
      final hourString = event.hour.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = hourString.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      // Ajustar para formato 12 horas si contiene PM
      if (event.hour.toLowerCase().contains('pm') && hour < 12) {
        hour += 12;
      }

      return DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        hour,
        minute,
      );
    } catch (e) {
      // Si falla el parseo, usar el mediodía como default
      return DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        12,
        0,
      );
    }
  }
}
