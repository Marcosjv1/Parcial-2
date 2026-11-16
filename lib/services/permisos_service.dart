import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Servicio para pedir permisos (cámara, micrófono, ubicación)
// y manejar el caso en que el usuario los niega.
class PermisosService {
  // Regresa true si el permiso quedó concedido.
  static Future<bool> pedir(
    BuildContext context,
    Permission permiso,
    String nombre,
  ) async {
    final estado = await permiso.request();
    if (estado.isGranted || estado.isLimited) return true;
    if (!context.mounted) return false;

    if (estado.isPermanentlyDenied) {
      // El usuario marcó "No volver a preguntar": solo se puede activar
      // desde los Ajustes del teléfono, así que le ofrecemos abrirlos.
      final abrir = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permiso de $nombre bloqueado'),
          content: Text(
            'Para usar $nombre, actívalo en los Ajustes del teléfono.',
          ),
          actions: [
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
      if (abrir == true) await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Necesitas dar permiso de $nombre')),
      );
    }
    return false;
  }
}
