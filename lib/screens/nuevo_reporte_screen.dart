// dart:io para File (mostrar la vista previa de la foto)
import 'dart:io';

import 'package:flutter/material.dart';
// Para decir qué permiso queremos (Permission.camera, Permission.microphone...)
import 'package:permission_handler/permission_handler.dart';

import '../database/db_helper.dart';
import '../models/reporte.dart';
import '../services/camara_service.dart';
import '../services/permisos_service.dart';
import '../services/ubicacion_service.dart';
import '../services/voz_service.dart';
import '../tema.dart';

// ============================================================
// PANTALLA 3: NUEVO REPORTE (el formulario)
// Aquí se juntan los 3 gadgets:
//   1. Cámara / galería  -> foto del problema
//   2. Micrófono         -> dictar la descripción
//   3. GPS               -> se toma solito al darle "Enviar reporte"
// Al final todo se guarda en SQLite con DBHelper.
// ============================================================
class NuevoReporteScreen extends StatefulWidget {
  const NuevoReporteScreen({super.key});

  @override
  State<NuevoReporteScreen> createState() => _NuevoReporteScreenState();
}

class _NuevoReporteScreenState extends State<NuevoReporteScreen> {
  // El "controller" guarda lo que el usuario escribe en el campo de texto.
  final _descripcionController = TextEditingController();
  final _voz = VozService(); // nuestro servicio del micrófono

  String _tipo = Reporte.tipos.first; // tipo elegido en el menú (Bache por defecto)
  String? _imagen; // ruta de la foto elegida
  bool _escuchando = false; // ¿el micrófono está grabando?
  bool _guardando = false; // true mientras se obtiene el GPS y se guarda
  String _estado = ''; // mensaje mientras se guarda (ej. "Obteniendo GPS...")

  // dispose se ejecuta cuando se cierra la pantalla: liberamos el controller
  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  // ---------- GADGET 1: Cámara y galería ----------
  Future<void> _tomarFoto() async {
    // Primero pedimos permiso de cámara; si lo niega, no seguimos
    final permitido =
        await PermisosService.pedir(context, Permission.camera, 'la cámara');
    if (!permitido) return;
    try {
      final ruta = await CamaraService.tomarFoto();
      if (ruta != null) setState(() => _imagen = ruta); // guardamos la ruta y se ve la foto
    } catch (e) {
      _mostrarMensaje('Error con la cámara: $e');
    }
  }

  // La galería no necesita permiso en Android nuevo, por eso va directo
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

    // Pedimos permiso del micrófono (con el manejo de "denegado")
    final conPermiso = await PermisosService.pedir(
        context, Permission.microphone, 'el micrófono');
    if (!conPermiso) return;

