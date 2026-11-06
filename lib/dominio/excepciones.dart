/// Todos los errores esperados de la aplicación
/// heredan de ErrorDeApp.
abstract class ErrorDeApp implements Exception {
  const ErrorDeApp();
}

class SinConexionException extends ErrorDeApp {
  const SinConexionException();

  @override
  String toString() => 'No hay conexión con el servidor. Revisa tu internet.';
}

class ErrorServidorException extends ErrorDeApp {
  final int codigo;

  const ErrorServidorException(this.codigo);

  @override
  String toString() {
    switch (codigo) {
      case 401:
      case 403:
        return 'La clave de la API no es válida o no tiene permiso ($codigo).';
      case 404:
        return 'No se encontró lo que buscabas (404).';
      case 429:
        return 'Demasiadas peticiones (429). Espera un momento e intenta de nuevo.';
      default:
        return 'El servidor respondió con error ($codigo).';
    }
  }
}

class RespuestaInvalidaException extends ErrorDeApp {
  const RespuestaInvalidaException();

  @override
  String toString() => 'El servidor respondió con datos que no entiendo.';
}

class RespuestaDemasiadoGrandeException extends ErrorDeApp {
  const RespuestaDemasiadoGrandeException();

  @override
  String toString() =>
      'La respuesta del servidor es demasiado grande y se descartó.';
}

class ConexionInseguraException extends ErrorDeApp {
  const ConexionInseguraException();

  @override
  String toString() => 'Por seguridad solo se permiten direcciones https://';
}

class EntradaInvalidaException extends ErrorDeApp {
  final String motivo;

  const EntradaInvalidaException(this.motivo);

  @override
  String toString() => 'Dato inválido: $motivo';
}

class ClaveFaltanteException extends ErrorDeApp {
  final String nombre;

  const ClaveFaltanteException(this.nombre);

  @override
  String toString() => 'Falta configurar la clave $nombre.';
}

/// Solo muestra mensajes seguros al usuario.
/// Los errores desconocidos reciben un mensaje genérico.
String mensajeSeguro(Object error) => error is ErrorDeApp
    ? error.toString()
    : 'Ocurrió un error inesperado. Intenta de nuevo.';
