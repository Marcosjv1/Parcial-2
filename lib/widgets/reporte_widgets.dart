// dart:io para File (leer la foto guardada)
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/reporte.dart';

// ============================================================
// WIDGETS REUTILIZABLES — Piezas de pantalla que se usan en varios
// lugares (la lista y el detalle). Así no repetimos el mismo código.
// SOLID (S): cada widget hace una sola cosa (ícono, etiqueta o foto).
// ============================================================

// Un ícono distinto para cada tipo de problema
IconData iconoDeTipo(String tipo) {
  // switch = según el texto del tipo, regresa un ícono diferente
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
      return Icons.report_problem_outlined; // para "Otro"
  }
}

// La ilustración (imagen de assets) de cada tipo de problema
String imagenDeTipo(String tipo) {
  switch (tipo) {
    case 'Bache':
      return 'assets/images/tipos/bache.png';
    case 'Luminaria apagada':
      return 'assets/images/tipos/lampara.png';
    case 'Basura':
      return 'assets/images/tipos/basura.png';
    case 'Fuga de agua':
      return 'assets/images/tipos/fuga.png';
    default:
      return 'assets/images/tipos/otro.png';
  }
}

// Color de la urgencia: del verde (1) al rojo (5), como un semáforo
Color colorDeUrgencia(int nivel) {
  const colores = [
    Colors.grey, // posición 0 no se usa
    Color(0xFF43A047), // 1 verde
    Color(0xFF9CCC65), // 2 verde claro
    Color(0xFFFFB300), // 3 amarillo
    Color(0xFFF57C00), // 4 naranja
    Color(0xFFE53935), // 5 rojo
  ];
  return colores[nivel.clamp(1, 5)];
}

// Etiquetita de color con el estado: naranja = Pendiente, verde = Resuelto
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.estado});

  final String estado; // el texto que va dentro de la etiqueta

  @override
  Widget build(BuildContext context) {
    final resuelto = estado == 'Resuelto';
    // Chip = la etiquetita redondeada de Material
    return Chip(
      label: Text(estado),
      // El "? :" es un if cortito: si está resuelto palomita verde, si no reloj naranja
      avatar: Icon(
        resuelto ? Icons.check_circle : Icons.schedule,
        size: 18,
        color: resuelto ? Colors.green : Colors.orange,
      ),
      visualDensity: VisualDensity.compact, // más chiquita para que quepa en la lista
    );
  }
}

// La foto del reporte (o el ícono del tipo si no tiene foto).
// Se usa dentro de un Hero en la lista y en el detalle.
class FotoReporte extends StatelessWidget {
  const FotoReporte({super.key, required this.reporte, required this.tamano});

  final Reporte reporte;
  final double tamano; // 56 en la lista, 320 en el detalle

  @override
  Widget build(BuildContext context) {
    // Si no tiene foto, ponemos la ilustración del tipo de problema
    if (reporte.imagen == null) return _ilustracion();
    // ClipRRect redondea las esquinas de la foto
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      // Image.file lee la foto desde la ruta guardada en SQLite
      child: Image.file(
        File(reporte.imagen!),
        width: tamano,
        height: tamano,
        fit: BoxFit.cover, // la recorta para llenar el cuadro sin deformarse
        // Si la foto se borró del teléfono, mostramos el ícono en vez de tronar
        errorBuilder: (context, error, stack) => _ilustracion(),
      ),
    );
  }

  // La imagen del tipo (bache, lámpara, basura...) en lugar de la foto
  Widget _ilustracion() {
    return Image.asset(imagenDeTipo(reporte.tipo), width: tamano, height: tamano);
  }
}
