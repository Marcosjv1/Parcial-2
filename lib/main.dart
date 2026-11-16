// Importamos Material, que trae todos los widgets visuales (botones, barras, etc.)
import 'package:flutter/material.dart';

// Importamos las 4 pantallas de la app para poder registrarlas como rutas
import 'screens/detalle_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nuevo_reporte_screen.dart';
// Aquí están los colores azules que usa toda la app
import 'tema.dart';

// ============================================================
// main.dart — Aquí arranca TODO.
// Cuando abres la app, Flutter ejecuta main() y main() le dice
// "corre MiApp". MiApp es el "esqueleto": define el tema (colores)
// y la lista de pantallas (rutas) a las que se puede navegar.
// ============================================================
void main() {
  // runApp recibe el widget principal y lo pone en la pantalla del teléfono
  runApp(const MiApp());
}

// MiApp es StatelessWidget porque no cambia nunca, solo configura cosas
class MiApp extends StatelessWidget {
  const MiApp({super.key});

  // build() es el método que "dibuja" el widget
  @override
  Widget build(BuildContext context) {
    // MaterialApp es la base de cualquier app con diseño Material
    return MaterialApp(
      title: 'ReportaCalle', // nombre que usa Android en la lista de apps recientes
      debugShowCheckedModeBanner: false, // quita la etiqueta roja de "DEBUG" de la esquina
      // Tema: aquí se define el color de toda la app de una sola vez
      theme: ThemeData(
        colorSchemeSeed: azulApp, // a partir de este azul Flutter saca los demás tonos
        useMaterial3: true, // usamos la versión nueva de Material (se ve más moderno)
        scaffoldBackgroundColor: azulClaro, // fondo azul claro en vez de blanco
        appBarTheme: const AppBarTheme(
          backgroundColor: azulApp, // barra de arriba azul fuerte
          foregroundColor: Colors.white, // título e íconos en blanco
        ),
        // El botón flotante (el de "Reportar") también azul con letras blancas
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: azulApp,
          foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: azulClaro), // menú lateral azulito
        // Campos de texto con fondo blanco para que resalten sobre el azul
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      // Rutas con nombre: cada pantalla tiene un "nombre" (como una URL).
      // Para ir a una pantalla solo hacemos Navigator.pushNamed(context, '/nuevo').
      // initialRoute = la primera pantalla que se ve al abrir la app (el login).
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // pantalla 1: huella
        '/inicio': (context) => const InicioScreen(), // pantalla 2: lista de reportes
        '/nuevo': (context) => const NuevoReporteScreen(), // pantalla 3: formulario
        '/detalle': (context) => const DetalleScreen(), // pantalla 4: ver un reporte
      },
    );
  }
}
