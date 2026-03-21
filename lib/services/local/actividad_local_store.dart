import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/docente/models/actividad_model.dart';
import 'local_db_service.dart';

class ActividadLocalStore {
  Box<Actividad> get _box => LocalDbService.actividadesBox();

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
    await _box.put(actividad.id, actividad);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}