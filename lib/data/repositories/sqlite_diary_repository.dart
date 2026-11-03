import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/database_helper.dart';

/// Implementación concreta de [DiaryRepository] usando SQLite (sqflite).
///
/// Cada operación está envuelta en try-catch: los errores técnicos de
/// sqflite se traducen a [StorageException] con un mensaje claro para el
/// usuario, de modo que la interfaz nunca recibe una excepción "cruda".
class SqliteDiaryRepository implements DiaryRepository {
  /// El helper se inyecta por constructor (facilita pruebas y cumple DIP).
  SqliteDiaryRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const String _table = DatabaseHelper.entriesTable;

  @override
  Future<List<DiaryEntry>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        orderBy: '${DiaryEntry.colCreatedAt} DESC',
      );
      return rows.map(DiaryEntry.fromMap).toList();
    } on DatabaseException catch (e) {
      throw StorageException('No se pudieron cargar las entradas: $e');
    } catch (e) {
      throw StorageException('Error inesperado al leer el diario: $e');
    }
  }

  @override
  Future<DiaryEntry?> getById(int id) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: '${DiaryEntry.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      return rows.isEmpty ? null : DiaryEntry.fromMap(rows.first);
    } on DatabaseException catch (e) {
      throw StorageException('No se pudo leer la entrada: $e');
    } catch (e) {
      throw StorageException('Error inesperado al leer la entrada: $e');
    }
  }

  @override
  Future<DiaryEntry> insert(DiaryEntry entry) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert(
        _table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return entry.copyWith(id: id);
    } on DatabaseException catch (e) {
      throw StorageException('No se pudo guardar la entrada: $e');
    } catch (e) {
      throw StorageException('Error inesperado al guardar: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        _table,
        where: '${DiaryEntry.colId} = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      throw StorageException('No se pudo eliminar la entrada: $e');
    } catch (e) {
      throw StorageException('Error inesperado al eliminar: $e');
    }
  }
}
