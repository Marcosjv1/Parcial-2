import 'package:flutter/material.dart';

// El servicio que pide la huella
import '../services/auth_service.dart';
import '../tema.dart';

// ============================================================
// PANTALLA 1: LOGIN
// Es lo primero que ves. Pide la huella (o el PIN del teléfono).
// Si es correcta, te manda a la lista de reportes.
// ¿Por qué huella? Tus reportes guardan fotos y lugares por donde
// pasas, así que solo tú deberías poder verlos.
// ============================================================

// Es StatefulWidget porque la pantalla cambia (botón "Verificando...", mensaje de error)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _verificando = false; // true mientras la ventanita de huella está abierta
  String? _error; // mensaje de error para mostrar (null = no hay error)

  // initState se ejecuta UNA vez, cuando la pantalla se crea
  @override
  void initState() {
    super.initState();
    // Pedimos la huella en cuanto se abre la app.
    // addPostFrameCallback = "espera a que la pantalla termine de dibujarse y luego hazlo"
    WidgetsBinding.instance.addPostFrameCallback((_) => _desbloquear());
  }

  Future<void> _desbloquear() async {
    if (_verificando) return; // para no abrir dos ventanitas de huella al mismo tiempo
    // setState = cambia variables Y redibuja la pantalla
    setState(() {
      _verificando = true;
      _error = null;
    });

    try {
      final ok = await AuthService.autenticar(); // espera a que pongas la huella
      if (!mounted) return; // si la pantalla ya no existe, no hacemos nada
      if (ok) {
        // pushReplacementNamed quita el login de la pila de pantallas:
        // así el botón "atrás" no regresa a esta pantalla.
        Navigator.pushReplacementNamed(context, '/inicio');
        return;
      }
      setState(() => _error = 'No se pudo verificar tu identidad');
    } catch (e) {
      // Aquí caen las Exception que lanza AuthService
      if (mounted) {
        // Le quitamos el "Exception: " del principio para que se lea bonito
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      // finally se ejecuta SIEMPRE, haya salido bien o mal
      if (mounted) setState(() => _verificando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold = el "marco" de la pantalla
    return Scaffold(
      backgroundColor: azulApp, // el login es todo azul
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          // Column acomoda las cosas una debajo de otra
          child: Column(
            mainAxisSize: MainAxisSize.min, // la columna ocupa solo lo necesario (queda centrada)
            children: [
              const Icon(Icons.add_road, size: 90, color: Colors.white), // logo de la app
              const SizedBox(height: 16), // SizedBox = espacio en blanco entre cosas
              const Text(
                'ReportaCalle',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reporta baches, lámparas apagadas, basura y fugas de tu ciudad.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pon tu huella para entrar',
                style: TextStyle(color: Colors.white70), // blanco un poco transparente
              ),
              const SizedBox(height: 12),
              // Solo se dibuja si hay error. Los "..." meten varios widgets a la vez
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFFFCDD2)), // rojo claro
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                // Botón blanco con letras azules
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: azulApp,
                ),
                // Si onPressed es null el botón se desactiva (mientras verifica)
                onPressed: _verificando ? null : _desbloquear,
                icon: const Icon(Icons.fingerprint),
                label: Text(_verificando ? 'Verificando...' : 'Entrar con huella'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
