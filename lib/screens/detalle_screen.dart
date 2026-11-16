import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/db_helper.dart';
import '../models/reporte.dart';
import '../widgets/reporte_widgets.dart';

// ============================================================
// PANTALLA 4: DETALLE
// Muestra un reporte completo: foto (con animación Hero), tipo,
// estado, descripción, coordenadas y el botón para abrir Google Maps.
// También deja marcarlo como resuelto o borrarlo.
// ============================================================
class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key});

  // Arma un link de Google Maps con la latitud y longitud guardadas
  // y lo abre con url_launcher (se abre la app de Maps o el navegador).
  Future<void> _abrirMapa(BuildContext context, Reporte reporte) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${reporte.latitud},${reporte.longitud}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, 'No se pudo abrir el mapa: $e');
    }
  }

  // Cambia el reporte a "Resuelto" (o de regreso a "Pendiente")
  Future<void> _cambiarEstado(BuildContext context, Reporte reporte) async {
    final nuevo = reporte.resuelto ? 'Pendiente' : 'Resuelto';
    try {
      await DBHelper.actualizarEstado(reporte.id!, nuevo);
      if (!context.mounted) return;
      Navigator.pop(context); // regresamos a la lista, que se recarga sola
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, 'Error al actualizar: $e');
    }
  }

  // Muestra cómo se guarda el reporte (serializado en JSON)
  void _verJson(BuildContext context, Reporte reporte) {
    final json = const JsonEncoder.withIndent('  ').convert(reporte.toMap());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datos guardados (JSON)'),
        content: SingleChildScrollView(child: SelectableText(json)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, Reporte reporte) async {
    try {
      await DBHelper.eliminar(reporte.id!);
      if (!context.mounted) return;
      Navigator.pop(context); // regresamos a la lista
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, 'Error al eliminar: $e');
    }
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    // La pantalla de inicio nos mandó el reporte como "arguments"
    // al navegar (pushNamed). Aquí lo recibimos.
    final reporte = ModalRoute.of(context)!.settings.arguments as Reporte;

    return Scaffold(
      appBar: AppBar(
        title: Text(reporte.tipo),
        actions: [
          IconButton(
            tooltip: 'Ver datos en JSON',
            icon: const Icon(Icons.data_object),
            onPressed: () => _verJson(context, reporte),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminar(context, reporte),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mismo tag que en la lista, para que funcione la animación Hero
          Hero(
            tag: 'foto${reporte.id}',
            child: reporte.imagen != null
                ? FotoReporte(reporte: reporte, tamano: 320)
                : Icon(iconoDeTipo(reporte.tipo), size: 120),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              EstadoChip(estado: reporte.estado),
              const SizedBox(width: 12),
              Text(reporte.fecha, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(reporte.descripcion, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          const Text('Ubicación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (reporte.latitud != null) ...[
            Text(
              'Coordenadas: ${reporte.latitud!.toStringAsFixed(5)}, '
              '${reporte.longitud!.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _abrirMapa(context, reporte),
              icon: const Icon(Icons.map),
              label: const Text('Ver en Google Maps'),
            ),
          ] else
            const Text('Este reporte no tiene ubicación'),
          const SizedBox(height: 24),
          const Text('¿Ya lo arreglaron?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: () => _cambiarEstado(context, reporte),
            icon: Icon(reporte.resuelto ? Icons.undo : Icons.check),
            label: Text(
              reporte.resuelto ? 'Marcar como pendiente' : 'Marcar como resuelto',
            ),
          ),
        ],
      ),
    );
  }
}
