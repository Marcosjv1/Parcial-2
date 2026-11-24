// path nos ayuda a armar la ruta del archivo de la base de datos
import 'package:path/path.dart';
// sqflite es el paquete para usar SQLite en Flutter
import 'package:sqflite/sqflite.dart';

// Necesitamos el modelo para convertir filas <-> objetos Reporte
import '../models/reporte.dart';

// ============================================================
// BASE DE DATOS — DBHelper es el único que habla con SQLite.
// Las pantallas nunca tocan SQLite directo: le piden las cosas a DBHelper.
// SOLID (S): DBHelper solo se encarga de SQLite.
// SOLID (D - Inversión de dependencias): las pantallas dependen de DBHelper,
// no de sqflite directo; si cambiamos de base de datos, solo se cambia este archivo.
// ============================================================
class DBHelper {
  // Aquí guardamos la conexión abierta. Empieza en null (todavía no se abre).
  static Database? _db;

  // Abre la base de datos. La primera vez que se usa la app no existe,
  // así que onCreate crea la tabla "reportes" (como una hoja de Excel
  // con columnas: id, tipo, descripcion, fecha, estado, imagen, latitud, longitud,
  // tamano_cm, peligroso, fecha_visto y enviado).
  // Las siguientes veces solo la abre. Guardamos la conexión en _db
  // para no abrirla una y otra vez.
  static Future<Database> obtenerDB() async {
    if (_db != null) return _db!; // si ya estaba abierta, la regresamos tal cual

    // getDatabasesPath() = carpeta donde Android guarda las bases de datos de la app
    final ruta = join(await getDatabasesPath(), 'reportes.db');
    _db = await openDatabase(
      ruta,
      // Versión 2: el proyecto final agregó 4 columnas. Al subir el número,
      // en los teléfonos que ya tenían la versión 1 se corre onUpgrade.
      version: 2,
      // onCreate solo se ejecuta la PRIMERA vez (cuando el archivo no existe)
      onCreate: (db, version) async {
        // SQL normal para crear la tabla. AUTOINCREMENT = el id se pone solo (1, 2, 3...)
        // TEXT = texto, REAL = número con decimales, INTEGER = entero (y 1/0 para sí/no)
        await db.execute('''
          CREATE TABLE reportes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            descripcion TEXT,
            fecha TEXT,
            estado TEXT,
            imagen TEXT,
            latitud REAL,
            longitud REAL,
            tamano_cm INTEGER,
            peligroso INTEGER DEFAULT 0,
            fecha_visto TEXT,
            enviado INTEGER DEFAULT 0
          )
        ''');
      },
      // onUpgrade: si la app ya tenía la base vieja (versión 1), le agrega
      // las columnas nuevas SIN borrar los reportes que ya estaban guardados
      onUpgrade: (db, versionVieja, versionNueva) async {
        if (versionVieja < 2) {
          await db.execute('ALTER TABLE reportes ADD COLUMN tamano_cm INTEGER');
          await db.execute('ALTER TABLE reportes ADD COLUMN peligroso INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE reportes ADD COLUMN fecha_visto TEXT');
          await db.execute('ALTER TABLE reportes ADD COLUMN enviado INTEGER DEFAULT 0');
        }
      },
    );
    return _db!; // el "!" le asegura a Dart que ya no es null
  }

  // INSERT: agrega una fila nueva con los datos del reporte (usa toMap).
  // Regresa el id que SQLite le asignó.
  static Future<int> insertar(Reporte reporte) async {
    final db = await obtenerDB();
    return await db.insert('reportes', reporte.toMap());
  }

  // SELECT: trae todos los reportes (el más nuevo primero) y los convierte
  // de vuelta a objetos Reporte con fromMap.
  static Future<List<Reporte>> obtenerTodos() async {
    final db = await obtenerDB();
    // orderBy 'id DESC' = ordenar por id de mayor a menor (el último primero)
    final filas = await db.query('reportes', orderBy: 'id DESC');
    // .map recorre cada fila y la convierte; .toList() lo vuelve lista
    return filas.map((fila) => Reporte.fromMap(fila)).toList();
  }

  // UPDATE: cambia el estado de un reporte (ej. de Pendiente a Resuelto).
  static Future<void> actualizarEstado(int id, String estado) async {
    final db = await obtenerDB();
    await db.update(
      'reportes',
      {'estado': estado}, // solo cambiamos esta columna
      where: 'id = ?', // solo la fila con ese id
      whereArgs: [id], // el valor que reemplaza al "?"
    );
  }

  // UPDATE: marca que el reporte ya se mandó al servidor web
  static Future<void> marcarEnviado(int id) async {
    final db = await obtenerDB();
    await db.update('reportes', {'enviado': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE: borra la fila cuyo id coincida. El "?" evita inyección SQL.
  static Future<void> eliminar(int id) async {
    final db = await obtenerDB();
    await db.delete('reportes', where: 'id = ?', whereArgs: [id]);
  }
}
