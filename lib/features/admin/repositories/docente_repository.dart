import '../../../services/local/docente_local_store.dart';
import '../models/docente_model.dart';

class DocenteRepository {
  final DocenteLocalStore _localStore;

  DocenteRepository({DocenteLocalStore? localStore})
      : _localStore = localStore ?? DocenteLocalStore();

  /// Obtener todos los docentes
  List<Docente> getAll() {
    return _localStore.getAll();
  }

  /// Obtener solo docentes activos
  List<Docente> getActivos() {
    return _localStore.getActivos();
  }

  /// Obtener docente por ID
  Docente? getById(String id) {
    return _localStore.getById(id);
  }

  /// Guardar nuevo docente
  Future<String?> save(Docente docente) async {
    if (_localStore.existsCedula(docente.cedula)) {
      return 'La cédula ya está registrada.';
    }

    if (_localStore.existsCorreo(docente.correo)) {
      return 'El correo ya está registrado.';
    }

    final nuevoDocente = docente.copyWith(
      fechaCreacion: docente.fechaCreacion.isEmpty
          ? DateTime.now().toIso8601String()
          : docente.fechaCreacion,
      pendienteSync: true,
    );

    await _localStore.upsert(nuevoDocente);
    return null;
  }

  /// Actualizar docente existente
  Future<String?> update(Docente docente) async {
    if (_localStore.existsCedula(docente.cedula, excludeId: docente.id)) {
      return 'La cédula ya está registrada.';
    }

    if (_localStore.existsCorreo(docente.correo, excludeId: docente.id)) {
      return 'El correo ya está registrado.';
    }

    final docenteActualizado = docente.copyWith(
      pendienteSync: true,
    );

    await _localStore.upsert(docenteActualizado);
    return null;
  }

  /// Cambiar estado activo/inactivo
  Future<void> cambiarEstado({
    required String id,
    required bool activo,
  }) async {
    final docente = _localStore.getById(id);
    if (docente == null) return;

    await _localStore.upsert(
      docente.copyWith(
        activo: activo,
        pendienteSync: true,
      ),
    );
  }

  /// Eliminar docente
  Future<void> delete(String id) async {
    await _localStore.delete(id);
  }

  /// Limpiar todos los docentes
  Future<void> clear() async {
    await _localStore.clear();
  }
}
