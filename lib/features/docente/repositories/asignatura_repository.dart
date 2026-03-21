import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'package:app_academica_offline/services/local/asignatura_local_store.dart';

class AsignaturaRepository {
  final AsignaturaLocalStore _localStore = AsignaturaLocalStore();

  List<Asignatura> getAll() {
    return _localStore.getAll();
  }

  List<Asignatura> getByDocenteId(String docenteId) {
    return _localStore.getByDocenteId(docenteId);
  }

  Asignatura? getById(String id) {
    return _localStore.getById(id);
  }

  Future<void> save(Asignatura asignatura) async {
    await _localStore.upsert(asignatura);
  }

  Future<void> delete(String id) async {
    await _localStore.delete(id);
  }

  Future<void> clear() async {
    await _localStore.clear();
  }
}