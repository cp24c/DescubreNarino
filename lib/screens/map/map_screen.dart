import 'dart:async';
import 'dart:convert';

import 'package:descubre_narino/constants/colors.dart';
import 'package:descubre_narino/models/event_model.dart';
import 'package:descubre_narino/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// Pantalla principal del mapa que muestra eventos con sus ubicaciones
///
/// Funcionalidades:
/// - Obtiene ubicación GPS del usuario en tiempo real
/// - Carga eventos desde Firebase que tengan coordenadas
/// - Muestra marcadores en el mapa para cada evento
/// - Permite ver detalles del evento al tocar un marcador
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Token de acceso de Mapbox (REEMPLAZAR CON EL TUYO)
  static const String _mapboxToken =
      'pk.eyJ1IjoiY2hhcnRlc3QiLCJhIjoiY21oaTM4eWVkMHpzczJvb2cxZWozeGFoOCJ9.3fF0_MaR-s998PLI5HHa2Q';

  // Nuevas variables para la navegación y rutas
  LatLng? _destinationPosition;
  List<LatLng> _routePolyline = [];
  bool _showRoute = false;

  final EventService _eventService = EventService();
  final MapController _mapController = MapController();

  LatLng? _userPosition; // Ubicación GPS del usuario
  bool _isLoading = true;
  String? _errorMessage;
  List<EventModel> _eventsWithLocation = []; // Eventos que tienen coordenadas

  // Nuevas variables para ubicación en tiempo real
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTrackingRealTime = true;
  double? _locationAccuracy;

  /// Solo verifica permisos - no obtiene ubicación
  Future<void> _verifyPermissions() async {
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Los servicios de ubicación están deshabilitados. Por favor actívalos en la configuración.';
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permisos de ubicación denegados';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Los permisos de ubicación están permanentemente denegados.\nPor favor actívalos desde la configuración del dispositivo.';
    }
  }

  /// Inicia el seguimiento de ubicación en tiempo real
  void _startRealTimeLocation() async {
    try {
      // Verificar permisos primero
      await _verifyPermissions();

      print("🎯 Iniciando seguimiento de ubicación en tiempo real...");

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Actualizar cada 5 metros
      );

      // Cancelar suscripción anterior si existe
      _positionStreamSubscription?.cancel();

      // Variable para controlar si ya recibimos la primera ubicación
      bool firstLocationReceived = false;

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          print("📍 Actualización en tiempo real:");
          print("   → Latitud: ${position.latitude}");
          print("   → Longitud: ${position.longitude}");
          print("   → Precisión: ${position.accuracy}m");
          print("   → Timestamp: ${position.timestamp}");

          setState(() {
            _userPosition = LatLng(position.latitude, position.longitude);
            _locationAccuracy = position.accuracy;
            _isTrackingRealTime = true;

            // Solo marcamos que no está cargando cuando recibimos la primera ubicación
            if (!firstLocationReceived) {
              _isLoading = false;
              firstLocationReceived = true;
            }
          });

          // Mover el mapa automáticamente para seguir al usuario
          if (_isTrackingRealTime) {
            _mapController.move(_userPosition!, 16.0);
          }
        },
        onError: (error) {
          print("❌ Error en stream de ubicación: $error");
          setState(() {
            _isTrackingRealTime = false;
            _isLoading = false; // En caso de error, también dejamos de cargar
          });
        },
        cancelOnError: false,
      );

      // Timeout: si después de 10 segundos no recibimos ubicación, mostramos error
      Future.delayed(const Duration(seconds: 10), () {
        if (!firstLocationReceived && mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'No se pudo obtener la ubicación después de 10 segundos';
          });
        }
      });
    } catch (e) {
      print("❌ Error iniciando ubicación en tiempo real: $e");
      _handleLocationError(e);
    }
  }

  /// Maneja errores de ubicación
  void _handleLocationError(dynamic e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
      _isTrackingRealTime = false;
      // Ubicación por defecto: Centro de Pasto, Nariño
      _userPosition = LatLng(1.2136, -77.2811);
    });

    _mapController.move(_userPosition!, 13.0);
  }

  /// Detiene el seguimiento de ubicación en tiempo real
  void _stopRealTimeLocation() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _isTrackingRealTime = false;
    });
    print("⏹️ Seguimiento de ubicación detenido");
  }

  /// Alterna entre modo de seguimiento y modo estático
  void _toggleRealTimeTracking() {
    if (_isTrackingRealTime) {
      _stopRealTimeLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seguimiento desactivado',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange, // Temporal hasta que agregues warning
        ),
      );
    } else {
      _startRealTimeLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seguimiento activado',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Carga eventos desde Firebase que tengan coordenadas
  void _loadEventsWithLocation() {
    _eventService.getActiveEvents().listen((events) {
      setState(() {
        // Filtrar solo eventos con coordenadas válidas
        _eventsWithLocation =
            events.where((event) => event.hasLocation).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startRealTimeLocation(); // ← Cambiado a tiempo real
    _loadEventsWithLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // ← Importante limpiar el stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoadingWidget()
          : _userPosition == null
              ? _buildErrorWidget()
              : _buildMapWidget(),

      // Botón flotante para centrar en ubicación del usuario
      floatingActionButton: !_isLoading && _userPosition != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón para limpiar ruta (solo visible cuando hay ruta)
                if (_showRoute)
                  FloatingActionButton(
                    heroTag: 'clearRoute',
                    onPressed: _clearRoute,
                    backgroundColor: AppColors.error,
                    child: const Icon(
                      Icons.clear,
                      color: AppColors.white,
                    ),
                  ),
                if (_showRoute) const SizedBox(height: 12),

                // Botón para activar/desactivar seguimiento en tiempo real
                FloatingActionButton(
                  heroTag: 'tracking',
                  onPressed: _toggleRealTimeTracking,
                  backgroundColor:
                      _isTrackingRealTime ? AppColors.primary : AppColors.white,
                  child: Icon(
                    _isTrackingRealTime
                        ? Icons.location_searching
                        : Icons.location_disabled,
                    color: _isTrackingRealTime
                        ? AppColors.white
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Botón para centrar en ubicación del usuario
                FloatingActionButton(
                  heroTag: 'centerUser',
                  onPressed: () {
                    if (_userPosition != null) {
                      _mapController.move(_userPosition!, 16.0);
                    }
                  },
                  backgroundColor: AppColors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Botón para recargar eventos
                FloatingActionButton(
                  heroTag: 'reload',
                  onPressed: () {
                    _loadEventsWithLocation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Eventos actualizados',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  backgroundColor: AppColors.white,
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.primary,
                  ),
                ),
              ],
            )
          : null,
    );
  }

  /// Widget de carga mientras se obtiene ubicación
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Obteniendo tu ubicación...',
            style: GoogleFonts.poppins(
              color: AppColors.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activando seguimiento en tiempo real',
            style: GoogleFonts.poppins(
              color: AppColors.lightText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de error si no se puede obtener ubicación
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off,
                size: 60,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No se pudo obtener tu ubicación',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _startRealTimeLocation();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Reintentar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _userPosition = LatLng(1.2136, -77.2811);
                  _isLoading = false;
                  _isTrackingRealTime = false;
                });
              },
              child: Text(
                'Continuar sin mi ubicación',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget principal del mapa con marcadores
  Widget _buildMapWidget() {
    return Stack(
      children: [
        // Mapa
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _userPosition!,
            minZoom: 5,
            maxZoom: 18,
            initialZoom: 16, // Zoom más cercano por defecto
          ),
          children: [
            // Capa de tiles del mapa (fondo)
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$_mapboxToken',
              additionalOptions: const {},
              tileProvider: NetworkTileProvider(),
            ),

            // Capa de marcadores de eventos
            MarkerLayer(
              markers: _buildEventMarkers(),
            ),

            // Marcador de ubicación del usuario
            MarkerLayer(
              markers: [
                Marker(
                  point: _userPosition!,
                  width: 60,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTrackingRealTime
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Icon(
                        _isTrackingRealTime
                            ? Icons.location_searching
                            : Icons.person_pin_circle,
                        color: _isTrackingRealTime
                            ? AppColors.success
                            : AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                // Marcador de destino (si hay ruta activa)
                if (_showRoute && _destinationPosition != null)
                  Marker(
                    point: _destinationPosition!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.place,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            if (_showRoute && _routePolyline.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePolyline,
                    color: AppColors.primary.withOpacity(0.8),
                    strokeWidth: 5,
                    borderStrokeWidth: 2,
                    borderColor: AppColors.white.withOpacity(0.8),
                  ),
                ],
              ),

            // Loading overlay para cálculo de rutas
            if (_isLoading)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Calculando la mejor ruta...',
                            style: GoogleFonts.poppins(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Header con información
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.white,
                  AppColors.white.withOpacity(0.9),
                  AppColors.white.withOpacity(0),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isTrackingRealTime
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isTrackingRealTime
                          ? Icons.location_searching
                          : Icons.map,
                      color: _isTrackingRealTime
                          ? AppColors.success
                          : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTrackingRealTime
                              ? 'Siguiendo tu ubicación en tiempo real'
                              : 'Eventos en el Mapa',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          _isTrackingRealTime
                              ? 'Ubicación actualizada en tiempo real'
                              : '${_eventsWithLocation.length} eventos disponibles',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _isTrackingRealTime
                                ? AppColors.success
                                : AppColors.lightText,
                          ),
                        ),
                        if (_locationAccuracy != null && _isTrackingRealTime)
                          Text(
                            'Precisión: ${_locationAccuracy!.toStringAsFixed(1)}m',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _locationAccuracy! < 50
                                  ? AppColors.success
                                  : Colors.orange, // Temporal hasta warning
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Crea la lista de marcadores para los eventos
  List<Marker> _buildEventMarkers() {
    // Agrupar eventos por ubicación
    Map<String, List<EventModel>> eventsByLocation = {};

    for (var event in _eventsWithLocation) {
      String locationKey = '${event.latitude}_${event.longitude}';
      if (!eventsByLocation.containsKey(locationKey)) {
        eventsByLocation[locationKey] = [];
      }
      eventsByLocation[locationKey]!.add(event);
    }

    return eventsByLocation.entries.map((entry) {
      List<EventModel> eventsAtLocation = entry.value;
      LatLng point = LatLng(
          eventsAtLocation.first.latitude!, eventsAtLocation.first.longitude!);

      return Marker(
        point: point,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showEventsBottomSheet(eventsAtLocation),
          child: Stack(
            alignment: Alignment.center, // Centrar todo el contenido
            children: [
              // Círculo de fondo pulsante
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              // Icono del marcador principal
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              // Badge para mostrar cantidad de eventos - POSICIONADO CORRECTAMENTE
              if (eventsAtLocation.length > 1)
                Positioned(
                  top: 0, // Posicionar en la parte superior
                  right: 0, // Posicionar en la parte derecha
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      eventsAtLocation.length.toString(),
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Muestra un BottomSheet con TODOS los eventos en una ubicación
  void _showEventsBottomSheet(List<EventModel> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header con información de la ubicación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          events.first.place,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          '${events.length} evento${events.length > 1 ? 's' : ''} en esta ubicación',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Lista de eventos
            Expanded(
              child: events.length == 1
                  ? _buildEventDetails(events.first)
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(events[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una tarjeta para cada evento en la lista
  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Cerrar el bottomSheet actual y abrir uno con detalles completos
            Navigator.pop(context);
            _showEventDetailsBottomSheet(event);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del evento
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: event.img != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            event.img!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.event,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.event,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(width: 12),
                // Información del evento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoría
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.type,
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Título
                      Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Fecha y hora
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppColors.lightText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d', 'es').format(event.date),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.lightText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.lightText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.hour,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Precio
                      Text(
                        event.formattedPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: event.isFree
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.lightText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye los detalles de un solo evento
  Widget _buildEventDetails(EventModel event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del evento
          if (event.img != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                event.img!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          // Categoría
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.type,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Título
          Text(
            event.title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),

          const SizedBox(height: 16),

          // Organizador
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                'Organizado por ${event.organizer}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Fecha y hora
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'es').format(event.date),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 20,
                color: AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                event.hour,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ubicación
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.place,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Precio
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                size: 20,
                color: AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                event.formattedPrice,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: event.isFree ? AppColors.success : AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Descripción
          Text(
            'Descripción',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.lightText,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRouteToEvent(event);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.directions),
                  label: Text(
                    'Cómo llegar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                child: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Muestra un BottomSheet con los detalles de UN SOLO evento
  void _showEventDetailsBottomSheet(EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: _buildEventDetails(event),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra la ruta desde la ubicación actual hasta el evento usando Mapbox Directions API
  void _showRouteToEvent(EventModel event) async {
    if (_userPosition == null) return;

    final destination = LatLng(event.latitude!, event.longitude!);

    setState(() {
      _isLoading = true;
    });

    try {
      print("🗺️ Calculando ruta hacia ${event.title}...");

      // Obtener la ruta real desde Mapbox Directions API
      final routePoints =
          await _getRouteFromMapbox(_userPosition!, destination);

      if (routePoints.isNotEmpty) {
        setState(() {
          _destinationPosition = destination;
          _showRoute = true;
          _routePolyline = routePoints;
          _isLoading = false;
        });

        // Ajustar el mapa para mostrar toda la ruta
        _fitMapToRoute();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ruta calculada hacia ${event.title}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Ocultar',
              textColor: AppColors.white,
              onPressed: () {
                _clearRoute();
              },
            ),
          ),
        );
      } else {
        throw 'No se pudo calcular la ruta';
      }
    } catch (e) {
      print("❌ Error calculando ruta: $e");
      setState(() {
        _isLoading = false;
      });

      // Fallback: mostrar línea recta si la API falla
      _showStraightLineRoute(event, destination);
    }
  }

  /// Método fallback: muestra línea recta si la API falla
  void _showStraightLineRoute(EventModel event, LatLng destination) {
    setState(() {
      _destinationPosition = destination;
      _showRoute = true;
      _routePolyline = [_userPosition!, destination];
    });

    _fitMapToRoute();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mostrando línea directa (servicio de rutas no disponible)',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Ajusta el mapa para mostrar la ruta completa
  void _fitMapToRoute() {
    if (_userPosition == null || _destinationPosition == null) return;

    // Calcular los bounds para incluir toda la ruta, no solo los puntos extremos
    final allPoints = _routePolyline.isNotEmpty
        ? _routePolyline
        : [_userPosition!, _destinationPosition!];

    double minLat =
        allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng =
        allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng =
        allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    // Calcular centro
    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    // Calcular zoom apropiado basado en la distancia
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom;
    if (maxDiff < 0.01) {
      zoom = 15.0; // Muy cerca
    } else if (maxDiff < 0.05) {
      zoom = 13.0; // Cercano
    } else if (maxDiff < 0.1) {
      zoom = 11.0; // Media distancia
    } else {
      zoom = 10.0; // Lejos
    }

    _mapController.move(center, zoom);
  }

  /// Limpia la ruta mostrada
  void _clearRoute() {
    setState(() {
      _showRoute = false;
      _routePolyline = [];
      _destinationPosition = null;
    });
  }

  /// Obtiene una ruta real usando Mapbox Directions API
  Future<List<LatLng>> _getRouteFromMapbox(LatLng start, LatLng end) async {
    try {
      // Construir la URL para Mapbox Directions API
      final String coordinates =
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

      final String url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates'
          '?alternatives=false'
          '&geometries=geojson'
          '&overview=full'
          '&steps=false'
          '&access_token=$_mapboxToken';

      print("🌐 Solicitando ruta a Mapbox API...");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];

          // Decodificar la geometría Polyline6 de Mapbox
          final List<dynamic> coordinates = geometry['coordinates'];

          // Convertir coordenadas [lng, lat] a LatLng [lat, lng]
          List<LatLng> routePoints = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          print("✅ Ruta obtenida con ${routePoints.length} puntos");
          return routePoints;
        } else {
          throw 'Error en respuesta de Mapbox: ${data['code']}';
        }
      } else {
        throw 'Error HTTP ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      print("❌ Error en Mapbox Directions API: $e");
      rethrow;
    }
  }
}
