/// Coordenada geográfica simple e inmutable.
///
/// Se usa en el dominio para no depender de las clases de los paquetes
/// `geolocator` o `latlong2` (Inversión de Dependencias).
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Texto legible, p. ej. `21.04512, -89.62341`
  String get formatted =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($formatted)';
}
