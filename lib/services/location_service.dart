import 'dart:convert';

import 'package:descubre_narino/data/narino_places.dart';
import 'package:descubre_narino/models/place_search_result.dart';
import 'package:http/http.dart' as http;

/// Servicio para buscar lugares y obtener coordenadas usando Mapbox Geocoding API
class LocationService {
  // REEMPLAZA CON TU TOKEN DE MAPBOX (obtenido en PASO 3)
  static const String _mapboxToken =
      'pk.eyJ1IjoiY2hhcnRlc3QiLCJhIjoiY21oaTM4eWVkMHpzczJvb2cxZWozeGFoOCJ9.3fF0_MaR-s998PLI5HHa2Q';

  // URL base de la API de geocoding de Mapbox
  static const String _baseUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  // Coordenadas aproximadas del centro de Nariño (Pasto)
  static const double _pastoLat = 1.2136;
  static const double _pastoLng = -77.2811;

  /// Busca lugares según el texto ingresado por el usuario
  ///
  /// Parámetros:
  /// - [query]: Texto a buscar (ej: "Parque Nariño")
  ///
  /// Retorna: Lista de lugares encontrados con sus coordenadas
  ///
  /// Funcionamiento:
  /// 1. Hace petición HTTP a Mapbox con el texto de búsqueda
  /// 2. Filtra resultados para priorizar lugares en Colombia/Nariño
  /// 3. Convierte respuesta JSON a objetos PlaceSearchResult
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) {
      return [];
    }

    try {
      // 1. PRIMERO: Buscar en lugares predefinidos locales
      final localResults = NarinoPlaces.searchLocal(query);

      // 2. SEGUNDO: Buscar en API de Mapbox (solo si hay conexión)
      List<PlaceSearchResult> apiResults = [];

      try {
        const String narinoBbox = '-79.0,0.5,-76.5,2.5'; // Límites de Nariño

        final url = Uri.parse('$_baseUrl/${Uri.encodeComponent(query)}.json'
            '?access_token=$_mapboxToken'
            '&bbox=$narinoBbox' // Limita búsqueda a Nariño
            '&proximity=$_pastoLng,$_pastoLat' // Prioriza cerca de Pasto
            '&limit=5' // Solo 5 de API
            '&language=es'
            '&types=poi,address,locality,place'
            '&country=CO');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final features = data['features'] as List;

          // Filtrar para asegurar que están en Nariño
          final filteredFeatures = features.where((feature) {
            final coords = feature['center'];
            final lng = coords[0] as double;
            final lat = coords[1] as double;
            return lat >= 0.5 && lat <= 2.5 && lng >= -79.0 && lng <= -76.5;
          }).toList();

          apiResults = filteredFeatures
              .map((feature) => PlaceSearchResult.fromMapbox(feature))
              .toList();
        }
      } catch (e) {
        print('Error en API de Mapbox: $e');
        // Si falla la API, continuar solo con resultados locales
      }

      // 3. COMBINAR: Primero locales, luego API (sin duplicados)
      final combinedResults = <PlaceSearchResult>[];
      final addedNames = <String>{};

      // Agregar resultados locales primero (máxima prioridad)
      for (var place in localResults) {
        combinedResults.add(place);
        addedNames.add(place.placeName.toLowerCase());
      }

      // Agregar resultados de API que no estén duplicados
      for (var place in apiResults) {
        final normalizedName = place.placeName.toLowerCase();
        // Verificar si ya existe un lugar similar
        bool isDuplicate = addedNames.any((name) =>
            name.contains(normalizedName) || normalizedName.contains(name));

        if (!isDuplicate) {
          combinedResults.add(place);
          addedNames.add(normalizedName);
        }
      }

      return combinedResults.take(10).toList(); // Máximo 10 resultados totales
    } catch (e) {
      print('Error general al buscar lugares: $e');
      // En caso de error total, devolver solo lugares predefinidos
      return NarinoPlaces.searchLocal(query);
    }
  }

  /// Verifica si las coordenadas están dentro del departamento de Nariño
  ///
  /// Parámetros:
  /// - [latitude]: Latitud a verificar
  /// - [longitude]: Longitud a verificar
  ///
  /// Retorna: true si está en Nariño, false si no
  ///
  /// Límites aproximados de Nariño:
  /// - Latitud: 0.5° a 2.5° Norte
  /// - Longitud: -79.0° a -76.5° Oeste
  bool isInNarino(double latitude, double longitude) {
    return latitude >= 0.5 &&
        latitude <= 2.5 &&
        longitude >= -79.0 &&
        longitude <= -76.5;
  }

  /// Obtiene las coordenadas de un lugar específico por su nombre
  ///
  /// Similar a searchPlaces pero retorna solo el primer resultado
  /// Útil cuando ya conoces el nombre exacto del lugar
  Future<PlaceSearchResult?> getCoordinatesFromPlace(String placeName) async {
    final results = await searchPlaces(placeName);
    return results.isNotEmpty ? results.first : null;
  }
}
