import 'dart:convert';

// ============================================================
// MODELO — La clase Reporte es "el molde" de un problema en la calle.
// Cada vez que reportas algo, se crea un objeto Reporte con estos datos.
// Aquí NO hay pantallas ni base de datos, solo los datos y cómo
// convertirlos a otro formato (Map / JSON) para poder guardarlos.
// ============================================================
class Reporte {
  int? id; // lo asigna SQLite automáticamente
  String tipo; // Bache, Luminaria apagada, Basura...
  String descripcion; // lo que escribiste o dictaste
  String fecha;
  String estado; // 'Pendiente' o 'Resuelto'
  String? imagen; // ruta de la foto en el teléfono
  double? latitud; // coordenadas GPS de dónde está el problema
  double? longitud;

  // Los tipos de problema que se pueden reportar (salen en el menú del formulario)
  static const List<String> tipos = [
    'Bache',
    'Luminaria apagada',
    'Basura',
    'Fuga de agua',
    'Otro',
  ];

  Reporte({
    this.id,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    this.estado = 'Pendiente', // todo reporte nuevo empieza pendiente
    this.imagen,
    this.latitud,
    this.longitud,
  });

  bool get resuelto => estado == 'Resuelto';

  // toMap: pasa el Reporte a un Map (clave: valor), que es básicamente un JSON.
  // SQLite no entiende objetos de Dart, pero sí un Map. Por eso lo usamos al guardar.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': fecha,
      'estado': estado,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  // fromMap: lo contrario. Agarra una fila que viene de SQLite (un Map)
  // y la vuelve a convertir en un objeto Reporte que la app sí puede usar.
  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      descripcion: map['descripcion'] as String,
      fecha: map['fecha'] as String,
      estado: map['estado'] as String? ?? 'Pendiente',
      imagen: map['imagen'] as String?,
      // "as num" acepta 21 o 21.04; luego lo pasamos a double
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
    );
  }

  // toJson / fromJson: lo mismo, pero en texto JSON ("serializar").
  // Lo usamos en el detalle con el botón { } para enseñar cómo se guardan los datos.
  String toJson() => jsonEncode(toMap());

  factory Reporte.fromJson(String json) {
    return Reporte.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
