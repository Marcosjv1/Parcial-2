import 'package:url_launcher/url_launcher.dart';

import '../core/errors/app_exception.dart';
import '../domain/entities/geo_point.dart';

/// Abstracción para abrir una ubicación en una app de mapas externa.
abstract class MapsLauncherService {
  Future<void> openInMaps(GeoPoint point);
}

/// Abre Google Maps (app si está instalada, si no el navegador) con las
/// coordenadas guardadas, usando la URL universal de Google Maps.
class GoogleMapsLauncherService implements MapsLauncherService {
  const GoogleMapsLauncherService();

  @override
  Future<void> openInMaps(GeoPoint point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${point.latitude},${point.longitude}',
    );
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw const MapsException('No se encontró una app para abrir mapas.');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw MapsException('No se pudo abrir Google Maps: $e');
    }
  }
}
