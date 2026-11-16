import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/entrada.dart';

// ============================================================
// BASE DE DATOS — DBHelper es el único que habla con SQLite.
// SQLite es una mini base de datos que vive DENTRO del teléfono,
// por eso tus entradas no se borran aunque cierres la app.
// Las pantallas nunca tocan SQLite directo: le piden las cosas a DBHelper.
// ============================================================
class DBHelper {
  static Database? _db;

  // Abre la base de datos. La primera vez que se usa la app no existe,
  // así que onCreate crea la tabla "entradas" (como una hoja de Excel
  // con columnas: id, titulo, texto, fecha, imagen, latitud, longitud).
  // Las siguientes veces solo la abre. Guardamos la conexión en _db
  // para no abrirla una y otra vez.
  static Future<Database> obtenerDB() async {
    if (_db != null) return _db!;

    final ruta = join(await getDatabasesPath(), 'diario.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entradas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            texto TEXT,
            fecha TEXT,
            imagen TEXT,
            latitud REAL,
            longitud REAL
          )
        ''');
      },
    );
    return _db!;
  }

  // INSERT: agrega una fila nueva con los datos de la entrada (usa toMap).
  static Future<int> insertar(Entrada entrada) async {
    final db = await obtenerDB();
    return await db.insert('entradas', entrada.toMap());
  }

  // SELECT: trae todas las entradas (la más nueva primero) y las convierte
  // de vuelta a objetos Entrada con fromMap.
  static Future<List<Entrada>> obtenerTodas() async {
    final db = await obtenerDB();
    final filas = await db.query('entradas', orderBy: 'id DESC');
    return filas.map((fila) => Entrada.fromMap(fila)).toList();
  }

  // DELETE: borra la fila cuyo id coincida. El "?" evita inyección SQL.
  static Future<void> eliminar(int id) async {
    final db = await obtenerDB();
    await db.delete('entradas', where: 'id = ?', whereArgs: [id]);
  }
}
