import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_academica_offline/core/network/connectivity_service.dart';
import 'package:app_academica_offline/core/sync/outbox_item.dart';
import 'package:app_academica_offline/features/docente/models/asistencia_model.dart';
import 'package:app_academica_offline/services/local/asistencia_local_store.dart';
import 'package:app_academica_offline/services/local/outbox_local_store.dart';

class AsistenciaRepository {
  final AsistenciaLocalStore _localStore;
  final ConnectivityService _connectivityService;
  final OutboxLocalStore _outboxLocalStore;
  final FirebaseFirestore _firestore;

  AsistenciaRepository({
    AsistenciaLocalStore? localStore,
    ConnectivityService? connectivityService,
    OutboxLocalStore? outboxLocalStore,
    FirebaseFirestore? firestore,
  })  : _localStore = localStore ?? AsistenciaLocalStore(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _outboxLocalStore = outboxLocalStore ?? OutboxLocalStore(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  List<Asistencia> getAll() {
    return _localStore.getAll();
  }

  List<Asistencia> getByAsignatura(String asignaturaId) {
    return _localStore.getByAsignatura(asignaturaId);
  }

  List<Asistencia> getByFecha(String fecha) {
    return _localStore.getByFecha(fecha);
  }

  Future<void> save(Asistencia asistencia) async {
    // 1. Siempre se guarda primero en Hive local.
    await _localStore.upsert(asistencia);

    final data = _asistenciaToMap(asistencia);

    // 2. Luego se intenta sincronizar con Firebase.
    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('asistencias').doc(data['id']).set(
              data,
              SetOptions(merge: true),
            );
      } catch (_) {
        await _guardarPendiente(
          entidad: 'asistencia',
          accion: 'upsert',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'asistencia',
        accion: 'upsert',
        data: data,
      );
    }
  }

  Future<void> delete(String id) async {
    // 1. Primero se elimina localmente.
    await _localStore.delete(id);

    final data = {
      'id': id,
    };

    // 2. Luego se intenta eliminar en Firebase.
    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('asistencias').doc(id).delete();
      } catch (_) {
        await _guardarPendiente(
          entidad: 'asistencia',
          accion: 'eliminar',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'asistencia',
        accion: 'eliminar',
        data: data,
      );
    }
  }

  Map<String, dynamic> _asistenciaToMap(Asistencia asistencia) {
    return {
      'id': asistencia.id,
      'asignaturaId': asistencia.asignaturaId,
      'estudianteId': asistencia.estudianteId,
      'fecha': asistencia.fecha,
      'estado': asistencia.estado,
      'observacion': asistencia.observacion,
      'actualizadoEn': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _guardarPendiente({
    required String entidad,
    required String accion,
    required Map<String, dynamic> data,
  }) async {
    final item = OutboxItem.crear(
      entidad: entidad,
      accion: accion,
      data: data,
    );

    await _outboxLocalStore.add(item);
  }
}

