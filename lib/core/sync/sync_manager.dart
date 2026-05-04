import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_academica_offline/core/network/connectivity_service.dart';
import 'package:app_academica_offline/core/sync/outbox_item.dart';
import 'package:app_academica_offline/services/local/outbox_local_store.dart';

class SyncManager {
  final ConnectivityService _connectivityService;
  final OutboxLocalStore _outboxLocalStore;
  final FirebaseFirestore _firestore;

  StreamSubscription<bool>? _conexionSubscription;
  bool _sincronizando = false;

  SyncManager({
    ConnectivityService? connectivityService,
    OutboxLocalStore? outboxLocalStore,
    FirebaseFirestore? firestore,
  })  : _connectivityService = connectivityService ?? ConnectivityService(),
        _outboxLocalStore = outboxLocalStore ?? OutboxLocalStore(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Inicia la escucha de conexión.
  ///
  /// Cuando vuelve el internet, intenta sincronizar los pendientes.
  void iniciarEscucha() {
    _conexionSubscription ??=
        _connectivityService.cambiosDeConexion.listen((hayConexion) async {
      if (hayConexion) {
        await sincronizarPendientes();
      }
    });
  }

  /// Detiene la escucha de conexión.
  void detenerEscucha() {
    _conexionSubscription?.cancel();
    _conexionSubscription = null;
  }

  /// Sincroniza todos los elementos pendientes del Outbox.
  ///
  /// Este método se puede llamar:
  /// - al iniciar la app;
  /// - al presionar un botón de sincronizar;
  /// - cuando vuelve el internet.
  Future<void> sincronizarPendientes() async {
    if (_sincronizando) return;

    final hayConexion = await _connectivityService.tieneConexion();

    if (!hayConexion) return;

    _sincronizando = true;

    try {
      final pendientes = await _outboxLocalStore.getPendientes();

      for (final item in pendientes) {
        try {
          await _sincronizarItem(item);
          await _outboxLocalStore.delete(item.id);
        } catch (e) {
          await _outboxLocalStore.registrarError(
            id: item.id,
            error: e.toString(),
          );
        }
      }
    } finally {
      _sincronizando = false;
    }
  }

  Future<int> cantidadPendientes() async {
    return await _outboxLocalStore.countPendientes();
  }

  Future<void> _sincronizarItem(OutboxItem item) async {
    final coleccion = _resolverColeccion(item.entidad);
    final accion = item.accion.trim().toLowerCase();
    final data = Map<String, dynamic>.from(item.data);

    final documentoId = _resolverDocumentoId(
      item: item,
      data: data,
    );

    final referencia = _firestore.collection(coleccion).doc(documentoId);

    if (_esAccionEliminar(accion)) {
      await referencia.delete();
      return;
    }

    if (_esAccionGuardar(accion)) {
      await referencia.set(
        data,
        SetOptions(merge: true),
      );
      return;
    }

    throw Exception('Acción de sincronización no reconocida: ${item.accion}');
  }

  String _resolverColeccion(String entidad) {
    final nombre = entidad.trim().toLowerCase();

    switch (nombre) {
      case 'docente':
      case 'docentes':
      case 'usuario':
      case 'usuarios':
        return 'usuarios';

      case 'asignatura':
      case 'asignaturas':
        return 'asignaturas';

      case 'estudiante':
      case 'estudiantes':
        return 'estudiantes';

      case 'asistencia':
      case 'asistencias':
        return 'asistencias';

      case 'actividad':
      case 'actividades':
        return 'actividades';

      case 'nota':
      case 'notas':
        return 'notas';

      default:
        return nombre;
    }
  }

  String _resolverDocumentoId({
    required OutboxItem item,
    required Map<String, dynamic> data,
  }) {
    final posiblesIds = [
      data['id'],
      data['uid'],
      data['docenteId'],
      data['asignaturaId'],
    ];

    for (final valor in posiblesIds) {
      final id = (valor ?? '').toString().trim();

      if (id.isNotEmpty) {
        return id;
      }
    }

    return item.id;
  }

  bool _esAccionGuardar(String accion) {
    return accion == 'crear' ||
        accion == 'guardar' ||
        accion == 'actualizar' ||
        accion == 'editar' ||
        accion == 'upsert' ||
        accion == 'set';
  }

  bool _esAccionEliminar(String accion) {
    return accion == 'eliminar' ||
        accion == 'delete' ||
        accion == 'borrar';
  }
}

