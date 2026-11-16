// dart:io trae la clase File para copiar archivos
import 'dart:io';

// image_picker abre la cámara o la galería
import 'package:image_picker/image_picker.dart';
// join() para armar la ruta del archivo
import 'package:path/path.dart';
// path_provider nos dice cuál es la carpeta propia de la app
import 'package:path_provider/path_provider.dart';

// ============================================================
// GADGET 1: CÁMARA Y GALERÍA
// Usa el paquete image_picker, que abre la cámara o la galería del
// teléfono y nos regresa la foto que el usuario eligió.
// SOLID (S): un servicio por gadget. Este solo sabe de cámara y galería.
// ============================================================
class CamaraService {
  // El objeto que abre la cámara/galería
  static final ImagePicker _picker = ImagePicker();

  // Botón "Cámara": abre la cámara del teléfono
  static Future<String?> tomarFoto() {
    return _obtenerImagen(ImageSource.camera);
  }

  // Botón "Galería": abre las fotos que ya tienes
  static Future<String?> elegirDeGaleria() {
    return _obtenerImagen(ImageSource.gallery);
  }

  // Abre la cámara o la galería y regresa la ruta de la foto.
  // Las dos funciones de arriba usan esta para no repetir código.
  static Future<String?> _obtenerImagen(ImageSource origen) async {
    final XFile? foto = await _picker.pickImage(
      source: origen, // cámara o galería
      imageQuality: 80, // la comprimimos un poco para que no pese tanto
    );
    if (foto == null) return null; // el usuario canceló

    // OJO: image_picker deja la foto en una carpeta temporal que Android
    // puede limpiar cuando quiera. Por eso la copiamos a la carpeta propia
    // de la app y en SQLite guardamos ESA ruta (no la foto en sí).
    final carpeta = await getApplicationDocumentsDirectory();
    // Le ponemos de nombre la hora en milisegundos para que nunca se repita
    final nombre = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final nuevaRuta = join(carpeta.path, nombre);
    await File(foto.path).copy(nuevaRuta); // copiamos la foto a nuestra carpeta
    return nuevaRuta; // esta ruta es la que se guarda en el reporte
  }
}
