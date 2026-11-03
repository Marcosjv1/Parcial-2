import 'package:bitacora/core/utils/date_formatter.dart';
import 'package:bitacora/domain/entities/diary_entry.dart';
import 'package:bitacora/domain/entities/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pruebas unitarias de la capa de dominio (no requieren dispositivo).
/// Ejecutar con:  flutter test
void main() {
  group('DiaryEntry', () {
    final fecha = DateTime(2026, 11, 3, 14, 5);

    test('toMap y fromMap conservan todos los datos', () {
      final original = DiaryEntry(
        id: 7,
        title: 'Visita a Progreso',
        content: 'Fuimos a la playa.',
        createdAt: fecha,
        imagePath: '/data/diary_images/img_1.jpg',
        location: const GeoPoint(21.28, -89.66),
      );

      final copia = DiaryEntry.fromMap(original.toMap());

      expect(copia.id, 7);
      expect(copia.title, original.title);
      expect(copia.content, original.content);
      expect(copia.createdAt, fecha);
      expect(copia.imagePath, original.imagePath);
      expect(copia.location, const GeoPoint(21.28, -89.66));
    });

    test('una entrada sin foto ni GPS se serializa con nulos', () {
      final entry = DiaryEntry(title: 'a', content: 'b', createdAt: fecha);
      final map = entry.toMap();

      expect(map.containsKey(DiaryEntry.colId), isFalse);
      expect(map[DiaryEntry.colLatitude], isNull);
      expect(DiaryEntry.fromMap(map).hasLocation, isFalse);
      expect(entry.hasImage, isFalse);
    });

    test('copyWith asigna el id generado por SQLite', () {
      final entry = DiaryEntry(title: 'a', content: 'b', createdAt: fecha);
      expect(entry.copyWith(id: 3).id, 3);
      expect(entry.copyWith(id: 3).title, 'a');
    });
  });

  group('DateFormatter', () {
    final fecha = DateTime(2026, 11, 3, 9, 7); // martes

    test('formatea fechas en español', () {
      expect(DateFormatter.longDate(fecha), '3 de noviembre de 2026');
      expect(DateFormatter.shortDate(fecha), '03 nov 2026');
      expect(DateFormatter.time(fecha), '09:07');
      expect(
        DateFormatter.fullDateTime(fecha),
        'martes, 3 de noviembre de 2026 · 09:07',
      );
    });
  });
}
