import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Servicio para tomar una foto con la cámara o elegirla de la galería
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

    // Copiamos la foto a la carpeta de la app para que no se borre
    final carpeta = await getApplicationDocumentsDirectory();
    final nombre = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final nuevaRuta = join(carpeta.path, nombre);
    await File(foto.path).copy(nuevaRuta);
    return nuevaRuta;
  }
}
