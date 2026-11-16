import 'package:flutter/material.dart';

import '../services/auth_service.dart';

// ============================================================
// PANTALLA 1: LOGIN
// Es lo primero que ves. Pide la huella (o el PIN del teléfono).
// Si es correcta, te manda a la lista de entradas.
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'Bitácora',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu diario es privado. Desbloquéalo con tu huella.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                onPressed: _verificando ? null : _desbloquear,
                icon: const Icon(Icons.fingerprint),
                label: Text(_verificando ? 'Verificando...' : 'Desbloquear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
