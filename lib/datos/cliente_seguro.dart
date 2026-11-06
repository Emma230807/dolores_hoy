import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../dominio/excepciones.dart';

/// Único punto de salida a Internet de toda la aplicación.
/// Aplica HTTPS, timeout, límites de tamaño y manejo de errores.
class ClienteSeguro {
  final http.Client _cliente;
  final Duration espera;
  final int maxBytes;

  ClienteSeguro(
    this._cliente, {
    this.espera = const Duration(seconds: 8),
    this.maxBytes = 1024 * 1024,
  });

  static const _cabeceras = {
    'Accept': 'application/json',
    'User-Agent': 'DoloresHoy/1.0 (curso Flutter UTNG)',
  };

  /// Realiza una petición GET y devuelve el JSON decodificado.
  Future<dynamic> obtenerJson(Uri uri) async {
    // Rechazar conexiones que no utilicen HTTPS.
    if (uri.scheme != 'https') {
      throw const ConexionInseguraException();
    }

    http.Response r;

    try {
      r = await _cliente.get(uri, headers: _cabeceras).timeout(espera);
    } on SocketException {
      throw const SinConexionException();
    } on TimeoutException {
      throw const SinConexionException();
    } on http.ClientException {
      throw const SinConexionException();
    }

    // Comprobar que el servidor respondió correctamente.
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ErrorServidorException(r.statusCode);
    }

    // Rechazar respuestas que excedan el límite permitido.
    if (r.bodyBytes.length > maxBytes) {
      throw const RespuestaDemasiadoGrandeException();
    }

    // Interpretar la respuesta como JSON.
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      throw const RespuestaInvalidaException();
    }
  }

  /// Oculta claves privadas cuando una URL se escribe en los logs.

  static String redactar(Uri uri) {
    const secretos = {'api_key', 'apikey', 'key', 'token', 'access_token'};

    final params = uri.queryParameters.map(
      (k, v) => MapEntry(k, secretos.contains(k.toLowerCase()) ? '***' : v),
    );

    final url = uri
        .replace(queryParameters: params.isEmpty ? null : params)
        .toString();

    return url.replaceAll('%2A%2A%2A', '***');
  }
}

/// Convierte JSON a objetos sin mostrar errores técnicos internos.
T convertir<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    throw const RespuestaInvalidaException();
  }
}
