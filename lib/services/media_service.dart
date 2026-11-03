import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/errors/app_exception.dart';

/// Abstracción del gadget multimedia (cámara y galería).
abstract class MediaService {
  /// Abre la cámara. Devuelve la ruta persistente de la foto o null si el
  /// usuario canceló.
  Future<String?> takePhoto();

  /// Abre la galería. Devuelve la ruta persistente o null si se canceló.
  Future<String?> pickFromGallery();

  /// Borra una imagen guardada por la app (al eliminar o descartar).
  Future<void> deleteImage(String path);
}

/// Implementación con el paquete `image_picker`.
///
/// Las fotos que entrega image_picker viven en una carpeta temporal que el
/// sistema puede limpiar; por eso se COPIAN a la carpeta de documentos de la
/// app y en SQLite se guarda esa ruta definitiva.
class ImagePickerMediaService implements MediaService {
  ImagePickerMediaService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const String _imagesFolder = 'diary_images';

  @override
  Future<String?> takePhoto() => _pick(ImageSource.camera);

  @override
  Future<String?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<String?> _pick(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600, // Reduce el peso sin perder calidad visible.
        imageQuality: 85,
      );
      if (file == null) return null; // El usuario canceló.
      return await _persist(file);
    } on PlatformException catch (e) {
      final what = source == ImageSource.camera ? 'la cámara' : 'la galería';
      throw MediaException(
        'No se pudo acceder a $what. Revisa los permisos. (${e.code})',
      );
    } catch (e) {
      throw MediaException('Error al obtener la imagen: $e');
    }
  }

  /// Copia la imagen a `<documentos>/diary_images/` y devuelve la nueva ruta.
  Future<String> _persist(XFile file) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docsDir.path, _imagesFolder));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final extension = p.extension(file.path).isEmpty
        ? '.jpg'
        : p.extension(file.path);
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destination = p.join(imagesDir.path, fileName);
    await file.saveTo(destination);
    return destination;
  }

  @override
  Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Si no se puede borrar el archivo no es crítico para el usuario:
      // la entrada ya fue eliminada de la base de datos.
    }
  }
}
