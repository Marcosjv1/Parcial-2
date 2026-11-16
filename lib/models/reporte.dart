// dart:convert trae jsonEncode y jsonDecode para trabajar con JSON
import 'dart:convert';

// ============================================================
// MODELO — La clase Reporte es "el molde" de un problema en la calle.
// Cada vez que reportas algo, se crea un objeto Reporte con estos datos.
// Aquí NO hay pantallas ni base de datos, solo los datos y cómo
// convertirlos a otro formato (Map / JSON) para poder guardarlos.
// ============================================================
class Reporte {
  // El "?" significa que puede ser null (vacío)
  int? id; // lo asigna SQLite automáticamente, por eso al crear el reporte va vacío
  String tipo; // Bache, Luminaria apagada, Basura...
  String descripcion; // lo que escribiste o dictaste
  String fecha; // la guardamos como texto, ej. "15/11/2026 20:30"
  String estado; // 'Pendiente' o 'Resuelto'
  String? imagen; // ruta de la foto en el teléfono (puede no tener foto)
  double? latitud; // coordenadas GPS de dónde está el problema
  double? longitud; // (pueden ser null si el GPS falló)

  // Los tipos de problema que se pueden reportar (salen en el menú del formulario).
  // Es static porque es la misma lista para todos los reportes.
  static const List<String> tipos = [
    'Bache',
    'Luminaria apagada',
    'Basura',
    'Fuga de agua',
    'Otro',
  ];

  // Constructor: así se crea un Reporte nuevo.
  // "required" = obligatorio pasarlo; los demás son opcionales.
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

  // Getter: un atajo para preguntar "¿ya está resuelto?" sin comparar textos cada vez
  bool get resuelto => estado == 'Resuelto';

  // toMap: pasa el Reporte a un Map (clave: valor), que es básicamente un JSON.
  // SQLite no entiende objetos de Dart, pero sí un Map. Por eso lo usamos al guardar.
  // Cada clave tiene que llamarse igual que la columna de la tabla.
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
  // "factory" es un constructor que puede hacer cosas antes de crear el objeto.
  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'] as int?, // "as" le dice a Dart de qué tipo es el dato
      tipo: map['tipo'] as String,
      descripcion: map['descripcion'] as String,
      fecha: map['fecha'] as String,
      estado: map['estado'] as String? ?? 'Pendiente', // "??" = si viene null, usa 'Pendiente'
      imagen: map['imagen'] as String?,
      // "as num" acepta 21 o 21.04; luego lo pasamos a double
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
    );
  }

  // toJson / fromJson: lo mismo, pero en texto JSON ("serializar").
  // Lo usamos en el detalle con el botón { } para enseñar cómo se guardan los datos.
  String toJson() => jsonEncode(toMap()); // Map -> texto JSON

  // texto JSON -> Map -> Reporte
  factory Reporte.fromJson(String json) {
    return Reporte.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
