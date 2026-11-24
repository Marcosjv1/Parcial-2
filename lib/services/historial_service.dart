// dart:io trae File para leer y escribir archivos
import 'dart:io';

// join() para armar la ruta del archivo
import 'package:path/path.dart';
// path_provider nos dice cuál es la carpeta propia de la app
import 'package:path_provider/path_provider.dart';

// ============================================================
// ARCHIVO PLANO — historial.txt
// Además de SQLite, la app guarda un historial de lo que hace el usuario
// en un archivo de texto normal (un renglón por acción), por ejemplo:
//   24/11/2026 16:40 | Reporte guardado: Bache
// SOLID (S): esta clase solo se encarga de ese archivo.
// ============================================================
class HistorialService {
  static const String nombreArchivo = 'historial.txt';

  // Regresa el archivo dentro de la carpeta de documentos de la app
  static Future<File> _archivo() async {
    final carpeta = await getApplicationDocumentsDirectory();
    return File(join(carpeta.path, nombreArchivo));
  }

  // Agrega un renglón al final del archivo (si no existe, lo crea)
  static Future<void> registrar(String accion) async {
    try {
      final ahora = DateTime.now();
      // padLeft(2, '0') hace que 5 se vea "05"
      String dos(int n) => n.toString().padLeft(2, '0');
      final fecha =
          '${dos(ahora.day)}/${dos(ahora.month)}/${ahora.year} ${dos(ahora.hour)}:${dos(ahora.minute)}';
      final archivo = await _archivo();
      // FileMode.append = escribir al final sin borrar lo que ya había
      await archivo.writeAsString('$fecha | $accion\n', mode: FileMode.append);
    } catch (e) {
      // Si falla el historial no pasa nada grave: la app sigue funcionando
    }
  }

  // Lee todos los renglones, el más nuevo primero
  static Future<List<String>> leer() async {
    final archivo = await _archivo();
    if (!await archivo.exists()) return []; // todavía no hay historial
    final lineas = await archivo.readAsLines();
    // quitamos renglones vacíos y volteamos la lista (el último arriba)
    return lineas.where((l) => l.trim().isNotEmpty).toList().reversed.toList();
  }

  // Borra el archivo completo
  static Future<void> borrar() async {
    final archivo = await _archivo();
    if (await archivo.exists()) await archivo.delete();
  }
}
