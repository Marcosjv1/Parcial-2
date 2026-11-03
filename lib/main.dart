import 'package:flutter/material.dart';

import 'screens/detalle_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/nueva_entrada_screen.dart';

// Punto de entrada de la app
void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitácora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      // Rutas con nombre: cada pantalla tiene un "nombre" para navegar a ella
      initialRoute: '/',
      routes: {
        '/': (context) => const InicioScreen(),
        '/nueva': (context) => const NuevaEntradaScreen(),
        '/detalle': (context) => const DetalleScreen(),
      },
    );
  }
}
