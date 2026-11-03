/// Utilidades para mostrar fechas en español sin depender de paquetes
/// externos (Responsabilidad Única: sólo formatea fechas).
class DateFormatter {
  DateFormatter._(); // Clase de utilidades: no se instancia.

  static const List<String> _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static const List<String> _weekdays = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];

  /// Ejemplo: `3 de noviembre de 2026`
  static String longDate(DateTime date) =>
      '${date.day} de ${_months[date.month - 1]} de ${date.year}';

  /// Ejemplo: `martes, 3 de noviembre de 2026 · 14:05`
  static String fullDateTime(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${longDate(date)} · ${time(date)}';

  /// Ejemplo: `03 nov 2026`
  static String shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} '
      '${_months[date.month - 1].substring(0, 3)} ${date.year}';

  /// Ejemplo: `14:05`
  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
