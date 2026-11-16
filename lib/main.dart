import 'package:flutter/material.dart';

import 'screens/detalle_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nuevo_reporte_screen.dart';

// ============================================================
// main.dart — Aquí arranca TODO.
// Cuando abres la app, Flutter ejecuta main() y main() le dice
// "corre MiApp". MiApp es el "esqueleto": define el tema (colores)
// y la lista de pantallas (rutas) a las que se puede navegar.
// ============================================================
void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReportaCalle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      // Rutas con nombre: cada pantalla tiene un "nombre" (como una URL).
      // Para ir a una pantalla solo hacemos Navigator.pushNamed(context, '/nuevo').
      // initialRoute = la primera pantalla que se ve al abrir la app (el login).
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/inicio': (context) => const InicioScreen(),
        '/nuevo': (context) => const NuevoReporteScreen(),
        '/detalle': (context) => const DetalleScreen(),
      },
    );
  }
}
