import 'package:descubre_narino/models/place_search_result.dart';

class NarinoPlaces {
  static final List<PlaceSearchResult> places = [
    // ======== PASTO - Centro y alrededores ========
    PlaceSearchResult(
      placeName: 'Parque Nariño',
      fullAddress: 'Parque Nariño, Centro, Pasto, Nariño',
      latitude: 1.214575,
      longitude: -77.278328,
    ),
    PlaceSearchResult(
      placeName: 'Plaza de Nariño',
      fullAddress: 'Plaza de Nariño, Centro, Pasto, Nariño',
      latitude: 1.214575,
      longitude: -77.278328,
    ),
    PlaceSearchResult(
      placeName: 'Parque Infantil',
      fullAddress: 'Parque Infantil, Pasto, Nariño',
      latitude: 1.219481,
      longitude: -77.281667,
    ),
    PlaceSearchResult(
      placeName: 'Parque Chapalito',
      fullAddress: 'Parque Chapalito, Pasto, Nariño',
      latitude: 1.186950,
      longitude: -77.276867,
    ),
    PlaceSearchResult(
      placeName: 'Parque Santiago',
      fullAddress: 'Parque Santiago, Pasto, Nariño',
      latitude: 1.210544,
      longitude: -77.282802,
    ),
    PlaceSearchResult(
      placeName: 'Centro Comercial Unicentro',
      fullAddress: 'Unicentro, Pasto, Nariño',
      latitude: 1.216535,
      longitude: -77.288564,
    ),
    PlaceSearchResult(
      placeName: 'Estadio Departamental Libertad',
      fullAddress: 'Estadio Libertad, Pasto, Nariño',
      latitude: 1.198001,
      longitude: -77.277192,
    ),
    PlaceSearchResult(
      placeName: 'Centro Cultural Pandiaco',
      fullAddress: 'Centro Cultural Pandiaco, Pasto, Nariño',
      latitude: 1.230337,
      longitude: -77.287107,
    ),
    PlaceSearchResult(
      placeName: 'Universidad de Nariño',
      fullAddress: 'Universidad de Nariño, Pasto, Nariño',
      latitude: 1.231010,
      longitude: -77.293298,
    ),
    PlaceSearchResult(
      placeName: 'Museo Taminango',
      fullAddress: 'Museo Taminango (Arte Precolombino), Pasto, Nariño',
      latitude: 1.215183,
      longitude: -77.284136,
    ),

    // ======== LUGARES NATURALES Y REGIONES (NARIÑO) ========
    PlaceSearchResult(
      placeName: 'Laguna de la Cocha',
      fullAddress: 'Laguna de la Cocha, El Encano, Pasto, Nariño',
      latitude: 1.136175,
      longitude: -77.152687,
    ),
    PlaceSearchResult(
      placeName: 'Santuario de Las Lajas (Ipiales)',
      fullAddress: 'Santuario de Nuestra Señora de las Lajas, Ipiales, Nariño',
      latitude: 0.805511,
      longitude: -77.585497,
    ),

    // ======== IPIALES ========
    PlaceSearchResult(
      placeName: 'Parque Central de Ipiales',
      fullAddress: 'Parque Central, Ipiales, Nariño',
      latitude: 0.8267,
      longitude: -77.6417,
    ),
    PlaceSearchResult(
      placeName: 'Rumichaca (Frontera)',
      fullAddress: 'Rumichaca (Puente binacional), Ipiales, Nariño',
      latitude: 0.8119,
      longitude: -77.6544,
    ),

    // ======== TÚQUERRES ========
    PlaceSearchResult(
      placeName: 'Parque Principal de Túquerres',
      fullAddress: 'Parque Principal, Túquerres, Nariño',
      latitude: 1.0867,
      longitude: -77.6167,
    ),

    // ======== TUMACO ========
    PlaceSearchResult(
      placeName: 'Playa El Morro',
      fullAddress: 'Playa El Morro, Tumaco, Nariño',
      latitude: 1.8000,
      longitude: -78.8000,
    ),
    PlaceSearchResult(
      placeName: 'Parque Colón (Tumaco)',
      fullAddress: 'Parque Colón, Tumaco, Nariño',
      latitude: 1.8067,
      longitude: -78.7647,
    ),
    PlaceSearchResult(
      placeName: 'Playa Bocagrande (Tumaco)',
      fullAddress: 'Playa Bocagrande, Tumaco, Nariño',
      latitude: 1.8333,
      longitude: -78.7833,
    ),

    // ======== MUNICIPIOS DEL SUR Y OCCIDENTE ========
    PlaceSearchResult(
      placeName: 'Parque de Sandoná',
      fullAddress: 'Parque Principal, Sandoná, Nariño',
      latitude: 1.2819,
      longitude: -77.4675,
    ),
    PlaceSearchResult(
      placeName: 'Parque de Samaniego',
      fullAddress: 'Parque Principal, Samaniego, Nariño',
      latitude: 1.3433,
      longitude: -77.5897,
    ),
    PlaceSearchResult(
      placeName: 'Parque de La Unión',
      fullAddress: 'Parque Principal, La Unión, Nariño',
      latitude: 1.6042,
      longitude: -77.1333,
    ),
    PlaceSearchResult(
      placeName: 'Parque de La Cruz',
      fullAddress: 'Parque Principal, La Cruz, Nariño',
      latitude: 1.6017,
      longitude: -77.1114,
    ),

    // ======== OTROS PUNTOS DE INTERÉS ========
    PlaceSearchResult(
      placeName: 'Plaza del Carnaval',
      fullAddress: 'Plaza / Espacio del Carnaval, Pasto, Nariño',
      latitude: 1.211183,
      longitude: -77.276633,
    ),
  ];

  /// Busca lugares en la lista predefinida
  static List<PlaceSearchResult> searchLocal(String query) {
    final lowerQuery = query.toLowerCase();
    return places.where((place) {
      return place.placeName.toLowerCase().contains(lowerQuery) ||
          place.fullAddress.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
