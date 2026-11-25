import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../services/api_service.dart';
import '../widgets/reporte_widgets.dart';

// ============================================================
// PANTALLA: REPORTES DE LA CIUDAD (comunicación web)
// Consulta los reportes guardados en la base de datos PostgreSQL
// del servidor (GET /api/reportes) y los muestra en una lista.
// Se puede jalar hacia abajo para recargar (RefreshIndicator).
// ============================================================
class CiudadScreen extends StatefulWidget {
  const CiudadScreen({super.key});

  @override
  State<CiudadScreen> createState() => _CiudadScreenState();
}

class _CiudadScreenState extends State<CiudadScreen> {
  late Future<List<Reporte>> _reportes; // la lista que llegará del servidor

  @override
  void initState() {
    super.initState();
    _reportes = ApiService.obtenerReportes();
  }

  // Vuelve a pedir la lista al servidor
  Future<void> _recargar() async {
    setState(() => _reportes = ApiService.obtenerReportes());
    await _reportes.catchError((_) => <Reporte>[]); // para que el circulito termine
  }

  // Muestra todos los datos de un reporte del servidor en una hoja de abajo
  void _verDetalle(Reporte r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // para que quepa la foto grande
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La foto que se subió al servidor (si tiene)
            if (r.fotoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(r.fotoUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, st) => const SizedBox(height: 0)),
              ),
              const SizedBox(height: 12),
            ],
            Text(r.tipo,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            EstadoChip(estado: r.estado),
            const SizedBox(height: 12),
            Text(r.descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Reportado: ${r.fecha}'),
            if (r.fechaVisto != null) Text('Visto el: ${r.fechaVisto}'),
            Text(
              'Urgencia: ${r.urgencia} de 5 - ${Reporte.textoUrgencia(r.urgencia)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: colorDeUrgencia(r.urgencia)),
            ),
            if (r.referencia != null) Text('Referencia: ${r.referencia}'),
            Text('¿Es peligroso?: ${r.peligroso ? 'Sí' : 'No'}'),
            if (r.latitud != null)
              Text('Ubicación: ${r.latitud!.toStringAsFixed(5)}, '
                  '${r.longitud!.toStringAsFixed(5)}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de la ciudad'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
          ),
        ],
      ),
      body: FutureBuilder<List<Reporte>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Si el servidor está apagado, lo explicamos y dejamos reintentar
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _recargar, child: const Text('Reintentar')),
                  ],
                ),
              ),
            );
          }
          final reportes = snapshot.data ?? [];
          // RefreshIndicator: jalar la lista hacia abajo la recarga
          return RefreshIndicator(
            onRefresh: _recargar,
            child: reportes.isEmpty
                ? ListView(children: [
                    const SizedBox(height: 120),
                    Image.asset('assets/images/vacio.png', height: 180),
                    const SizedBox(height: 12),
                    const Center(
                        child: Text('El servidor no tiene reportes todavía')),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: reportes.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            '${reportes.length} reporte(s) en el servidor',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      final r = reportes[i - 1];
                      return Card(
                        child: ListTile(
                          // Foto del servidor; si no tiene, la ilustración del tipo
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: r.fotoUrl != null
                                ? Image.network(r.fotoUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, st) =>
                                        Image.asset(imagenDeTipo(r.tipo), width: 56))
                                : Image.asset(imagenDeTipo(r.tipo), width: 56),
                          ),
                          title: Row(children: [
                            Text(r.tipo),
                            if (r.peligroso) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.warning, color: Colors.red, size: 18),
                            ],
                          ]),
                          subtitle: Text('${r.fecha}\n${r.descripcion}',
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          isThreeLine: true,
                          trailing: EstadoChip(estado: r.estado),
                          onTap: () => _verDetalle(r),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
