import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/entrada.dart';

// Clase que se encarga de la base de datos SQLite
class DBHelper {
  static Database? _db;

  // Abre la base de datos (la crea la primera vez que se usa la app)
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

  // Guarda una entrada nueva
  static Future<int> insertar(Entrada entrada) async {
    final db = await obtenerDB();
    return await db.insert('entradas', entrada.toMap());
  }

  // Regresa todas las entradas, de la más nueva a la más vieja
  static Future<List<Entrada>> obtenerTodas() async {
    final db = await obtenerDB();
    final filas = await db.query('entradas', orderBy: 'id DESC');
    return filas.map((fila) => Entrada.fromMap(fila)).toList();
  }

  // Borra una entrada por su id
  static Future<void> eliminar(int id) async {
    final db = await obtenerDB();
    await db.delete('entradas', where: 'id = ?', whereArgs: [id]);
  }
}
