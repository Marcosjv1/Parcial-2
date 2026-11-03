import 'package:geolocator/geolocator.dart';

// Servicio para obtener la ubicación GPS actual
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
