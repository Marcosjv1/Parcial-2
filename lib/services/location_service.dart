import 'package:geolocator/geolocator.dart';

import '../core/errors/app_exception.dart';
import '../domain/entities/geo_point.dart';

/// Abstracción del GPS. La UI sólo conoce este contrato.
abstract class LocationService {
  /// Obtiene la posición actual del dispositivo.
  /// Lanza [LocationException] si el GPS está apagado o no hay permiso.
  Future<GeoPoint> getCurrentPosition();
}

/// Implementación con el paquete `geolocator`.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService({
    this.timeLimit = const Duration(seconds: 15),
  });

  /// Tiempo máximo de espera por una lectura del GPS.
  final Duration timeLimit;

  @override
  Future<GeoPoint> getCurrentPosition() async {
    try {
      // 1. ¿Está encendido el GPS?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'El GPS está desactivado. Actívalo para registrar la ubicación.',
        );
      }

      // 2. Verificar / solicitar permiso en tiempo de ejecución.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationException('Permiso de ubicación denegado.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'El permiso de ubicación está bloqueado. '
          'Habilítalo desde los ajustes del teléfono.',
        );
      }

      // 3. Leer la posición con alta precisión.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } on AppException {
      rethrow; // Ya trae un mensaje adecuado.
    } catch (e) {
      throw LocationException('No se pudo obtener la ubicación: $e');
    }
  }
}
