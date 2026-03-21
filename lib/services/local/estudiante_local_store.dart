import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';

import 'local_db_service.dart';

class EstudianteLocalStore {
  Box<Estudiante> get _box => LocalDbService.estudiantesBox();

  List<Estudiante> getAll() {
    return _box.values.toList();
  }

  List<Estudiante> getByAsignatura(String asignaturaId) {
    return _box.values
        .where((e) => e.asignaturaId == asignaturaId)
        .toList();
  }

  Estudiante? getById(String id) {
    return _box.get(id);
  }

  Future<void> upsert(Estudiante estudiante) async {
    await _box.put(estudiante.id, estudiante);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}