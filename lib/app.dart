import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

/// Widget raíz: configura tema y navegación por rutas con nombre.
class BitacoraApp extends StatelessWidget {
  const BitacoraApp({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitácora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) =>
          AppRoutes.onGenerateRoute(settings, locator),
    );
  }
}
