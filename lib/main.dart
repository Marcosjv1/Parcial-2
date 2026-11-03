import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/service_locator.dart';

/// Punto de entrada de Bitácora.
///
/// Estructura por capas:
///  - domain/        Entidades y contratos (no depende de Flutter ni plugins)
///  - data/          Implementación con SQLite
///  - services/      Acceso a hardware: GPS, cámara, micrófono, mapas
///  - presentation/  Pantallas y widgets
///  - core/          Rutas, tema, errores, utilidades e inyección de deps.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BitacoraApp(locator: ServiceLocator.production()));
}
