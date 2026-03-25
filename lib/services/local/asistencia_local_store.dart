// para operaciones basicas: guardar asistencia
// leer, leer por asignatura, por fecha y eliminar
import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/docente/models/asistencia_model.dart';

import 'local_db_service.dart';

class AsistenciaLocalStore {
  Box<Asistencia> get _box => LocalDbService.asistenciasBox();

  List<Asistencia> getAll() {
    return _box.values.toList();
  }

  List<Asistencia> getByAsignatura(String asignaturaId) {
    return _box.values
        .where((a) => a.asignaturaId == asignaturaId)
        .toList();
  }

  List<Asistencia> getByFecha(String fecha) {
    return _box.values.where((a) => a.fecha == fecha).toList();
  }

  List<Asistencia> getByAsignaturaAndFecha(String asignaturaId, String fecha) {
    return _box.values
        .where((a) => a.asignaturaId == asignaturaId && a.fecha == fecha)
        .toList();
  }

  Asistencia? getByAsignaturaEstudianteAndFecha(
    String asignaturaId,
    String estudianteId,
    String fecha,
  ) {
    try {
      return _box.values.firstWhere(
        (a) =>
            a.asignaturaId == asignaturaId &&
            a.estudianteId == estudianteId &&
            a.fecha == fecha,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Asistencia asistencia) async {
    await _box.put(asistencia.id, asistencia);
  }

  Future<void> upsertMany(List<Asistencia> asistencias) async {
    final Map<String, Asistencia> data = {
      for (final a in asistencias) a.id: a,
    };
    await _box.putAll(data);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

