// speech_to_text convierte lo que hablas en texto
import 'package:speech_to_text/speech_to_text.dart';

// ============================================================
// GADGET 2: MICRÓFONO (VOZ A TEXTO)
// Usa el paquete speech_to_text: abre el micrófono, escucha lo que
// dices y el reconocedor de voz de Google lo convierte en texto
// en tiempo real. Ese texto se va poniendo en el formulario.
// ============================================================
class VozService {
  // El objeto del paquete que controla el micrófono
  final SpeechToText _speech = SpeechToText();

  // Prepara el micrófono (pide permiso la primera vez).
  // Regresa false si el usuario no dio permiso.
  // "alTerminar" es una función que nos pasa la pantalla para avisarle cuando se calla.
  Future<bool> iniciar({required Function() alTerminar}) async {
    return await _speech.initialize(
      // onStatus se llama cada vez que cambia el estado del micrófono
      onStatus: (estado) {
        // "done" o "notListening" = el usuario dejó de hablar
        if (estado == 'done' || estado == 'notListening') {
          alTerminar();
        }
      },
      onError: (error) => alTerminar(), // si hay error, también paramos
    );
  }

  // Empieza a escuchar y manda el texto reconocido a la pantalla
  Future<void> escuchar(Function(String texto) alReconocer) async {
    await _speech.listen(
      // Cada vez que reconoce palabras nuevas, se las mandamos a la pantalla
      onResult: (resultado) => alReconocer(resultado.recognizedWords),
      // ignore: deprecated_member_use
      localeId: 'es_MX', // reconocer en español de México
    );
  }

  // Apaga el micrófono
  Future<void> detener() async {
    await _speech.stop();
  }
}
