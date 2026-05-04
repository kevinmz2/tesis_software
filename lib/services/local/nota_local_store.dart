import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_academica_offline/core/network/connectivity_service.dart';
import 'package:app_academica_offline/core/sync/outbox_item.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/services/local/outbox_local_store.dart';

import 'local_db_service.dart';

class NotaLocalStore {
  Box<Nota> get _box => LocalDbService.notasBox();

  final ConnectivityService _connectivityService = ConnectivityService();
  final OutboxLocalStore _outboxLocalStore = OutboxLocalStore();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Nota> getAll() {
    return _box.values.toList();
  }

  List<Nota> getByAsignatura(String asignaturaId) {
    return _box.values
        .where((n) => n.asignaturaId == asignaturaId)
        .toList();
  }

  List<Nota> getByActividad(String actividadId) {
    return _box.values
        .where((n) => n.actividadId == actividadId)
        .toList();
  }

  List<Nota> getByAsignaturaFechaTipo(
    String asignaturaId,
    String fecha,
    String tipo,
  ) {
    return _box.values
        .where(
          (n) =>
              n.asignaturaId == asignaturaId &&
              n.fecha == fecha &&
              n.tipo == tipo,
        )
        .toList();
  }

  List<Nota> getByActividadYFecha(
    String actividadId,
    String fecha,
  ) {
    return _box.values
        .where(
          (n) => n.actividadId == actividadId && n.fecha == fecha,
        )
        .toList();
  }

  Nota? getByActividadEstudiante(
    String actividadId,
    String estudianteId,
  ) {
    try {
      return _box.values.firstWhere(
        (n) =>
            n.actividadId == actividadId &&
            n.estudianteId == estudianteId,
      );
    } catch (_) {
      return null;
    }
  }

  Nota? getByActividadEstudianteFecha(
    String actividadId,
    String estudianteId,
    String fecha,
  ) {
    try {
      return _box.values.firstWhere(
        (n) =>
            n.actividadId == actividadId &&
            n.estudianteId == estudianteId &&
            n.fecha == fecha,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Nota nota) async {
    // 1. Primero se guarda localmente, como ya funcionaba.
    await _box.put(nota.id, nota);

    // 2. Luego se intenta sincronizar o guardar pendiente.
    await _sincronizarGuardarNota(nota);
  }

  Future<void> upsertMany(List<Nota> notas) async {
    final Map<String, Nota> data = {
      for (final n in notas) n.id: n,
    };

    // 1. Primero se guarda todo localmente.
    await _box.putAll(data);

    // 2. Luego se intenta sincronizar cada nota.
    for (final nota in notas) {
      await _sincronizarGuardarNota(nota);
    }
  }

  Future<void> delete(String id) async {
    // 1. Primero se elimina localmente.
    await _box.delete(id);

    // 2. Luego se intenta eliminar en Firebase o guardar pendiente.
    await _sincronizarEliminarNota(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> _sincronizarGuardarNota(Nota nota) async {
    final data = _notaToMap(nota);

    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('notas').doc(data['id']).set(
              data,
              SetOptions(merge: true),
            );
        return;
      } catch (_) {
        await _guardarPendiente(
          entidad: 'nota',
          accion: 'upsert',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'nota',
        accion: 'upsert',
        data: data,
      );
    }
  }

  Future<void> _sincronizarEliminarNota(String id) async {
    final data = {
      'id': id,
    };

    final hayConexion = await _connectivityService.tieneConexion();

    if (hayConexion) {
      try {
        await _firestore.collection('notas').doc(id).delete();
        return;
      } catch (_) {
        await _guardarPendiente(
          entidad: 'nota',
          accion: 'eliminar',
          data: data,
        );
      }
    } else {
      await _guardarPendiente(
        entidad: 'nota',
        accion: 'eliminar',
        data: data,
      );
    }
  }

  Map<String, dynamic> _notaToMap(Nota nota) {
    final dynamic n = nota;

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

    agregarCampo('id', () => n.id);
    agregarCampo('asignaturaId', () => n.asignaturaId);
    agregarCampo('estudianteId', () => n.estudianteId);
    agregarCampo('actividadId', () => n.actividadId);
    agregarCampo('fecha', () => n.fecha);
    agregarCampo('tipo', () => n.tipo);
    agregarCampo('valor', () => n.valor);
    agregarCampo('nota', () => n.nota);
    agregarCampo('observacion', () => n.observacion);
    agregarCampo('descripcion', () => n.descripcion);
    agregarCampo('componente', () => n.componente);

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

