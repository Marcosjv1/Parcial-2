// dart:convert trae jsonEncode y jsonDecode para trabajar con JSON
import 'dart:convert';

// ============================================================
// MODELO — La clase Reporte es "el molde" de un problema en la calle.
// Cada vez que reportas algo, se crea un objeto Reporte con estos datos.
// Aquí NO hay pantallas ni base de datos, solo los datos y cómo
// convertirlos a otro formato (Map / JSON) para poder guardarlos.
// SOLID (S - Responsabilidad única): esta clase solo guarda los datos y
// sabe convertirse a Map/JSON. No dibuja nada ni toca la base de datos.
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

  // ---- Campos nuevos del proyecto final ----
  int urgencia; // qué tan urgente es, de 1 (poco) a 5 (muchísimo): entrada numérica (slider)
  String? referencia; // referencia del lugar, ej. "frente a la tienda" (texto, opcional)
  bool peligroso; // ¿es peligroso? (campo lógico: sí / no)
  String? fechaVisto; // cuándo lo vio el usuario, ej. "2026-11-20" (selector de fecha)
  bool enviado; // ¿ya se mandó al servidor web?
  int? servidorId; // el id que le dio PostgreSQL (sirve para avisarle cuando se resuelve)
  String? fotoUrl; // dirección de la foto en el servidor (solo en reportes que vienen de la web)

  // Regla de negocio: la urgencia va de 1 a 5
  static const int urgenciaMinima = 1;
  static const int urgenciaMaxima = 5;

  // Los tipos de problema que se pueden reportar (salen en el menú del formulario).
  // SOLID (O - Abierto/cerrado): para agregar un tipo nuevo solo se añade aquí,
  // sin modificar las pantallas.
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
    this.urgencia = 3, // por defecto, urgencia media
    this.referencia,
    this.peligroso = false,
    this.fechaVisto,
    this.enviado = false,
    this.servidorId,
    this.fotoUrl,
  });

  // Texto de la urgencia para mostrarla en pantalla
  static String textoUrgencia(int nivel) {
    const textos = ['', 'Muy baja', 'Baja', 'Media', 'Alta', 'Muy alta'];
    return textos[nivel.clamp(1, 5)];
  }

  // Getter: un atajo para preguntar "¿ya está resuelto?" sin comparar textos cada vez
  bool get resuelto => estado == 'Resuelto';

  // toMap: pasa el Reporte a un Map (clave: valor), que es básicamente un JSON.
  // SQLite no entiende objetos de Dart, pero sí un Map. Por eso lo usamos al guardar.
  // Cada clave tiene que llamarse igual que la columna de la tabla.
  // SQLite no tiene tipo bool, por eso true/false se guardan como 1/0.
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
      'urgencia': urgencia,
      'referencia': referencia,
      'peligroso': peligroso ? 1 : 0,
      'fecha_visto': fechaVisto,
      'enviado': enviado ? 1 : 0,
      'servidor_id': servidorId,
    };
  }

  // fromMap: lo contrario. Agarra una fila que viene de SQLite (o del servidor)
  // y la vuelve a convertir en un objeto Reporte que la app sí puede usar.
  // "factory" es un constructor que puede hacer cosas antes de crear el objeto.
  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'] as int?, // "as" le dice a Dart de qué tipo es el dato
      tipo: map['tipo'] as String,
      descripcion: map['descripcion'] as String,
      fecha: map['fecha'] as String? ?? '',
      estado: map['estado'] as String? ?? 'Pendiente', // "??" = si viene null, usa 'Pendiente'
      imagen: map['imagen'] as String?,
      // "as num" acepta 21 o 21.04; luego lo pasamos a double
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      urgencia: (map['urgencia'] as num?)?.toInt() ?? 3,
      referencia: map['referencia'] as String?,
      peligroso: _aBool(map['peligroso']),
      fechaVisto: map['fecha_visto'] as String?,
      enviado: _aBool(map['enviado']),
      servidorId: (map['servidor_id'] as num?)?.toInt(),
    );
  }

  // SQLite manda 1/0 y el servidor manda true/false: esto acepta los dos
  static bool _aBool(dynamic valor) => valor == true || valor == 1;

  // toApi: el JSON que se le manda al servicio web (Node.js).
  // Aquí sí van true/false, y no se manda la foto ni el id local.
  Map<String, dynamic> toApi() {
    return {
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': fecha,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
      'urgencia': urgencia,
      'referencia': referencia,
      'peligroso': peligroso,
      'fecha_visto': fechaVisto,
    };
  }

  // toJson / fromJson: lo mismo, pero en texto JSON ("serializar").
  // Lo usamos en el detalle con el botón { } para enseñar cómo se guardan los datos.
  String toJson() => jsonEncode(toMap()); // Map -> texto JSON

  // texto JSON -> Map -> Reporte
  factory Reporte.fromJson(String json) {
    return Reporte.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
