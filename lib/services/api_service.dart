// dart:convert trae jsonEncode y jsonDecode (y base64 para mandar la foto)
import 'dart:convert';
// dart:io para leer el archivo de la foto
import 'dart:io';

// http es el paquete para hacer peticiones a un servicio web
import 'package:http/http.dart' as http;

import '../models/reporte.dart';

// ============================================================
// COMUNICACIÓN WEB — ApiService habla con el servidor de Node.js
// (carpeta servidor/ del proyecto), que guarda los reportes en PostgreSQL.
//   POST /api/reportes -> registra un reporte en la base de datos
//   GET  /api/reportes -> consulta todos los reportes de la base de datos
//   PUT  /api/reportes/:id/estado -> cambia a Pendiente / Resuelto
//   GET  /api/reportes/:id/foto -> la foto del reporte
// SOLID (S y D): las pantallas no usan http directo, usan este servicio.
// ============================================================
class ApiService {
  // 10.0.2.2 es "la laptop" vista desde el emulador de Android.
  // (localhost dentro del emulador sería el propio teléfono virtual)
  static const String urlBase = 'http://10.0.2.2:3000/api';

  // Si el servidor no contesta en 8 segundos, nos rendimos
  static const Duration espera = Duration(seconds: 8);

  // POST: manda un reporte al servidor. Regresa el id que le dio PostgreSQL.
  static Future<int> enviarReporte(Reporte reporte) async {
    try {
      final datos = reporte.toApi();
      // Si el reporte tiene foto, la mandamos como texto (base64) dentro del JSON
      if (reporte.imagen != null && File(reporte.imagen!).existsSync()) {
        datos['foto_base64'] = base64Encode(File(reporte.imagen!).readAsBytesSync());
      }
      final respuesta = await http
          .post(
            Uri.parse('$urlBase/reportes'),
            headers: {'Content-Type': 'application/json'}, // mandamos JSON
            body: jsonEncode(datos), // Reporte -> texto JSON
          )
          .timeout(espera);

      // 201 = "creado". Cualquier otro código es un error del servidor
      if (respuesta.statusCode != 201) {
        final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
        throw Exception(cuerpo['error'] ?? 'Error ${respuesta.statusCode}');
      }
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      return cuerpo['id'] as int;
    } on Exception catch (e) {
      // Si no hay conexión o el servidor está apagado, lo decimos claro
      throw Exception(_mensaje(e));
    }
  }

  // GET: trae todos los reportes guardados en la base de datos del servidor
  static Future<List<Reporte>> obtenerReportes() async {
    try {
      final respuesta =
          await http.get(Uri.parse('$urlBase/reportes')).timeout(espera);
      if (respuesta.statusCode != 200) {
        throw Exception('Error ${respuesta.statusCode} del servidor');
      }
      // El servidor manda una lista JSON; cada elemento se vuelve un Reporte
      final lista = jsonDecode(respuesta.body) as List<dynamic>;
      return lista.map((fila) {
        final mapa = fila as Map<String, dynamic>;
        final r = Reporte.fromMap(mapa);
        // El servidor avisa si tiene foto; si sí, armamos la dirección para verla
        if (mapa['tiene_foto'] == true) r.fotoUrl = '$urlBase/reportes/${r.id}/foto';
        return r;
      }).toList();
    } on Exception catch (e) {
      throw Exception(_mensaje(e));
    }
  }

  // PUT: le avisa al servidor que el reporte cambió de estado
  static Future<void> actualizarEstado(int servidorId, String estado) async {
    try {
      final respuesta = await http
          .put(
            Uri.parse('$urlBase/reportes/$servidorId/estado'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'estado': estado}),
          )
          .timeout(espera);
      if (respuesta.statusCode != 200) {
        throw Exception('Error ${respuesta.statusCode} del servidor');
      }
    } on Exception catch (e) {
      throw Exception(_mensaje(e));
    }
  }

  // Convierte los errores técnicos en un mensaje que el usuario entienda
  static String _mensaje(Exception e) {
    final texto = e.toString();
    if (texto.contains('SocketException') ||
        texto.contains('Connection refused') ||
        texto.contains('TimeoutException') ||
        texto.contains('ClientException')) {
      return 'No se pudo conectar con el servidor. ¿Está prendido?';
    }
    return texto.replaceFirst('Exception: ', '');
  }
}
