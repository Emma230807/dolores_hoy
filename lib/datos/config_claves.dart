import '../dominio/excepciones.dart';

/// Las claves nunca se escriben directamente en el código.
/// Se reciben al compilar mediante --dart-define.
class ConfigClaves {
  final String nasa;

  const ConfigClaves({required this.nasa});

  /// Lee la clave de NASA desde la configuración
  /// utilizada al compilar la aplicación.
  factory ConfigClaves.desdeEntorno() => const ConfigClaves(
    nasa: String.fromEnvironment('NASA_API_KEY', defaultValue: 'DEMO_KEY'),
  );

  /// Indica si estamos usando la clave pública de prueba.
  bool get usaClaveDemo => nasa == 'DEMO_KEY';

  /// Comprueba que exista una clave configurada.
  void validar() {
    if (nasa.trim().isEmpty) {
      throw const ClaveFaltanteException('NASA_API_KEY');
    }
  }

  /// Evita mostrar la clave completa al imprimir el objeto.
  @override
  String toString() => 'ConfigClaves(nasa: ${_ocultar(nasa)})';

  /// Solo muestra los primeros y últimos dos caracteres.
  static String _ocultar(String s) => s.length <= 4
      ? '****'
      : '${s.substring(0, 2)}***${s.substring(s.length - 2)}';
}
