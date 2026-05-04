// archivo puente entre la UI y Hive
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_academica_offline/core/network/connectivity_service.dart';
import 'package:app_academica_offline/core/sync/outbox_item.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';
import 'package:app_academica_offline/services/local/outbox_local_store.dart';

class EstudianteRepository {
  final EstudianteLocalStore _localStore;
  final ConnectivityService _connectivityService;
  final OutboxLocalStore _outboxLocalStore;
  final FirebaseFirestore _firestore;

  EstudianteRepository({
    EstudianteLocalStore? localStore,
    ConnectivityService? connectivityService,
    OutboxLocalStore? outboxLocalStore,
    FirebaseFirestore? firestore,
  })  : _localStore = localStore ?? EstudianteLocalStore(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _outboxLocalStore = outboxLocalStore ?? OutboxLocalStore(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  List<Estudiante> getAll() {
    return _localStore.getAll();
  }

  List<Estudiante> getByAsignatura(String asignaturaId) {
    return _localStore.getByAsignatura(asignaturaId);
  }

  Estudiante? getById(String id) {
    return _localStore.getById(id);
  }

  Future<void> save(Estudiante estudiante) async {
    // 1. Siempre se guarda primero en Hive local.
    await _localStore.upsert(estudiante);

    final data = _estudianteToMap(estudiante);

    // 2. Luego se intenta sincronizar con Firebase.
    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('estudiantes').doc(data['id']).set(
              data,
              SetOptions(merge: true),
            );
      } catch (_) {
        await _guardarPendiente(
          entidad: 'estudiante',
          accion: 'upsert',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'estudiante',
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
        await _firestore.collection('estudiantes').doc(id).delete();
      } catch (_) {
        await _guardarPendiente(
          entidad: 'estudiante',
          accion: 'eliminar',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'estudiante',
        accion: 'eliminar',
        data: data,
      );
    }
  }

  Future<void> clear() async {
    await _localStore.clear();
  }

  Map<String, dynamic> _estudianteToMap(Estudiante estudiante) {
    final dynamic e = estudiante;

    final data = <String, dynamic>{};

    void agregarCampo(String key, dynamic Function() leer) {
      try {
        final value = leer();

        if (value != null) {
          data[key] = value;
        }
      } catch (_) {
        // Si el modelo no tiene algún campo opcional, no se rompe la app.
      }
    }

    agregarCampo('id', () => e.id);
    agregarCampo('nombre', () => e.nombre);
    agregarCampo('curso', () => e.curso);
    agregarCampo('asignaturaId', () => e.asignaturaId);

    // Campos adicionales si tu modelo ya los tiene.
    agregarCampo('edad', () => e.edad);
    agregarCampo('celular', () => e.celular);
    agregarCampo('tipoSangre', () => e.tipoSangre);
    agregarCampo('contactoEmergenciaNombre', () => e.contactoEmergenciaNombre);
    agregarCampo(
      'contactoEmergenciaTelefono',
      () => e.contactoEmergenciaTelefono,
    );
    agregarCampo('activo', () => e.activo);

    data['actualizadoEn'] = DateTime.now().toIso8601String();

    return data;
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

