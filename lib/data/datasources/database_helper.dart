import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/diary_entry.dart';

/// Fuente de datos de bajo nivel: abre y crea la base de datos SQLite.
///
/// Responsabilidad Única: sólo gestiona la conexión y el esquema.
/// Las consultas de negocio viven en el repositorio.
///
/// Se usa el patrón Singleton para que toda la app comparta una sola
/// conexión abierta.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _databaseName = 'bitacora.db';
  static const int _databaseVersion = 1;
  static const String entriesTable = 'diary_entries';

  Database? _database;

  /// Devuelve la conexión, abriéndola la primera vez (carga perezosa).
  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Crea el esquema la primera vez que se instala la app.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $entriesTable (
        ${DiaryEntry.colId}        INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DiaryEntry.colTitle}     TEXT    NOT NULL,
        ${DiaryEntry.colContent}   TEXT    NOT NULL,
        ${DiaryEntry.colCreatedAt} INTEGER NOT NULL,
        ${DiaryEntry.colImagePath} TEXT,
        ${DiaryEntry.colLatitude}  REAL,
        ${DiaryEntry.colLongitude} REAL
      )
    ''');
    // Índice para ordenar rápido por fecha en la lista principal.
    await db.execute(
      'CREATE INDEX idx_entries_created_at '
      'ON $entriesTable(${DiaryEntry.colCreatedAt} DESC)',
    );
  }

  /// Cierra la conexión (útil en pruebas).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