    try {
      // Preparamos el micrófono; cuando termine de escuchar apagamos el botón rojo
      final permitido = await _voz.iniciar(alTerminar: () {
        if (mounted) setState(() => _escuchando = false);
      });
      if (!permitido) {
        _mostrarMensaje('No hay permiso para usar el micrófono');
        return;
      }

      // Guardamos lo que ya estaba escrito para no borrarlo al dictar
      final textoAnterior = _descripcionController.text;
      setState(() => _escuchando = true); // el botón se pone rojo con "Detener"

      // Cada vez que reconoce palabras, las ponemos en el campo de texto
      await _voz.escuchar((textoDictado) {
        _descripcionController.text = '$textoAnterior $textoDictado'.trim();
      });
    } catch (e) {
      if (mounted) setState(() => _escuchando = false);
      _mostrarMensaje('Error con el micrófono: $e');
    }
  }

  // ---------- GADGET 3: GPS + guardar en SQLite ----------
  // Pasos: 1) revisar que haya descripción, 2) pedir permiso de ubicación,
  // 3) leer el GPS (mostrando "Obteniendo tu ubicación..."), 4) guardar en SQLite.
  // Si el GPS falla NO perdemos el reporte: se guarda sin ubicación.
  Future<void> _guardar() async {
    // trim() quita espacios; si no escribió nada, no dejamos guardar
    if (_descripcionController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe o dicta qué problema viste');
      return;
    }
    // Si el micrófono seguía prendido, lo apagamos antes de guardar
    if (_escuchando) {
      await _voz.detener();
      setState(() => _escuchando = false);
    }
    if (!mounted) return;

    // Intentamos obtener la ubicación GPS (empiezan en null por si falla)
    double? latitud;
    double? longitud;
    final conPermiso = await PermisosService.pedir(
        context, Permission.locationWhenInUse, 'la ubicación');

    // Mostramos el circulito de carga con el mensaje
    setState(() {
      _guardando = true;
      _estado = 'Obteniendo tu ubicación GPS...';
    });
    if (conPermiso) {
      try {
        final posicion = await UbicacionService.obtenerUbicacion();
        latitud = posicion.latitude;
        longitud = posicion.longitude;
      } catch (e) {
        // Si falla el GPS, igual guardamos el reporte pero sin ubicación
        _mostrarMensaje('Se guardará sin ubicación: $e');
      }
    } else {
      _mostrarMensaje('Se guardará sin ubicación');
    }
    if (mounted) setState(() => _estado = 'Guardando...');

    // Guardamos el reporte en la base de datos
    try {
      final ahora = DateTime.now(); // fecha y hora de este momento
      // padLeft(2, '0') hace que 5 minutos se vea "05" y no "5"
      final minutos = ahora.minute.toString().padLeft(2, '0');
      // Armamos el objeto Reporte con todo lo del formulario
      final reporte = Reporte(
        tipo: _tipo,
        descripcion: _descripcionController.text.trim(),
        fecha: '${ahora.day}/${ahora.month}/${ahora.year} ${ahora.hour}:$minutos',
        imagen: _imagen,
        latitud: latitud,
        longitud: longitud,
      );
      await DBHelper.insertar(reporte); // INSERT en SQLite

      if (!mounted) return;
      Navigator.pop(context); // regresamos a la lista
    } catch (e) {
      _mostrarMensaje('Error al guardar: $e');
    } finally {
      // Pase lo que pase, quitamos el circulito de carga
      if (mounted) setState(() => _guardando = false);
    }
  }

  // Título de cada paso del formulario (número en círculo + texto)
  // Lo hicimos función para no copiar y pegar lo mismo 3 veces
  Widget _paso(int numero, String titulo, String ayuda) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, child: Text('$numero')), // el circulito con el número
          const SizedBox(width: 12),
          // Expanded = ocupa todo el espacio que sobra a la derecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(ayuda, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Atajo para mostrar un mensajito abajo (SnackBar)
  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // build: dibuja la pantalla. Cada vez que hacemos setState(),
  // Flutter vuelve a llamar build() y la pantalla se actualiza.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo reporte')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ---- PASO 1: foto ----
          _paso(1, 'Toma una foto del problema',
              'Opcional, pero ayuda a que lo arreglen más rápido'),
          // Si ya hay foto, la mostramos; si no, un cuadro gris con ícono
          if (_imagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_imagen!), height: 200, fit: BoxFit.cover),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.add_a_photo, size: 80, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          // Los dos botones de foto, uno al lado del otro
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
          // ---- PASO 2: tipo ----
          _paso(2, '¿Qué tipo de problema es?', 'Elige una opción de la lista'),
          // Menú desplegable para elegir el tipo de problema
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo de problema',
              border: OutlineInputBorder(),
            ),
            // Convertimos cada texto de la lista en una opción del menú
            items: Reporte.tipos
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (valor) => setState(() => _tipo = valor!), // guardamos lo que eligió
          ),
          // ---- PASO 3: descripción ----
          _paso(3, 'Describe lo que pasa',
              'Escríbelo o toca "Dictar con voz" y habla'),
          TextField(
            controller: _descripcionController, // aquí se guarda lo que escribe/dicta
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Ej. Bache grande frente a la tienda, ya rompió una llanta',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          // Botón del micrófono: cambia a rojo con "Detener" mientras escucha
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
          // Aviso para que el usuario sepa que se usará su ubicación
          Card(
            child: ListTile(
              leading: const Icon(Icons.my_location, color: azulApp),
              title: const Text('Tu ubicación se guarda sola'),
              subtitle: const Text(
                'Al enviar, tomamos tu ubicación GPS para saber dónde está el problema.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mientras guarda: circulito de carga. Si no: el botón de enviar
          if (_guardando)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(_estado), // "Obteniendo tu ubicación GPS..." o "Guardando..."
              ],
            )
          else
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.send),
              label: const Text('Enviar reporte'),
            ),
        ],
      ),
    );
  }
}
