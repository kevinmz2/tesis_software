//archivo puente entre la UI  y el Hivee
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';
import 'package:app_academica_offline/services/local/estudiante_local_store.dart';

class EstudianteRepository {
  final EstudianteLocalStore _localStore = EstudianteLocalStore();

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
    await _localStore.upsert(estudiante);
  }

  Future<void> delete(String id) async {
    await _localStore.delete(id);
  }

  Future<void> clear() async {
    await _localStore.clear();
  }
}