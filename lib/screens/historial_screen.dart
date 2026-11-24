import 'package:flutter/material.dart';

import '../services/historial_service.dart';

// ============================================================
// PANTALLA: HISTORIAL (archivo plano)
// Lee el archivo historial.txt y muestra un renglón por acción,
// la más nueva arriba. También deja borrar el archivo.
// ============================================================
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<String>> _lineas; // los renglones del archivo

  @override
  void initState() {
    super.initState();
    _lineas = HistorialService.leer();
  }

  Future<void> _borrar() async {
    // Preguntamos antes de borrar
    final seguro = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar el historial?'),
        content: const Text('Se borra el archivo historial.txt. Tus reportes no se borran.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Borrar')),
        ],
      ),
    );
    if (seguro != true) return;
    await HistorialService.borrar();
    setState(() => _lineas = HistorialService.leer());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Borrar historial',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _borrar,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _lineas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('No se pudo leer el archivo: ${snapshot.error}'));
          }
          final lineas = snapshot.data ?? [];
          if (lineas.isEmpty) {
            return const Center(child: Text('El historial está vacío'));
          }
          return ListView.separated(
            itemCount: lineas.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              // Cada renglón es "fecha | acción": lo partimos en dos
              final partes = lineas[i].split(' | ');
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(partes.length > 1 ? partes[1] : lineas[i]),
                subtitle: Text(partes[0]),
              );
            },
          );
        },
      ),
    );
  }
}
