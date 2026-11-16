import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/reporte.dart';

// ============================================================
// BASE DE DATOS — DBHelper es el único que habla con SQLite.
// SQLite es una mini base de datos que vive DENTRO del teléfono,
// por eso tus reportes no se borran aunque cierres la app.
// Las pantallas nunca tocan SQLite directo: le piden las cosas a DBHelper.
// ============================================================
class DBHelper {
  static Database? _db;

  // Abre la base de datos. La primera vez que se usa la app no existe,
  // así que onCreate crea la tabla "reportes" (como una hoja de Excel
  // con columnas: id, tipo, descripcion, fecha, estado, imagen, latitud, longitud).
  // Las siguientes veces solo la abre. Guardamos la conexión en _db
  // para no abrirla una y otra vez.
  static Future<Database> obtenerDB() async {
    if (_db != null) return _db!;

    final ruta = join(await getDatabasesPath(), 'reportes.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reportes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            descripcion TEXT,
            fecha TEXT,
            estado TEXT,
            imagen TEXT,
            latitud REAL,
            longitud REAL
          )
        ''');
      },
    );
    return _db!;
  }

  // INSERT: agrega una fila nueva con los datos del reporte (usa toMap).
  static Future<int> insertar(Reporte reporte) async {
    final db = await obtenerDB();
    return await db.insert('reportes', reporte.toMap());
  }

  // SELECT: trae todos los reportes (el más nuevo primero) y los convierte
  // de vuelta a objetos Reporte con fromMap.
  static Future<List<Reporte>> obtenerTodos() async {
    final db = await obtenerDB();
    final filas = await db.query('reportes', orderBy: 'id DESC');
    return filas.map((fila) => Reporte.fromMap(fila)).toList();
  }

  // UPDATE: cambia el estado de un reporte (ej. de Pendiente a Resuelto).
  static Future<void> actualizarEstado(int id, String estado) async {
    final db = await obtenerDB();
    await db.update(
      'reportes',
      {'estado': estado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: borra la fila cuyo id coincida. El "?" evita inyección SQL.
  static Future<void> eliminar(int id) async {
    final db = await obtenerDB();
    await db.delete('reportes', where: 'id = ?', whereArgs: [id]);
  }
}
