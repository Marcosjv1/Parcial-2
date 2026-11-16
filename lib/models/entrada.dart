import 'dart:convert';

// Modelo: representa una entrada (un día) del diario
class Entrada {
  int? id; // lo asigna SQLite automáticamente
  String titulo;
  String texto;
  String fecha;
  String? imagen; // ruta de la foto en el teléfono
  double? latitud; // coordenadas GPS
  double? longitud;

  Entrada({
    this.id,
    required this.titulo,
    required this.texto,
    required this.fecha,
    this.imagen,
    this.latitud,
    this.longitud,
  });

  // Convierte la entrada a un Map (formato JSON) para guardarla en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'texto': texto,
      'fecha': fecha,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  // Crea una entrada a partir de un Map (una fila de SQLite o un JSON)
  factory Entrada.fromMap(Map<String, dynamic> map) {
    return Entrada(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      texto: map['texto'] as String,
      fecha: map['fecha'] as String,
      imagen: map['imagen'] as String?,
      // "as num" acepta 21 o 21.04; luego lo pasamos a double
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
    );
  }

  // Serialización a texto JSON y de regreso
  String toJson() => jsonEncode(toMap());

  factory Entrada.fromJson(String json) {
    return Entrada.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
