import 'dart:convert';

// ============================================================
// MODELO — La clase Entrada es "el molde" de un día del diario.
// Cada vez que guardas algo, se crea un objeto Entrada con estos datos.
// Aquí NO hay pantallas ni base de datos, solo los datos y cómo
// convertirlos a otro formato (Map / JSON) para poder guardarlos.
// ============================================================
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

  // toMap: pasa la Entrada a un Map (clave: valor), que es básicamente un JSON.
  // SQLite no entiende objetos de Dart, pero sí un Map. Por eso lo usamos al guardar.
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

  // fromMap: lo contrario. Agarra una fila que viene de SQLite (un Map)
  // y la vuelve a convertir en un objeto Entrada que la app sí puede usar.
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

  // toJson / fromJson: lo mismo, pero en texto JSON ("serializar").
  // Lo usamos en el detalle con el botón { } para enseñar cómo se guardan los datos.
  String toJson() => jsonEncode(toMap());

  factory Entrada.fromJson(String json) {
    return Entrada.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
