import 'package:app_academica_offline/features/docente/models/asistencia_model.dart';
import 'package:app_academica_offline/services/local/asistencia_local_store.dart';

class AsistenciaRepository {
  final AsistenciaLocalStore _localStore = AsistenciaLocalStore();

  List<Asistencia> getAll() {
    return _localStore.getAll();
  }

  List<Asistencia> getByAsignatura(String asignaturaId) {
    return _localStore.getByAsignatura(asignaturaId);
  }

  List<Asistencia> getByFecha(String fecha) {
    return _localStore.getByFecha(fecha);
  }

  Future<void> save(Asistencia asistencia) async {
    await _localStore.upsert(asistencia);
  }

  Future<void> delete(String id) async {
    await _localStore.delete(id);
  }
}