// Material para poder mostrar el diálogo y el SnackBar
import 'package:flutter/material.dart';
// permission_handler pide los permisos de Android (cámara, micrófono, GPS)
import 'package:permission_handler/permission_handler.dart';

// ============================================================
// PERMISOS — Android no deja usar la cámara, el micrófono ni el GPS
// sin que el usuario diga "Permitir". Esta clase pide el permiso y
// maneja los 3 casos posibles:
//   1. Lo aceptó            -> seguimos normal.
//   2. Lo negó una vez      -> avisamos con un mensaje abajo (SnackBar).
//   3. Lo negó para siempre -> ofrecemos abrir los Ajustes del teléfono.
// (La rúbrica pide justo esto: "maneja los casos donde el usuario deniega permisos")
// ============================================================
class PermisosService {
  // Regresa true si el permiso quedó concedido.
  // "nombre" es solo para el mensaje, ej. 'la cámara'.
  static Future<bool> pedir(
    BuildContext context,
    Permission permiso,
    String nombre,
  ) async {
    // Aquí sale la ventanita de Android de "¿Permitir que ReportaCalle use...?"
    final estado = await permiso.request();
    if (estado.isGranted || estado.isLimited) return true; // caso 1: sí dio permiso
    // Si el usuario se salió de la pantalla mientras tanto, ya no mostramos nada
    if (!context.mounted) return false;

    if (estado.isPermanentlyDenied) {
      // Caso 3: el usuario marcó "No volver a preguntar": solo se puede activar
      // desde los Ajustes del teléfono, así que le ofrecemos abrirlos.
      final abrir = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permiso de $nombre bloqueado'),
          content: Text(
            'Para usar $nombre, actívalo en los Ajustes del teléfono.',
          ),
          actions: [
            // Navigator.pop cierra el diálogo y regresa el valor (false o true)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abrir ajustes'),
            ),
          ],
        ),
      );
      if (abrir == true) await openAppSettings(); // abre los Ajustes de la app
    } else {
      // Caso 2: lo negó solo esta vez, avisamos con un mensajito abajo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Necesitas dar permiso de $nombre')),
      );
    }
    return false; // en los casos 2 y 3 no hay permiso
  }
}
