import 'geo_point.dart';

/// Entidad principal del dominio: una entrada del diario.
///
/// Contiene el texto del día y sus metadatos: ruta de la imagen y
/// coordenadas GPS donde se guardó. Es inmutable; para "modificarla" se usa
/// [copyWith].
class DiaryEntry {
  const DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imagePath,
    this.location,
  });

  /// Identificador asignado por SQLite (null mientras no se ha guardado).
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;

  /// Ruta local (en el almacenamiento de la app) de la foto del día.
  final String? imagePath;

  /// Posición GPS capturada al guardar la entrada.
  final GeoPoint? location;

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasLocation => location != null;

  // ---------------------------------------------------------------------
  // Serialización para SQLite. Los nombres de columna viven aquí para que
  // el modelo y la tabla no se desincronicen.
  // ---------------------------------------------------------------------
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colCreatedAt = 'created_at';
  static const String colImagePath = 'image_path';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';

  /// Convierte la entidad a un `Map` que SQLite puede insertar.
  Map<String, Object?> toMap() => {
        if (id != null) colId: id,
        colTitle: title,
        colContent: content,
        colCreatedAt: createdAt.millisecondsSinceEpoch,
        colImagePath: imagePath,
        colLatitude: location?.latitude,
        colLongitude: location?.longitude,
      };

  /// Construye la entidad a partir de una fila de SQLite.
  factory DiaryEntry.fromMap(Map<String, Object?> map) {
    final lat = map[colLatitude] as num?;
    final lng = map[colLongitude] as num?;
    return DiaryEntry(
      id: map[colId] as int?,
      title: map[colTitle] as String? ?? '',
      content: map[colContent] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map[colCreatedAt] as int),
      imagePath: map[colImagePath] as String?,
      location: (lat != null && lng != null)
          ? GeoPoint(lat.toDouble(), lng.toDouble())
          : null,
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? imagePath,
    GeoPoint? location,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      location: location ?? this.location,
    );
  }

  @override
  String toString() => 'DiaryEntry(id: $id, title: $title)';
}
