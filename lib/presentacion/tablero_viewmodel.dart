import 'package:flutter/foundation.dart';

import '../datos/servicios.dart';
import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';

// Estados posibles de cada tarjeta.
enum Estado { cargando, listo, error }

/// Estado de una tarjeta.
/// Cada API tiene su propio estado independiente.
class Carga<T> {
  final Estado estado;
  final T? dato;
  final String? error;

  const Carga._(this.estado, this.dato, this.error);

  const Carga.cargando() : this._(Estado.cargando, null, null);

  const Carga.listo(T dato) : this._(Estado.listo, dato, null);

  const Carga.fallo(String error) : this._(Estado.error, null, error);
}

class TableroViewModel extends ChangeNotifier {
  // Servicios recibidos mediante el constructor.
  final ServicioClima servicioClima;
  final ServicioCambio servicioCambio;
  final ServicioFestivos servicioFestivos;
  final ServicioWikipedia servicioWikipedia;
  final ServicioNasa servicioNasa;

  TableroViewModel({
    required ServicioClima clima,
    required ServicioCambio cambio,
    required ServicioFestivos festivos,
    required ServicioWikipedia wikipedia,
    required ServicioNasa nasa,
  }) : servicioClima = clima,
       servicioCambio = cambio,
       servicioFestivos = festivos,
       servicioWikipedia = wikipedia,
       servicioNasa = nasa;

  // Estados independientes de las cinco APIs.
  Carga<Clima> clima = const Carga.cargando();

  Carga<TipoCambio> cambio = const Carga.cargando();

  Carga<List<Festivo>> festivos = const Carga.cargando();

  Carga<ResumenWiki> wiki = const Carga.cargando();

  Carga<FotoAstronomica> nasa = const Carga.cargando();

  /// Consulta las cinco APIs en paralelo.
  Future<void> cargarTodo() async {
    clima = const Carga.cargando();
    cambio = const Carga.cargando();
    festivos = const Carga.cargando();
    wiki = const Carga.cargando();
    nasa = const Carga.cargando();

    notifyListeners();

    await Future.wait([
      _cargar(() => servicioClima.actual(), (c) => clima = c),
      _cargar(() => servicioCambio.deMxn(), (c) => cambio = c),
      _cargar(() => servicioFestivos.proximos(), (c) => festivos = c),
      _cargar(
        () => servicioWikipedia.resumen('Dolores_Hidalgo'),
        (c) => wiki = c,
      ),
      _cargar(() => servicioNasa.fotoDelDia(), (c) => nasa = c),
    ]);
  }

  /// Consulta una API y actualiza únicamente su tarjeta.
  Future<void> _cargar<T>(
    Future<T> Function() pedir,
    void Function(Carga<T>) poner,
  ) async {
    try {
      poner(Carga.listo(await pedir()));
    } catch (e) {
      poner(Carga.fallo(mensajeSeguro(e)));
    }

    notifyListeners();
  }
}
