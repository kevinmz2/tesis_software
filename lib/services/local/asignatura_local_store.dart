import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'local_db_service.dart';

class AsignaturaLocalStore {
  Box<Asignatura> get _box => LocalDbService.asignaturasBox();

  List<Asignatura> getAll() {
    final asignaturas = _box.values.toList();
    asignaturas.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );
    return asignaturas;
  }

  Asignatura? getById(String id) {
    return _box.get(id);
  }

  List<Asignatura> getActivas() {
    return _box.values.where((a) => a.activo).toList();
  }

  List<Asignatura> getByDocenteId(String docenteId) {
    return _box.values
        .where(
          (a) =>
              a.docenteId.trim().toLowerCase() ==
              docenteId.trim().toLowerCase(),
        )
        .toList();
  }

  List<Asignatura> getByDocenteNombre(String docenteNombre) {
    return _box.values
        .where(
          (a) =>
              a.docenteNombre.trim().toLowerCase() ==
              docenteNombre.trim().toLowerCase(),
        )
        .toList();
  }

  List<Asignatura> getByModuloNombre(String moduloNombre) {
    return _box.values
        .where(
          (a) =>
              a.moduloNombre.trim().toLowerCase() ==
              moduloNombre.trim().toLowerCase(),
        )
        .toList();
  }

  List<Asignatura> getByCurso(String curso) {
    return _box.values
        .where(
          (a) => a.curso.trim().toLowerCase() == curso.trim().toLowerCase(),
        )
        .toList();
  }

  int countByDocenteId(String docenteId) {
    return _box.values
        .where(
          (a) =>
              a.docenteId.trim().toLowerCase() ==
              docenteId.trim().toLowerCase(),
        )
        .length;
  }

  int countByModuloNombre(String moduloNombre) {
    return _box.values
        .where(
          (a) =>
              a.moduloNombre.trim().toLowerCase() ==
              moduloNombre.trim().toLowerCase(),
        )
        .length;
  }

  bool docenteTieneAsignaturas(String docenteId) {
    return _box.values.any(
      (a) =>
          a.docenteId.trim().toLowerCase() == docenteId.trim().toLowerCase(),
    );
  }

  List<String> getModulosDisponibles() {
    final modulos = _box.values
        .map((a) => a.moduloNombre.trim())
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();

    modulos.sort();
    return modulos;
  }

  List<String> getCursosDisponibles() {
    final cursos = _box.values
        .map((a) => a.curso.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    cursos.sort();
    return cursos;
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
