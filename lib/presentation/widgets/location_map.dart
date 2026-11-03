import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/geo_point.dart';

/// Mapa interactivo (zoom y arrastre) con un marcador en la ubicación.
///
/// Usa OpenStreetMap mediante `flutter_map`, por lo que NO requiere una
/// API key de Google. Para abrir Google Maps se usa el botón del detalle.
class LocationMap extends StatelessWidget {
  const LocationMap({super.key, required this.point, this.height = 220});

  final GeoPoint point;
  final double height;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(point.latitude, point.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.marcos.bitacora',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
      ),
    );
  }
}
