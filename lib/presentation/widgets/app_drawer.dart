import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

/// Menú lateral (Drawer) compartido por las pantallas principales.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentRoute,
    this.onNewEntry,
  });

  /// Ruta de la pantalla actual, para resaltar la opción activa.
  final String currentRoute;

  /// Si la pantalla quiere manejar la creación (p. ej. para refrescar la
  /// lista al volver) pasa este callback; si no, se navega directo.
  final VoidCallback? onNewEntry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.auto_stories,
                    size: 48, color: scheme.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'Bitácora',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  'Tu diario con fotos, voz y ubicación',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Mis entradas'),
            selected: currentRoute == AppRoutes.home,
            onTap: () {
              Navigator.pop(context); // Cierra el drawer.
              if (currentRoute != AppRoutes.home) {
                Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Nueva entrada'),
            onTap: () {
              Navigator.pop(context);
              if (onNewEntry != null) {
                onNewEntry!();
              } else {
                Navigator.pushNamed(context, AppRoutes.newEntry);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            selected: currentRoute == AppRoutes.about,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != AppRoutes.about) {
                Navigator.pushNamed(context, AppRoutes.about);
              }
            },
          ),
        ],
      ),
    );
  }
}
