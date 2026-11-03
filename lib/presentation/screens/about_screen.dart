import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../widgets/app_drawer.dart';

/// Pantalla informativa sobre la app y los gadgets que utiliza.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<(IconData, String, String)> _features = [
    (Icons.photo_camera, 'Cámara y galería',
        'Ilustra tu día con una foto tomada al momento o de tu galería.'),
    (Icons.mic, 'Dictado por voz',
        'Habla y el micrófono convierte tu voz en texto automáticamente.'),
    (Icons.place, 'Ubicación GPS',
        'Cada entrada guarda dónde estabas y la muestra en un mapa.'),
    (Icons.storage, 'Guardado local',
        'Todo se guarda en tu teléfono con SQLite; funciona sin internet.'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      drawer: const AppDrawer(currentRoute: AppRoutes.about),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.auto_stories,
              size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Bitácora',
              textAlign: TextAlign.center, style: textTheme.headlineMedium),
          Text('Versión 1.0.0',
              textAlign: TextAlign.center, style: textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(
            'Un diario personal pensado para registrar tu día en segundos: '
            'escribe o dicta lo que pasó, agrega una foto y la app guarda '
            'automáticamente dónde estabas.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final (icon, title, description) in _features)
            Card(
              child: ListTile(
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(description),
              ),
            ),
        ],
      ),
    );
  }
}
