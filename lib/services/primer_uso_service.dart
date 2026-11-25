// dart:io para leer/escribir el archivo
import 'dart:io';

// path_provider nos da la carpeta propia de la app
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

// ============================================================
// PRIMER USO — Sirve para mostrar la pantalla de bienvenida solo
// la primera vez. Guarda una marca en un archivo plano chiquito
// (bienvenida_vista.txt); si el archivo existe, ya la vio.
// SOLID (S): este servicio solo sabe de esa marca.
// ============================================================
class PrimerUsoService {
  static Future<File> _archivo() async {
    final carpeta = await getApplicationDocumentsDirectory();
    return File(join(carpeta.path, 'bienvenida_vista.txt'));
  }

  // ¿Ya vio la bienvenida?
  static Future<bool> yaVioBienvenida() async {
    try {
      return await (await _archivo()).exists();
    } catch (_) {
      return true; // si algo falla, mejor no estorbar al usuario
    }
  }

  // Marca que ya la vio
  static Future<void> marcarVista() async {
    try {
      await (await _archivo()).writeAsString('visto');
    } catch (_) {
      // no es grave si no se puede guardar
    }
  }
}
