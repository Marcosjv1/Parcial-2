import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/reporte.dart';
import '../widgets/reporte_widgets.dart';

// ============================================================
// PANTALLA: GALERÍA (cuadrícula)
// Muestra los reportes del teléfono en una cuadrícula de 2 columnas
// con GridView.builder, que hace scroll solo y dibuja únicamente
// las tarjetas que se ven en pantalla.
// Al tocar una, se abre el detalle (le pasamos el reporte).
// ============================================================
class GaleriaScreen extends StatefulWidget {
  const GaleriaScreen({super.key});

  @override
  State<GaleriaScreen> createState() => _GaleriaScreenState();
}

class _GaleriaScreenState extends State<GaleriaScreen> {
  late Future<List<Reporte>> _reportes; // la lista que llegará de SQLite

  @override
  void initState() {
    super.initState();
    _reportes = DBHelper.obtenerTodos();
  }

  Future<void> _abrir(Reporte reporte) async {
    // Pasamos el reporte a la pantalla de detalle con "arguments"
    await Navigator.pushNamed(context, '/detalle', arguments: reporte);
    setState(() => _reportes = DBHelper.obtenerTodos()); // por si cambió algo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galería')),
      body: FutureBuilder<List<Reporte>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }
          final reportes = snapshot.data ?? [];
          if (reportes.isEmpty) {
            return const Center(child: Text('Todavía no hay reportes'));
          }
          // GridView.builder: cuadrícula con scroll automático
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reportes.length,
            // 2 columnas, un poco más altas que anchas
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, i) {
              final reporte = reportes[i];
              return InkWell(
                onTap: () => _abrir(reporte),
                child: Card(
                  clipBehavior: Clip.antiAlias, // recorta la foto a las esquinas redondas
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // La foto ocupa todo el espacio que sobra arriba
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, medidas) => FotoReporte(
                            reporte: reporte,
                            tamano: medidas.maxWidth,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Ícono rojo si es peligroso
                            if (reporte.peligroso)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.warning, color: Colors.red, size: 18),
                              ),
                            Expanded(
                              child: Text(
                                reporte.tipo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
