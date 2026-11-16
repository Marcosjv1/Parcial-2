import 'package:geolocator/geolocator.dart';

// ============================================================
// GADGET 3: GPS
// Usa el paquete geolocator para saber dónde está el teléfono.
// Si algo falla (GPS apagado, sin permiso), lanza una excepción
// con un mensaje claro; el formulario la atrapa con try-catch.
// ============================================================
class UbicacionService {
  static Future<Position> obtenerUbicacion() async {
    // 1. Revisar que el GPS esté prendido
    final gpsActivo = await Geolocator.isLocationServiceEnabled();
    if (!gpsActivo) {
      throw Exception('El GPS está desactivado');
    }

    // 2. Revisar el permiso (y pedirlo si no lo tiene)
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw Exception('No se dio permiso de ubicación');
    }

    // 3. Obtener la posición (máximo 15 segundos de espera)
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
