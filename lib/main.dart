import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'datos/cliente_seguro.dart';
import 'datos/config_claves.dart';
import 'datos/servicios.dart';
import 'presentacion/pantalla_tablero.dart';
import 'presentacion/tablero_viewmodel.dart';

void main() {
  // Cliente HTTP seguro utilizado por las cinco APIs.
  final cliente = ClienteSeguro(http.Client());

  // Obtener la clave de NASA desde la configuración.
  final claves = ConfigClaves.desdeEntorno();

  // Crear el ViewModel con los cinco servicios.
  final vm = TableroViewModel(
    clima: ServicioClima(cliente),
    cambio: ServicioCambio(cliente),
    festivos: ServicioFestivos(cliente),
    wikipedia: ServicioWikipedia(cliente),
    nasa: ServicioNasa(cliente, claves),
  );

  // Iniciar la aplicación.
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dolores Hoy',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: PantallaTablero(vm: vm),
    ),
  );
}
