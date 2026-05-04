// archivo que me sirve como detector de conexion a internet para que la aplicación móvil sepa cuándo puede sincronizar datos con Firebase y cuándo debe trabajar solo con Hive local
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica si el dispositivo tiene conexión real a internet.
  ///
  /// Primero revisa si existe una red disponible:
  /// wifi, datos móviles, ethernet, etc.
  ///
  /// Luego hace una verificación real con InternetAddress.lookup,
  /// porque a veces el celular está conectado a una red,
  /// pero esa red no tiene internet.
  Future<bool> tieneConexion() async {
    try {
      final resultados = await _connectivity.checkConnectivity();

      if (resultados.contains(ConnectivityResult.none)) {
        return false;
      }

      return await _tieneAccesoRealAInternet();
    } catch (_) {
      return false;
    }
  }

  /// Alias más cómodo por si en otros archivos queremos usar este nombre.
  Future<bool> estaConectado() async {
    return tieneConexion();
  }

  /// Stream para escuchar cambios de conectividad.
  ///
  /// Esto servirá después para que el SyncManager intente sincronizar
  /// automáticamente cuando vuelva el internet.
  Stream<bool> get cambiosDeConexion {
    return _connectivity.onConnectivityChanged
        .asyncMap((resultados) async {
          if (resultados.contains(ConnectivityResult.none)) {
            return false;
          }

          return await _tieneAccesoRealAInternet();
        })
        .distinct();
  }

  Future<bool> _tieneAccesoRealAInternet() async {
    try {
      final resultado = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      return resultado.isNotEmpty && resultado.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

