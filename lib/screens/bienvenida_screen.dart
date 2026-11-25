// dart:async trae el Timer para que el carrusel avance solito
import 'dart:async';

import 'package:flutter/material.dart';

import '../services/primer_uso_service.dart';
import '../tema.dart';

// ============================================================
// PANTALLA DE BIENVENIDA — Un carrusel (PageView) con 3 imágenes
// que explica cómo funciona la app. Avanza solo cada 4 segundos,
// o se puede deslizar con el dedo.
// Se muestra la primera vez que entras y también desde el menú
// ("Cómo funciona").
// ============================================================
class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  // Los 3 pasos: imagen, título y texto
  static const _pasos = [
    (
      imagen: 'assets/images/bienvenida/paso1.png',
      titulo: 'Toma una foto',
      texto: 'Si ves un bache, una lámpara apagada, basura o una fuga, '
          'tómale una foto con la cámara.',
    ),
    (
      imagen: 'assets/images/bienvenida/paso2.png',
      titulo: 'Cuéntanos y guardamos dónde',
      texto: 'Dicta la descripción con tu voz y la app guarda la ubicación '
          'con el GPS.',
    ),
    (
      imagen: 'assets/images/bienvenida/paso3.png',
      titulo: 'Se envía a la ciudad',
      texto: 'Tu reporte llega al servidor y todos pueden ver cuando '
          'ya está resuelto.',
    ),
  ];

  final _controlador = PageController(); // controla qué página se ve
  Timer? _reloj; // el cronómetro del avance automático
  int _pagina = 0;

  @override
  void initState() {
    super.initState();
    // Cada 4 segundos pasamos a la siguiente página (y volvemos a la primera al final)
    _reloj = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controlador.hasClients) return;
      final siguiente = (_pagina + 1) % _pasos.length;
      _controlador.animateToPage(siguiente,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _reloj?.cancel(); // apagamos el cronómetro al salir
    _controlador.dispose();
    super.dispose();
  }

  // Termina la bienvenida: si es la primera vez, vamos a la lista;
  // si venimos del menú, solo regresamos.
  Future<void> _terminar() async {
    await PrimerUsoService.marcarVista();
    if (!mounted) return;
    final primeraVez = ModalRoute.of(context)?.settings.arguments == true;
    if (primeraVez) {
      Navigator.pushReplacementNamed(context, '/inicio');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultima = _pagina == _pasos.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón "Saltar" arriba a la derecha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _terminar, child: const Text('Saltar')),
            ),
            // Las páginas deslizables
            Expanded(
              child: PageView.builder(
                controller: _controlador,
                itemCount: _pasos.length,
                onPageChanged: (i) => setState(() => _pagina = i),
                itemBuilder: (context, i) {
                  final paso = _pasos[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(paso.imagen, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 24),
                        Text(paso.titulo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(paso.texto,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Los puntitos que indican en qué página vas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pasos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  width: i == _pagina ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _pagina ? azulApp : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: ultima
                      ? _terminar
                      : () => _controlador.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut),
                  child: Text(ultima ? 'Empezar' : 'Siguiente'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
