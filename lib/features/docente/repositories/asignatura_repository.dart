import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'package:app_academica_offline/services/local/asignatura_local_store.dart';

class AsignaturaRepository {
  final AsignaturaLocalStore _localStore;

  AsignaturaRepository({AsignaturaLocalStore? localStore})
      : _localStore = localStore ?? AsignaturaLocalStore();

  List<Asignatura> getAll() {
    return _localStore.getAll();
  }

  List<Asignatura> getActivas() {
    return _localStore.getActivas();
  }

  List<Asignatura> getByDocenteId(String docenteId) {
    return _localStore.getByDocenteId(docenteId);
  }

  List<Asignatura> getByDocenteNombre(String docenteNombre) {
    return _localStore.getByDocenteNombre(docenteNombre);
  }

  List<Asignatura> getByModuloNombre(String moduloNombre) {
    return _localStore.getByModuloNombre(moduloNombre);
  }

  List<Asignatura> getByCurso(String curso) {
    return _localStore.getByCurso(curso);
  }

  Asignatura? getById(String id) {
    return _localStore.getById(id);
  }

  int countByDocenteId(String docenteId) {
    return _localStore.countByDocenteId(docenteId);
  }

  int countByModuloNombre(String moduloNombre) {
    return _localStore.countByModuloNombre(moduloNombre);
  }

  bool docenteTieneAsignaturas(String docenteId) {
    return _localStore.docenteTieneAsignaturas(docenteId);
  }

  List<String> getModulosDisponibles() {
    return _localStore.getModulosDisponibles();
  }

  List<String> getCursosDisponibles() {
    return _localStore.getCursosDisponibles();
  }

  Future<String?> save(Asignatura asignatura) async {
    if (asignatura.nombre.trim().isEmpty) {
      return 'El nombre de la asignatura es obligatorio.';
    }

    if (asignatura.curso.trim().isEmpty) {
      return 'El curso es obligatorio.';
    }

    if (asignatura.docenteId.trim().isEmpty) {
      return 'Debe asignar un docente.';
    }

    if (asignatura.moduloNombre.trim().isEmpty) {
      return 'El módulo es obligatorio.';
    }

    await _localStore.upsert(asignatura);
    return null;
  }

  Future<void> delete(String id) async {
    await _localStore.delete(id);
  }

  Future<void> clear() async {
    await _localStore.clear();
  }
}
