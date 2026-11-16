import 'dart:io';

import 'package:flutter/material.dart';

import '../models/reporte.dart';

// ============================================================
// WIDGETS REUTILIZABLES — Piezas de pantalla que se usan en varios
// lugares (la lista y el detalle). Así no repetimos el mismo código.
// ============================================================

// Un ícono distinto para cada tipo de problema
IconData iconoDeTipo(String tipo) {
  switch (tipo) {
    case 'Bache':
      return Icons.warning_amber;
    case 'Luminaria apagada':
      return Icons.lightbulb_outline;
    case 'Basura':
      return Icons.delete_outline;
    case 'Fuga de agua':
      return Icons.water_drop_outlined;
    default:
      return Icons.report_problem_outlined;
  }
}

// Etiquetita de color con el estado: naranja = Pendiente, verde = Resuelto
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final resuelto = estado == 'Resuelto';
    return Chip(
      label: Text(estado),
      avatar: Icon(
        resuelto ? Icons.check_circle : Icons.schedule,
        size: 18,
        color: resuelto ? Colors.green : Colors.orange,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

// La foto del reporte (o el ícono del tipo si no tiene foto).
// Se usa dentro de un Hero en la lista y en el detalle.
class FotoReporte extends StatelessWidget {
  const FotoReporte({super.key, required this.reporte, required this.tamano});

  final Reporte reporte;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    if (reporte.imagen == null) {
      return SizedBox(
        width: tamano,
        height: tamano,
        child: Icon(iconoDeTipo(reporte.tipo), size: tamano * 0.6),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(reporte.imagen!),
        width: tamano,
        height: tamano,
        fit: BoxFit.cover,
        // Si la foto se borró del teléfono, mostramos el ícono en vez de tronar
        errorBuilder: (context, error, stack) =>
            Icon(iconoDeTipo(reporte.tipo), size: tamano * 0.6),
      ),
    );
  }
}
