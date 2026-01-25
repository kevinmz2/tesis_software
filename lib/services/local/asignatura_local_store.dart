import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';

import 'local_db_service.dart';

class AsignaturaLocalStore {
  Box<Asignatura> get _box => LocalDbService.asignaturasBox();

  List<Asignatura> getAll() {
    return _box.values.toList();
  }

  List<Asignatura> getByDocente(String docenteId) {
    return _box.values
        .where((a) => a.docenteId == docenteId)
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
