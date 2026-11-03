/// Jerarquía de excepciones propias de la aplicación.
///
/// Cada capa traduce los errores técnicos (de SQLite, del GPS, del plugin
/// de cámara, etc.) a una de estas excepciones con un mensaje legible para
/// el usuario. Así la capa de presentación sólo necesita atrapar
/// [AppException] y mostrar [message], sin conocer detalles de cada plugin
/// (principio de Inversión de Dependencias).
class AppException implements Exception {
  const AppException(this.message);

  /// Mensaje en español, listo para mostrarse en un SnackBar o diálogo.
  final String message;

  @override
  String toString() => message;
}

/// Error al leer o escribir en la base de datos local (SQLite).
///
/// Se llama "Storage" para no chocar con `DatabaseException` de sqflite.
class StorageException extends AppException {
  const StorageException(super.message);
}

/// Error al obtener la posición GPS (permiso denegado, GPS apagado, timeout).
class LocationException extends AppException {
  const LocationException(super.message);
}

/// Error al usar la cámara o la galería.
class MediaException extends AppException {
  const MediaException(super.message);
}

/// Error al usar el micrófono o el reconocimiento de voz.
class SpeechException extends AppException {
  const SpeechException(super.message);
}

/// Error al abrir la aplicación de mapas externa.
class MapsException extends AppException {
  const MapsException(super.message);
}
