import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'local_db_service.dart';

class AsignaturaLocalStore {
  Box<Asignatura> get _box => LocalDbService.asignaturasBox();

  List<Asignatura> getAll() {
    return _box.values.toList();
  }

  Asignatura? getById(String id) {
    return _box.get(id);
  }

  List<Asignatura> getByDocenteId(String docenteId) {
    return _box.values
        .where(
          (a) => a.docenteId.trim().toLowerCase() ==
              docenteId.trim().toLowerCase(),
        )
        .toList();
  }

  Future<void> upsert(Asignatura asignatura) async {
    await _box.put(asignatura.id, asignatura);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}