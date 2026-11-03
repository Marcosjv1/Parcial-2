import 'package:speech_to_text/speech_to_text.dart';

// Servicio que usa el micrófono para convertir la voz en texto
class VozService {
  final SpeechToText _speech = SpeechToText();

  // Prepara el micrófono (pide permiso la primera vez).
  // Regresa false si el usuario no dio permiso.
  Future<bool> iniciar({required Function() alTerminar}) async {
    return await _speech.initialize(
      onStatus: (estado) {
        // "done" o "notListening" = el usuario dejó de hablar
        if (estado == 'done' || estado == 'notListening') {
          alTerminar();
        }
      },
      onError: (error) => alTerminar(),
    );
  }

  // Empieza a escuchar y manda el texto reconocido a la pantalla
  Future<void> escuchar(Function(String texto) alReconocer) async {
    await _speech.listen(
      onResult: (resultado) => alReconocer(resultado.recognizedWords),
      // ignore: deprecated_member_use
      localeId: 'es_MX', // reconocer en español
    );
  }

  Future<void> detener() async {
    await _speech.stop();
  }
}
