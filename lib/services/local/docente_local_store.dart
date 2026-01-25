import 'package:hive/hive.dart';
import '../../features/admin/models/docente_model.dart';
import 'local_db_service.dart';
//import 'package:app_academica_offline/features/admin/models/docente_model.dart';


class DocenteLocalStore {
  Box<Docente> get _box => LocalDbService.docentesBox();

  /// Obtener todos los docentes
  List<Docente> getAll() {
    return _box.values.toList();
  }

  /// Obtener docente por ID
  Docente? getById(String id) {
    return _box.get(id);
  }

  /// Crear o actualizar docente
  Future<void> upsert(Docente docente) async {
    await _box.put(docente.id, docente);
  }

  /// Eliminar docente
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Limpiar todos (útil para sync)
  Future<void> clear() async {
    await _box.clear();
  }
}
