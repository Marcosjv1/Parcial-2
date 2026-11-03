import '../entities/diary_entry.dart';

/// Contrato (abstracción) para persistir entradas del diario.
///
/// La interfaz de usuario depende de esta clase abstracta y NO de SQLite.
/// Si mañana se cambia a SharedPreferences, Firebase o una API REST, sólo se
/// crea otra implementación; las pantallas no cambian.
///  - D (Inversión de Dependencias): las pantallas dependen de la abstracción.
///  - O (Abierto/Cerrado): se extiende con nuevas implementaciones.
///  - L (Sustitución de Liskov): cualquier implementación es intercambiable.
abstract class DiaryRepository {
  /// Devuelve todas las entradas, de la más reciente a la más antigua.
  Future<List<DiaryEntry>> getAll();

  /// Busca una entrada por su id; devuelve null si no existe.
  Future<DiaryEntry?> getById(int id);

  /// Guarda una nueva entrada y la devuelve con su `id` asignado.
  Future<DiaryEntry> insert(DiaryEntry entry);

  /// Elimina la entrada con el [id] indicado.
  Future<void> delete(int id);
}
