import 'package:local_auth/local_auth.dart';

// Servicio de login biométrico (huella / rostro, o el PIN del teléfono)
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
        localizedReason: 'Usa tu huella para abrir tu diario',
        biometricOnly: false, // si no hay huella registrada, acepta el PIN
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          return false; // el usuario cerró el diálogo
        case LocalAuthExceptionCode.noCredentialsSet:
          throw Exception(
            'Configura un PIN o huella en tu teléfono para proteger tu diario',
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
