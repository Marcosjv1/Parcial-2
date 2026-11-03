import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/db_helper.dart';
import '../models/entrada.dart';

// Pantalla que muestra una entrada completa
class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key});

  // Abre Google Maps con las coordenadas guardadas
  Future<void> _abrirMapa(BuildContext context, Entrada entrada) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${entrada.latitud},${entrada.longitud}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el mapa: $e')),
      );
    }
  }

  Future<void> _eliminar(BuildContext context, Entrada entrada) async {
    try {
      await DBHelper.eliminar(entrada.id!);
      if (!context.mounted) return;
      Navigator.pop(context); // regresamos a la lista
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recibimos la entrada que nos mandó la pantalla de inicio
    final entrada = ModalRoute.of(context)!.settings.arguments as Entrada;

    return Scaffold(
      appBar: AppBar(
        title: Text(entrada.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminar(context, entrada),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mismo tag que en la lista, para que funcione la animación Hero
          Hero(
            tag: 'foto${entrada.id}',
            child: entrada.imagen != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(entrada.imagen!),
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.book, size: 120),
          ),
          const SizedBox(height: 16),
          Text(entrada.fecha, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(entrada.texto, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          if (entrada.latitud != null) ...[
            Text(
              'Ubicación: ${entrada.latitud!.toStringAsFixed(5)}, '
              '${entrada.longitud!.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _abrirMapa(context, entrada),
              icon: const Icon(Icons.map),
              label: const Text('Ver en Google Maps'),
            ),
          ] else
            const Text('Esta entrada no tiene ubicación'),
        ],
      ),
    );
  }
}
