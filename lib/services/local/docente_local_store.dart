import 'package:hive/hive.dart';
import '../../features/admin/models/docente_model.dart';
import 'local_db_service.dart';

class DocenteLocalStore {
  Box<Docente> get _box => LocalDbService.docentesBox();

  /// Obtener todos los docentes
  List<Docente> getAll() {
    final docentes = _box.values.toList();
    docentes.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return docentes;
  }

  /// Obtener solo docentes activos
  List<Docente> getActivos() {
    return _box.values.where((d) => d.activo).toList();
  }

  /// Obtener docente por ID
  Docente? getById(String id) {
    return _box.get(id);
  }

  /// Buscar docente por cédula
  Docente? getByCedula(String cedula) {
    try {
      return _box.values.firstWhere((d) => d.cedula == cedula);
    } catch (_) {
      return null;
    }
  }

  /// Buscar docente por correo
  Docente? getByCorreo(String correo) {
    try {
      return _box.values.firstWhere(
        (d) => d.correo.toLowerCase() == correo.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Verificar si ya existe una cédula
  bool existsCedula(String cedula, {String? excludeId}) {
    return _box.values.any(
      (d) => d.cedula == cedula && d.id != excludeId,
    );
  }

  /// Verificar si ya existe un correo
  bool existsCorreo(String correo, {String? excludeId}) {
    return _box.values.any(
      (d) => d.correo.toLowerCase() == correo.toLowerCase() && d.id != excludeId,
    );
  }

  /// Crear o actualizar docente
  Future<void> upsert(Docente docente) async {
    await _box.put(docente.id, docente);
  }

  /// Eliminar docente
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Limpiar todos
  Future<void> clear() async {
    await _box.clear();
  }
}

