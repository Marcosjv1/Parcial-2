import 'package:local_auth/local_auth.dart';

// ============================================================
// LOGIN BIOMÉTRICO — Usa el paquete local_auth.
// Le pide a Android que muestre su ventana de "pon tu huella".
// Nosotros nunca vemos la huella: Android solo nos dice "sí era" o
// "no era". Por eso es seguro.
// ============================================================
class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Regresa true si el usuario se identificó correctamente.
  // Lanza una Exception con un mensaje claro si algo impide autenticar.
  static Future<bool> autenticar() async {
    // ¿El teléfono tiene algún método de seguridad (huella, rostro, PIN)?
    final soportado = await _auth.isDeviceSupported();
    if (!soportado) {
      throw Exception('Este teléfono no tiene seguridad biométrica disponible');
    }

    try {
      return await _auth.authenticate(
        localizedReason: 'Usa tu huella para ver tus reportes',
        biometricOnly: false, // si no hay huella registrada, acepta el PIN
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      // Cada error tiene un código. Según el código, decidimos qué decirle
      // al usuario (canceló, no tiene huella configurada, muchos intentos...).
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          return false; // el usuario cerró el diálogo
        case LocalAuthExceptionCode.noCredentialsSet:
          throw Exception(
            'Configura un PIN o huella en tu teléfono para proteger tus reportes',
          );
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          throw Exception('Demasiados intentos fallidos. Espera un momento.');
        default:
          throw Exception('No se pudo verificar tu identidad (${e.code.name})');
      }
    }
  }
}
