import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_academica_offline/core/network/connectivity_service.dart';
import 'package:app_academica_offline/core/sync/outbox_item.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'package:app_academica_offline/services/local/asignatura_local_store.dart';
import 'package:app_academica_offline/services/local/outbox_local_store.dart';

class AsignaturaRepository {
  final AsignaturaLocalStore _localStore;
  final ConnectivityService _connectivityService;
  final OutboxLocalStore _outboxLocalStore;
  final FirebaseFirestore _firestore;

  AsignaturaRepository({
    AsignaturaLocalStore? localStore,
    ConnectivityService? connectivityService,
    OutboxLocalStore? outboxLocalStore,
    FirebaseFirestore? firestore,
  })  : _localStore = localStore ?? AsignaturaLocalStore(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _outboxLocalStore = outboxLocalStore ?? OutboxLocalStore(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  List<Asignatura> getAll() {
    return _localStore.getAll();
  }

  List<Asignatura> getActivas() {
    return _localStore.getActivas();
  }

  List<Asignatura> getByDocenteId(String docenteId) {
    return _localStore.getByDocenteId(docenteId);
  }

  List<Asignatura> getByDocenteNombre(String docenteNombre) {
    return _localStore.getByDocenteNombre(docenteNombre);
  }

  List<Asignatura> getByModuloNombre(String moduloNombre) {
    return _localStore.getByModuloNombre(moduloNombre);
  }

  List<Asignatura> getByCurso(String curso) {
    return _localStore.getByCurso(curso);
  }

  Asignatura? getById(String id) {
    return _localStore.getById(id);
  }

  int countByDocenteId(String docenteId) {
    return _localStore.countByDocenteId(docenteId);
  }

  int countByModuloNombre(String moduloNombre) {
    return _localStore.countByModuloNombre(moduloNombre);
  }

  bool docenteTieneAsignaturas(String docenteId) {
    return _localStore.docenteTieneAsignaturas(docenteId);
  }

  List<String> getModulosDisponibles() {
    return _localStore.getModulosDisponibles();
  }

  List<String> getCursosDisponibles() {
    return _localStore.getCursosDisponibles();
  }

  Future<String?> save(Asignatura asignatura) async {
    if (asignatura.nombre.trim().isEmpty) {
      return 'El nombre de la asignatura es obligatorio.';
    }

    if (asignatura.curso.trim().isEmpty) {
      return 'El curso es obligatorio.';
    }

    if (asignatura.docenteId.trim().isEmpty) {
      return 'Debe asignar un docente.';
    }

    // 1. Primero se guarda siempre localmente.
    await _localStore.upsert(asignatura);

    final data = _asignaturaToMap(asignatura);

    // 2. Luego se intenta sincronizar con Firebase si hay internet.
    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('asignaturas').doc(asignatura.id).set(
              data,
              SetOptions(merge: true),
            );
      } catch (_) {
        await _guardarPendiente(
          entidad: 'asignatura',
          accion: 'upsert',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'asignatura',
        accion: 'upsert',
        data: data,
      );
    }

    return null;
  }

  Future<void> delete(String id) async {
    // 1. Primero se elimina localmente.
    await _localStore.delete(id);

    final data = {
      'id': id,
    };

    // 2. Luego se intenta eliminar en Firebase si hay internet.
    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('asignaturas').doc(id).delete();
      } catch (_) {
        await _guardarPendiente(
          entidad: 'asignatura',
          accion: 'eliminar',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'asignatura',
        accion: 'eliminar',
        data: data,
      );
    }
  }

  Future<void> clear() async {
    await _localStore.clear();
  }

  Map<String, dynamic> _asignaturaToMap(Asignatura asignatura) {
    return {
      'id': asignatura.id,
      'nombre': asignatura.nombre,
      'curso': asignatura.curso,
      'docenteId': asignatura.docenteId,
      'docenteNombre': asignatura.docenteNombre,
      'moduloNombre': asignatura.moduloNombre,
      'numeroEstudiantes': asignatura.numeroEstudiantes,
      'activo': asignatura.activo,
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

