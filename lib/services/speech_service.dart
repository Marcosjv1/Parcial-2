import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/errors/app_exception.dart';

/// Callback con el texto reconocido. [isFinal] es true cuando el motor
/// terminó de procesar la frase.
typedef SpeechResultCallback = void Function(String text, bool isFinal);

/// Abstracción del gadget de audio: captura por micrófono + voz a texto.
abstract class SpeechService {
  bool get isListening;

  /// Pide permiso de micrófono e inicializa el motor de reconocimiento.
  Future<bool> initialize();

  /// Empieza a escuchar el micrófono y transcribir.
  Future<void> startListening({
    required SpeechResultCallback onResult,
    ValueChanged<bool>? onListeningChanged,
  });

  /// Deja de escuchar.
  Future<void> stopListening();
}

/// Implementación con el paquete `speech_to_text`.
///
/// El paquete abre el MICRÓFONO del dispositivo, captura el audio y lo envía
/// al reconocedor de voz del sistema (Google en Android, Siri en iOS), que
/// devuelve el texto en tiempo real.
class SpeechToTextService implements SpeechService {
  SpeechToTextService({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _initialized = false;
  String? _localeId;
  ValueChanged<bool>? _onListeningChanged;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      // initialize() solicita el permiso de micrófono (y de reconocimiento
      // de voz en iOS). Devuelve false si el usuario lo niega.
      _initialized = await _speech.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
      );
      if (!_initialized) {
        throw const SpeechException(
          'No hay permiso de micrófono o el reconocimiento de voz no está '
          'disponible en este dispositivo.',
        );
      }
      _localeId = await _findSpanishLocale();
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw SpeechException('No se pudo iniciar el micrófono: $e');
    }
  }

  /// Busca un idioma español instalado (prefiere es-MX).
  Future<String?> _findSpanishLocale() async {
    try {
      final locales = await _speech.locales();
      final spanish = locales
          .where((l) => l.localeId.toLowerCase().startsWith('es'))
          .toList();
      if (spanish.isEmpty) return null; // Usará el idioma del sistema.
      return spanish
          .firstWhere(
            (l) => l.localeId.toLowerCase().contains('mx'),
            orElse: () => spanish.first,
          )
          .localeId;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> startListening({
    required SpeechResultCallback onResult,
    ValueChanged<bool>? onListeningChanged,
  }) async {
    await initialize();
    _onListeningChanged = onListeningChanged;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) =>
            onResult(result.recognizedWords, result.finalResult),
        // En la versión estable 7.x estos tres parámetros van aquí; las
        // versiones beta los movieron a SpeechListenOptions.
        // ignore: deprecated_member_use
        localeId: _localeId,
        // ignore: deprecated_member_use
        listenFor: const Duration(minutes: 2),
        // ignore: deprecated_member_use
        pauseFor: const Duration(seconds: 5),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true, // Muestra el texto mientras hablas.
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
        ),
      );
      _onListeningChanged?.call(true);
    } catch (e) {
      _onListeningChanged?.call(false);
      throw SpeechException('No se pudo iniciar el dictado: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Error al detener el dictado: $e');
    } finally {
      _onListeningChanged?.call(false);
    }
  }

  void _handleStatus(String status) {
    // 'done' / 'notListening' llegan cuando el usuario deja de hablar.
    if (status == 'done' || status == 'notListening') {
      _onListeningChanged?.call(false);
    }
  }

  void _handleError(SpeechRecognitionError error) {
    debugPrint('Error de reconocimiento de voz: ${error.errorMsg}');
    _onListeningChanged?.call(false);
  }
}
