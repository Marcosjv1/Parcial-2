// dart:convert para JsonEncoder (mostrar el JSON bonito)
import 'dart:convert';

import 'package:flutter/material.dart';
// url_launcher abre links en otras apps (Google Maps o el navegador)
import 'package:url_launcher/url_launcher.dart';

import '../database/db_helper.dart';
import '../models/reporte.dart';
import '../services/api_service.dart';
import '../services/historial_service.dart';
import '../widgets/reporte_widgets.dart';

// ============================================================
// PANTALLA 4: DETALLE
// Muestra un reporte completo: foto (con animación Hero), tipo,
// estado, descripción, coordenadas y el botón para abrir Google Maps.
// También deja marcarlo como resuelto, borrarlo o (re)enviarlo al servidor.
// SOLID (S): la pantalla solo muestra el reporte; guardar y borrar lo hace DBHelper.
// ============================================================

// Es StatelessWidget porque no guarda nada; al cambiar algo regresa a la lista
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
      // externalApplication = que lo abra afuera de nuestra app (en Maps)
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, 'No se pudo abrir el mapa: $e');
    }
  }

  // Cambia el reporte a "Resuelto" (o de regreso a "Pendiente")
  Future<void> _cambiarEstado(BuildContext context, Reporte reporte) async {
    final nuevo = reporte.resuelto ? 'Pendiente' : 'Resuelto'; // lo contrario de lo que tiene
    try {
      await DBHelper.actualizarEstado(reporte.id!, nuevo); // UPDATE en SQLite
      await HistorialService.registrar('${reporte.tipo} marcado como $nuevo');
      // Si el reporte ya estaba en el servidor, también le avisamos a PostgreSQL (PUT).
      // Si no hay conexión, el cambio queda guardado en el teléfono y seguimos.
      var aviso = '';
      if (reporte.servidorId != null) {
        try {
          await ApiService.actualizarEstado(reporte.servidorId!, nuevo);
          await HistorialService.registrar('Estado actualizado en el servidor: $nuevo');
        } catch (e) {
          aviso = ' (no se pudo avisar al servidor)';
        }
      }
      if (!context.mounted) return;
      _mensaje(context, 'Marcado como $nuevo$aviso');
      Navigator.pop(context); // regresamos a la lista, que se recarga sola
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, 'Error al actualizar: $e');
    }
  }

  // Manda al servidor un reporte que no se pudo enviar al guardarlo
  Future<void> _enviar(BuildContext context, Reporte reporte) async {
    try {
      final idServidor = await ApiService.enviarReporte(reporte); // POST
      await DBHelper.marcarEnviado(reporte.id!, idServidor); // UPDATE enviado = 1
      await HistorialService.registrar(
          'Reporte enviado al servidor (id $idServidor)');
      if (!context.mounted) return;
      _mensaje(context, 'Enviado al servidor');
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Muestra cómo se guarda el reporte (serializado en JSON)
  void _verJson(BuildContext context, Reporte reporte) {
    // withIndent('  ') = lo acomoda con sangría para que se lea fácil
    final json = const JsonEncoder.withIndent('  ').convert(reporte.toMap());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datos guardados (JSON)'),
        // SelectableText deja copiar el texto; el scroll por si es largo
        content: SingleChildScrollView(child: SelectableText(json)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // cierra el diálogo
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Borra el reporte de SQLite
  Future<void> _eliminar(BuildContext context, Reporte reporte) async {
    try {
      await DBHelper.eliminar(reporte.id!); // DELETE en SQLite
      await HistorialService.registrar('Reporte eliminado: ${reporte.tipo}');
      if (!context.mounted) return;
      Navigator.pop(context); // regresamos a la lista
    } catch (e) {
      if (!context.mounted) return;
      _mensaje(context, 'Error al eliminar: $e');
    }
  }

  // Atajo para mostrar un mensajito abajo (SnackBar)
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
        title: Text(reporte.tipo), // el título es el tipo de problema
        // actions = botones a la derecha de la barra
        actions: [
          IconButton(
            tooltip: 'Ver datos en JSON', // texto que sale si dejas presionado
            icon: const Icon(Icons.data_object), // el ícono { }
            onPressed: () => _verJson(context, reporte),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminar(context, reporte),
          ),
        ],
      ),
      // ListView para que se pueda hacer scroll si no cabe todo
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mismo tag que en la lista, para que funcione la animación Hero
          Hero(
            tag: 'foto${reporte.id}',
            child: reporte.imagen != null
                ? FotoReporte(reporte: reporte, tamano: 320) // foto grande
                : Icon(iconoDeTipo(reporte.tipo), size: 120), // o ícono grande
          ),
          const SizedBox(height: 16),
          // Row acomoda las cosas una al lado de otra
          Row(
            children: [
              EstadoChip(estado: reporte.estado),
              const SizedBox(width: 12),
              Text(reporte.fecha, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          // ---- Sección: descripción ----
          const Text('Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(reporte.descripcion, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          // ---- Sección: detalles (los datos del paso 4 del formulario) ----
          const Text('Detalles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Urgencia: ${reporte.urgencia} de 5 - ${Reporte.textoUrgencia(reporte.urgencia)}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colorDeUrgencia(reporte.urgencia)),
          ),
          if (reporte.referencia != null) Text('Referencia: ${reporte.referencia}'),
          Text('¿Es peligroso?: ${reporte.peligroso ? 'Sí' : 'No'}'),
          if (reporte.fechaVisto != null) Text('Lo viste el: ${reporte.fechaVisto}'),
          const SizedBox(height: 24),
          // ---- Sección: ubicación ----
          const Text('Ubicación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Si tiene coordenadas mostramos el botón del mapa, si no, un aviso
          if (reporte.latitud != null) ...[
            Text(
              // toStringAsFixed(5) = solo 5 decimales
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
          // ---- Sección: cambiar estado ----
          const Text('¿Ya lo arreglaron?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: () => _cambiarEstado(context, reporte),
            // El ícono y el texto cambian según el estado actual
            icon: Icon(reporte.resuelto ? Icons.undo : Icons.check),
            label: Text(
              reporte.resuelto ? 'Marcar como pendiente' : 'Marcar como resuelto',
            ),
          ),
          const SizedBox(height: 24),
          // ---- Sección: servidor web ----
          const Text('Servidor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Si ya se mandó, lo decimos; si no, botón para intentarlo otra vez
          if (reporte.enviado)
            const Row(children: [
              Icon(Icons.cloud_done, color: Colors.green),
              SizedBox(width: 8),
              Text('Ya está en el servidor'),
            ])
          else
            OutlinedButton.icon(
              onPressed: () => _enviar(context, reporte),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Enviar al servidor'),
            ),
        ],
      ),
    );
  }
}
