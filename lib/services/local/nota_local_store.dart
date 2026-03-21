import 'package:hive/hive.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'local_db_service.dart';

class NotaLocalStore {
  Box<Nota> get _box => LocalDbService.notasBox();

  List<Nota> getAll() {
    return _box.values.toList();
  }

  List<Nota> getByAsignatura(String asignaturaId) {
    return _box.values
        .where((n) => n.asignaturaId == asignaturaId)
        .toList();
  }

  List<Nota> getByAsignaturaFechaTipo(
    String asignaturaId,
    String fecha,
    String tipo,
  ) {
    return _box.values
        .where(
          (n) =>
              n.asignaturaId == asignaturaId &&
              n.fecha == fecha &&
              n.tipo == tipo,
        )
        .toList();
  }

  Nota? getByAsignaturaEstudianteFechaTipo(
    String asignaturaId,
    String estudianteId,
    String fecha,
    String tipo,
  ) {
    try {
      return _box.values.firstWhere(
        (n) =>
            n.asignaturaId == asignaturaId &&
            n.estudianteId == estudianteId &&
            n.fecha == fecha &&
            n.tipo == tipo,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Nota nota) async {
    await _box.put(nota.id, nota);
  }

  Future<void> upsertMany(List<Nota> notas) async {
    final Map<String, Nota> data = {
      for (final n in notas) n.id: n,
    };
    await _box.putAll(data);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}