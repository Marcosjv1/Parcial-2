import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/reporte.dart';
import '../widgets/reporte_widgets.dart';
import '../tema.dart';

// ============================================================
// PANTALLA 2: INICIO (la lista de reportes)
// Tiene la estructura que pide el profe:
//   - Scaffold: el "marco" de la pantalla
//   - AppBar:   la barra de arriba con el título
//   - Drawer:   el menú lateral (botón de 3 rayitas)
//   - FutureBuilder: carga los reportes de SQLite sin congelar la app
// ============================================================
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Un Future es "una respuesta que llegará después". Leer SQLite tarda
  // un poquito, así que guardamos la promesa aquí y el FutureBuilder
  // se encarga de esperar y redibujar cuando lleguen los datos.
  // "late" = le damos valor después, en initState.
  late Future<List<Reporte>> _reportes;

  @override
  void initState() {
    super.initState();
    _reportes = DBHelper.obtenerTodos(); // primera carga de la lista al abrir la pantalla
  }

  // Vuelve a leer la base de datos y redibuja la lista
  void _recargar() {
    setState(() {
      _reportes = DBHelper.obtenerTodos();
    });
  }

  Future<void> _irANuevoReporte() async {
    // Esperamos a que el usuario regrese del formulario y recargamos
    await Navigator.pushNamed(context, '/nuevo');
    _recargar(); // así aparece el reporte que acaba de guardar
  }

  Future<void> _irADetalle(Reporte reporte) async {
    // Mandamos el reporte como argumento a la pantalla de detalle
    await Navigator.pushNamed(context, '/detalle', arguments: reporte);
    _recargar(); // por si lo marcó como resuelto o lo borró
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis reportes')), // barra de arriba
      drawer: _menuLateral(), // al poner drawer, el AppBar muestra solito el botón de 3 rayitas
      // Botón flotante de abajo a la derecha
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irANuevoReporte,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Reportar'),
      ),
      // FutureBuilder: según cómo vaya el Future, muestra algo distinto:
      //   esperando -> circulito de carga
      //   error     -> mensaje de error
      //   listo     -> la lista (o un mensaje si está vacía)
      body: FutureBuilder<List<Reporte>>(
        future: _reportes, // el Future al que le está "echando ojo"
        // snapshot = cómo va el Future en este momento
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // todavía cargando
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }

          final reportes = snapshot.data ?? []; // si viene null, usamos lista vacía
          if (reportes.isEmpty) {
            // Si no hay reportes, explicamos cómo funciona la app
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_road, size: 80, color: azulApp),
                  SizedBox(height: 16),
                  Text(
                    'Aún no has reportado nada',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '¿Viste un bache, una lámpara apagada o basura?\n\n'
                    '1. Toca "Reportar"\n'
                    '2. Toma una foto y describe el problema\n'
                    '3. Envíalo: guardamos dónde está',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Contamos cuántos siguen pendientes para mostrarlo arriba
          final pendientes = reportes.where((r) => !r.resuelto).length;

          // ListView.builder solo dibuja las tarjetas que se ven en pantalla (más eficiente)
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88), // espacio para que el botón no tape la última
            itemCount: reportes.length + 1, // +1 por el resumen de arriba
            itemBuilder: (context, i) {
              // El primer elemento es un resumen
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '${reportes.length} reporte(s) · $pendientes pendiente(s)\n'
                    'Toca uno para ver los detalles',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }
              final reporte = reportes[i - 1]; // -1 porque el 0 es el resumen
              // Card = tarjeta con sombrita; ListTile = renglón con ícono, título y subtítulo
              return Card(
                child: ListTile(
                  // Hero: la foto "vuela" a la pantalla de detalle.
                  // Funciona porque aquí y en el detalle usamos el MISMO tag.
                  leading: Hero(
                    tag: 'foto${reporte.id}',
                    child: FotoReporte(reporte: reporte, tamano: 56),
                  ),
                  title: Text(reporte.tipo),
                  subtitle: Text(
                    '${reporte.fecha}\n${reporte.descripcion}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // si es muy largo pone "..."
                  ),
                  isThreeLine: true,
                  trailing: EstadoChip(estado: reporte.estado), // etiqueta a la derecha
                  onTap: () => _irADetalle(reporte), // al tocar la tarjeta abre el detalle
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Menú lateral (Drawer)
  Widget _menuLateral() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // para que el encabezado llegue hasta arriba
        children: [
          // Encabezado azul del menú
          const DrawerHeader(
            decoration: BoxDecoration(color: azulApp),
            child: Text(
              'ReportaCalle\nReporta problemas de tu ciudad',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Mis reportes'),
            onTap: () => Navigator.pop(context), // solo cierra el menú (ya estamos aquí)
          ),
          ListTile(
            leading: const Icon(Icons.add_a_photo),
            title: const Text('Nuevo reporte'),
            onTap: () {
              Navigator.pop(context); // primero cerramos el menú
              _irANuevoReporte(); // y luego abrimos el formulario
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              // Regresa al login y borra todas las pantallas anteriores
              // ((ruta) => false significa "no dejes ninguna")
              Navigator.pushNamedAndRemoveUntil(context, '/', (ruta) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              // showAboutDialog es un diálogo que ya trae Flutter hecho
              showAboutDialog(
                context: context,
                applicationName: 'ReportaCalle',
                applicationVersion: '1.0',
                children: const [
                  Text(
                    'Reporta baches, luminarias apagadas, basura y fugas '
                    'con foto, descripción por voz y ubicación GPS.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
