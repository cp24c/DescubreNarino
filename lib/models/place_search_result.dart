/// Representa un resultado de búsqueda de lugares
/// Usado por el autocompletado de lugares en la creación de eventos
class PlaceSearchResult {
  final String placeName; // Nombre principal del lugar
  final String fullAddress; // Dirección completa
  final double latitude; // Coordenada latitud
  final double longitude; // Coordenada longitud

  PlaceSearchResult({
    required this.placeName,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  /// Crea un PlaceSearchResult desde la respuesta de Mapbox API
  factory PlaceSearchResult.fromMapbox(Map<String, dynamic> json) {
    return PlaceSearchResult(
      placeName: json['text'] ?? '',
      fullAddress: json['place_name'] ?? '',
      latitude: json['center'][1], // Mapbox devuelve [lng, lat]
      longitude: json['center'][0],
    );
  }

  @override
  String toString() => fullAddress;
}
