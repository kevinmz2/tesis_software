import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_academica_offline/core/network/connectivity_service.dart';
import 'package:app_academica_offline/core/sync/outbox_item.dart';
import 'package:app_academica_offline/features/docente/models/actividad_model.dart';
import 'package:app_academica_offline/services/local/outbox_local_store.dart';

import 'local_db_service.dart';

class ActividadLocalStore {
  Box<Actividad> get _box => LocalDbService.actividadesBox();

  final ConnectivityService _connectivityService = ConnectivityService();
  final OutboxLocalStore _outboxLocalStore = OutboxLocalStore();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Actividad> getAll() {
    return _box.values.toList();
  }

  List<Actividad> getByAsignatura(String asignaturaId) {
    return _box.values
        .where((a) => a.asignaturaId == asignaturaId)
        .toList();
  }

  Actividad? getById(String id) {
    return _box.get(id);
  }

  Future<void> upsert(Actividad actividad) async {
    // 1. Primero se guarda localmente, como ya funcionaba.
    await _box.put(actividad.id, actividad);

    // 2. Luego se intenta sincronizar o guardar pendiente.
    await _sincronizarGuardarActividad(actividad);
  }

  Future<void> delete(String id) async {
    // 1. Primero se elimina localmente.
    await _box.delete(id);

    // 2. Luego se intenta eliminar en Firebase o guardar pendiente.
    await _sincronizarEliminarActividad(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> _sincronizarGuardarActividad(Actividad actividad) async {
    final data = _actividadToMap(actividad);

    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('actividades').doc(data['id']).set(
              data,
              SetOptions(merge: true),
            );
        return;
      } catch (_) {
        await _guardarPendiente(
          entidad: 'actividad',
          accion: 'upsert',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'actividad',
        accion: 'upsert',
        data: data,
      );
    }
  }

  Future<void> _sincronizarEliminarActividad(String id) async {
    final data = {
      'id': id,
    };

    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('actividades').doc(id).delete();
        return;
      } catch (_) {
        await _guardarPendiente(
          entidad: 'actividad',
          accion: 'eliminar',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'actividad',
        accion: 'eliminar',
        data: data,
      );
    }
  }

  Map<String, dynamic> _actividadToMap(Actividad actividad) {
    final dynamic a = actividad;

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

    agregarCampo('id', () => a.id);
    agregarCampo('asignaturaId', () => a.asignaturaId);
    agregarCampo('nombre', () => a.nombre);
    agregarCampo('descripcion', () => a.descripcion);
    agregarCampo('tipo', () => a.tipo);
    agregarCampo('fecha', () => a.fecha);
    agregarCampo('puntaje', () => a.puntaje);
    agregarCampo('valor', () => a.valor);
    agregarCampo('componente', () => a.componente);
    agregarCampo('activo', () => a.activo);

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

