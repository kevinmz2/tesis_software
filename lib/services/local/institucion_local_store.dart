import 'package:hive/hive.dart';
import '../../features/admin/models/institucion_model.dart';
import 'local_db_service.dart';


class InstitucionLocalStore {
  Box<Institucion> get _box => LocalDbService.institucionesBox();

  List<Institucion> getAll() {
    return _box.values.toList();
  }

  Future<void> upsert(Institucion institucion) async {
    await _box.put(institucion.id, institucion);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
