// local_auth es el paquete que usa la huella / PIN del teléfono
import 'package:local_auth/local_auth.dart';

// ============================================================
// LOGIN BIOMÉTRICO — Usa el paquete local_auth.
// Le pide a Android que muestre su ventana de "pon tu huella".
// Nosotros nunca vemos la huella: Android solo nos dice "sí era" o
// "no era". Por eso es seguro.
// ============================================================
class AuthService {
  // Objeto del paquete que hace todo el trabajo. Es static para crearlo una sola vez.
  static final LocalAuthentication _auth = LocalAuthentication();

  // Regresa true si el usuario se identificó correctamente.
  // Lanza una Exception con un mensaje claro si algo impide autenticar.
  static Future<bool> autenticar() async {
    // ¿El teléfono tiene algún método de seguridad (huella, rostro, PIN)?
    final soportado = await _auth.isDeviceSupported();
    if (!soportado) {
      // throw = "aviento" el error para que la pantalla de login lo atrape
      throw Exception('Este teléfono no tiene seguridad biométrica disponible');
    }

    try {
      // Aquí sale la ventanita de Android pidiendo la huella
      return await _auth.authenticate(
        localizedReason: 'Usa tu huella para ver tus reportes', // texto de la ventanita
        biometricOnly: false, // si no hay huella registrada, acepta el PIN
        persistAcrossBackgrounding: true, // si minimizas la app, no se cancela
      );
    } on LocalAuthException catch (e) {
      // Cada error tiene un código. Según el código, decidimos qué decirle
      // al usuario (canceló, no tiene huella configurada, muchos intentos...).
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          return false; // el usuario cerró el diálogo, no es un error grave
        case LocalAuthExceptionCode.noCredentialsSet:
          // El teléfono no tiene ni PIN ni huella configurados
          throw Exception(
            'Configura un PIN o huella en tu teléfono para proteger tus reportes',
          );
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          // Android bloquea la huella un rato si fallas muchas veces
          throw Exception('Demasiados intentos fallidos. Espera un momento.');
        default:
          // Cualquier otro error: mostramos su nombre para saber qué pasó
          throw Exception('No se pudo verificar tu identidad (${e.code.name})');
      }
    }
  }
}
