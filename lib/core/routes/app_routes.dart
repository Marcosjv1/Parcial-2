import 'package:flutter/material.dart';

import '../../domain/entities/diary_entry.dart';
import '../../presentation/screens/about_screen.dart';
import '../../presentation/screens/entry_detail_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/new_entry_screen.dart';
import '../di/service_locator.dart';

/// Rutas con nombre de la aplicación y su generador.
///
/// Centralizar la navegación aquí evita "strings mágicos" repartidos por
/// las pantallas y permite pasar argumentos tipados (p. ej. la entrada que
/// se abre en el detalle).
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String newEntry = '/nueva-entrada';
  static const String detail = '/detalle';
  static const String about = '/acerca-de';

  /// Usado por `MaterialApp.onGenerateRoute`.
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    ServiceLocator locator,
  ) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreen(repository: locator.diaryRepository),
        );

      case newEntry:
        // Transición deslizando desde abajo, como una hoja nueva.
        return _slideUpRoute(
          settings,
          NewEntryScreen(
            repository: locator.diaryRepository,
            mediaService: locator.mediaService,
            speechService: locator.speechService,
            locationService: locator.locationService,
          ),
        );

      case detail:
        final entry = settings.arguments;
        if (entry is! DiaryEntry) {
          return _errorRoute('Falta la entrada del diario a mostrar.');
        }
        // Transición con desvanecimiento para que destaque la animación
        // Hero de la imagen.
        return _fadeRoute(
          settings,
          EntryDetailScreen(
            entry: entry,
            repository: locator.diaryRepository,
            mediaService: locator.mediaService,
            mapsLauncher: locator.mapsLauncher,
          ),
        );

      case about:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AboutScreen(),
        );

      default:
        return _errorRoute('Ruta no encontrada: ${settings.name}');
    }
  }

  // -------------------------------------------------------------------
  // Transiciones personalizadas
  // -------------------------------------------------------------------

  static PageRouteBuilder<T> _fadeRoute<T>(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
    );
  }

  static PageRouteBuilder<T> _slideUpRoute<T>(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(offset),
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
