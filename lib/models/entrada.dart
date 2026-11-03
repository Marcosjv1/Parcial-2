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

  // Convierte la entrada a un Map para guardarla en SQLite
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

  // Crea una entrada a partir de una fila de SQLite
  factory Entrada.fromMap(Map<String, dynamic> map) {
    return Entrada(
      id: map['id'],
      titulo: map['titulo'],
      texto: map['texto'],
      fecha: map['fecha'],
      imagen: map['imagen'],
      latitud: map['latitud'],
      longitud: map['longitud'],
    );
  }
}
