import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../tema.dart';

// ============================================================
// PANTALLA 1: LOGIN
// Es lo primero que ves. Pide la huella (o el PIN del teléfono).
// Si es correcta, te manda a la lista de reportes.
// ¿Por qué huella? Tus reportes guardan fotos y lugares por donde
// pasas, así que solo tú deberías poder verlos.
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _verificando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pedimos la huella en cuanto se abre la app
    WidgetsBinding.instance.addPostFrameCallback((_) => _desbloquear());
  }

  Future<void> _desbloquear() async {
    if (_verificando) return;
    setState(() {
      _verificando = true;
      _error = null;
    });

    try {
      final ok = await AuthService.autenticar();
      if (!mounted) return;
      if (ok) {
        // pushReplacementNamed quita el login de la pila de pantallas:
        // así el botón "atrás" no regresa a esta pantalla.
        Navigator.pushReplacementNamed(context, '/inicio');
        return;
      }
      setState(() => _error = 'No se pudo verificar tu identidad');
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulApp, // el login es todo azul
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_road, size: 90, color: Colors.white),
              const SizedBox(height: 16),
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
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
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
