import 'dart:io';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/entrada.dart';
import '../services/camara_service.dart';
import '../services/ubicacion_service.dart';
import '../services/voz_service.dart';

// Formulario para escribir una nueva entrada del diario
class NuevaEntradaScreen extends StatefulWidget {
  const NuevaEntradaScreen({super.key});

  @override
  State<NuevaEntradaScreen> createState() => _NuevaEntradaScreenState();
}

class _NuevaEntradaScreenState extends State<NuevaEntradaScreen> {
  final _tituloController = TextEditingController();
  final _textoController = TextEditingController();
  final _voz = VozService();

  String? _imagen; // ruta de la foto elegida
  bool _escuchando = false; // ¿el micrófono está grabando?
  bool _guardando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _textoController.dispose();
    super.dispose();
  }

  // ---------- GADGET 1: Cámara y galería ----------
  Future<void> _tomarFoto() async {
    try {
      final ruta = await CamaraService.tomarFoto();
      if (ruta != null) setState(() => _imagen = ruta);
    } catch (e) {
      _mostrarMensaje('Error con la cámara: $e');
    }
  }

  Future<void> _elegirDeGaleria() async {
    try {
      final ruta = await CamaraService.elegirDeGaleria();
      if (ruta != null) setState(() => _imagen = ruta);
    } catch (e) {
      _mostrarMensaje('Error con la galería: $e');
    }
  }

  // ---------- GADGET 2: Micrófono (voz a texto) ----------
  Future<void> _dictar() async {
    // Si ya está escuchando, el botón sirve para detener
    if (_escuchando) {
      await _voz.detener();
      setState(() => _escuchando = false);
      return;
    }

    try {
      final permitido = await _voz.iniciar(alTerminar: () {
        if (mounted) setState(() => _escuchando = false);
      });
      if (!permitido) {
        _mostrarMensaje('No hay permiso para usar el micrófono');
        return;
      }

      final textoAnterior = _textoController.text;
      setState(() => _escuchando = true);

      // Cada vez que reconoce palabras, las ponemos en el campo de texto
      await _voz.escuchar((textoDictado) {
        _textoController.text = '$textoAnterior $textoDictado'.trim();
      });
    } catch (e) {
      if (mounted) setState(() => _escuchando = false);
      _mostrarMensaje('Error con el micrófono: $e');
    }
  }

  // ---------- GADGET 3: GPS + guardar en SQLite ----------
  Future<void> _guardar() async {
    if (_tituloController.text.isEmpty || _textoController.text.isEmpty) {
      _mostrarMensaje('Escribe un título y lo que pasó hoy');
      return;
    }
    setState(() => _guardando = true);

    // Intentamos obtener la ubicación GPS
    double? latitud;
    double? longitud;
    try {
      final posicion = await UbicacionService.obtenerUbicacion();
      latitud = posicion.latitude;
      longitud = posicion.longitude;
    } catch (e) {
      // Si falla el GPS, igual guardamos la entrada pero sin ubicación
      _mostrarMensaje('Se guardará sin ubicación: $e');
    }

    // Guardamos la entrada en la base de datos
    try {
      final ahora = DateTime.now();
      final minutos = ahora.minute.toString().padLeft(2, '0');
      final entrada = Entrada(
        titulo: _tituloController.text,
        texto: _textoController.text,
        fecha: '${ahora.day}/${ahora.month}/${ahora.year} ${ahora.hour}:$minutos',
        imagen: _imagen,
        latitud: latitud,
        longitud: longitud,
      );
      await DBHelper.insertar(entrada);

      if (!mounted) return;
      Navigator.pop(context); // regresamos a la lista
    } catch (e) {
      _mostrarMensaje('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva entrada')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Vista previa de la foto
          if (_imagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_imagen!), height: 200, fit: BoxFit.cover),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.photo, size: 80, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _tomarFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _elegirDeGaleria,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textoController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: '¿Qué pasó hoy?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _dictar,
            icon: Icon(_escuchando ? Icons.stop : Icons.mic),
            label: Text(_escuchando ? 'Detener' : 'Dictar con voz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _escuchando ? Colors.red : null,
              foregroundColor: _escuchando ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 24),
          if (_guardando)
            const Center(child: CircularProgressIndicator())
          else
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
        ],
      ),
    );
  }
}
