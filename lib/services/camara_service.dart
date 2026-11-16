import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// ============================================================
// GADGET 1: CÁMARA Y GALERÍA
// Usa el paquete image_picker, que abre la cámara o la galería del
// teléfono y nos regresa la foto que el usuario eligió.
// ============================================================
class CamaraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> tomarFoto() {
    return _obtenerImagen(ImageSource.camera);
  }

  static Future<String?> elegirDeGaleria() {
    return _obtenerImagen(ImageSource.gallery);
  }

  // Abre la cámara o la galería y regresa la ruta de la foto
  static Future<String?> _obtenerImagen(ImageSource origen) async {
    final XFile? foto = await _picker.pickImage(
      source: origen,
      imageQuality: 80,
    );
    if (foto == null) return null; // el usuario canceló

    // OJO: image_picker deja la foto en una carpeta temporal que Android
    // puede limpiar cuando quiera. Por eso la copiamos a la carpeta propia
    // de la app y en SQLite guardamos ESA ruta (no la foto en sí).
    final carpeta = await getApplicationDocumentsDirectory();
    final nombre = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final nuevaRuta = join(carpeta.path, nombre);
    await File(foto.path).copy(nuevaRuta);
    return nuevaRuta;
  }
}
