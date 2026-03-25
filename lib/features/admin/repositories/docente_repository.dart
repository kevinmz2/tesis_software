import '../../../services/firebase/docente_remote_service.dart';
import '../../../services/local/docente_local_store.dart';
import '../models/docente_model.dart';

class DocenteRepository {
  final DocenteLocalStore _localStore;
  final DocenteRemoteService _remoteService;

  DocenteRepository({
    DocenteLocalStore? localStore,
    DocenteRemoteService? remoteService,
  })  : _localStore = localStore ?? DocenteLocalStore(),
        _remoteService = remoteService ?? DocenteRemoteService();

  Future<List<Docente>> getAll() async {
    print('REPOSITORY: getAll() iniciado');

    await syncPendingChanges();
    await syncFromRemote();

    final locales = _localStore.getAll();
    print('REPOSITORY: docentes locales finales = ${locales.length}');

    for (final docente in locales) {
      print(
        'LOCAL DOCENTE -> id: ${docente.id}, nombre: ${docente.nombre}, correo: ${docente.correo}, pendienteSync: ${docente.pendienteSync}',
      );
    }

    return locales;
  }

  Future<List<Docente>> getActivos() async {
    await syncPendingChanges();
    await syncFromRemote();
    return _localStore.getActivos();
  }

  Docente? getById(String id) {
    return _localStore.getById(id);
  }

  Future<void> syncFromRemote() async {
    try {
      print('REPOSITORY: syncFromRemote() iniciado');

      final remotos = await _remoteService.getDocentes();

      print('REPOSITORY: docentes remotos recibidos = ${remotos.length}');

      for (final remoto in remotos) {
        final local = _localStore.getById(remoto.id);

        final docenteFusionado = Docente(
          id: remoto.id,
          nombre: remoto.nombre,
          cedula: remoto.cedula.isNotEmpty
              ? remoto.cedula
              : (local?.cedula ?? ''),
          edad: remoto.edad != 0 ? remoto.edad : (local?.edad ?? 0),
          correo: remoto.correo.isNotEmpty
              ? remoto.correo
              : (local?.correo ?? ''),
          telefono: remoto.telefono.isNotEmpty
              ? remoto.telefono
              : (local?.telefono ?? ''),
          institucionId: remoto.institucionId.isNotEmpty
              ? remoto.institucionId
              : (local?.institucionId ?? ''),
          institucionNombre: remoto.institucionNombre.isNotEmpty
              ? remoto.institucionNombre
              : (local?.institucionNombre ?? ''),
          activo: remoto.activo,
          fechaCreacion: remoto.fechaCreacion.isNotEmpty
              ? remoto.fechaCreacion
              : (local?.fechaCreacion ?? ''),
          pendienteSync: false,
        );

        await _localStore.upsert(docenteFusionado);
      }

      print('REPOSITORY: syncFromRemote() finalizado');
    } catch (e) {
      print('REPOSITORY ERROR syncFromRemote(): $e');
    }
  }

  Future<void> syncPendingChanges() async {
    final pendientes = _localStore
        .getAll()
        .where((docente) => docente.pendienteSync)
        .toList();

    print('REPOSITORY: pendientes por sincronizar = ${pendientes.length}');

    for (final docente in pendientes) {
      try {
        print('REPOSITORY: sincronizando pendiente -> ${docente.id}');
        await _remoteService.saveDocente(docente);

        await _localStore.upsert(
          docente.copyWith(
            pendienteSync: false,
          ),
        );
      } catch (e) {
        print('REPOSITORY ERROR syncPendingChanges(): $e');
      }
    }
  }

  Future<String?> save(Docente docente) async {
    if (docente.cedula.trim().isNotEmpty &&
        _localStore.existsCedula(docente.cedula)) {
      return 'La cédula ya está registrada.';
    }

    if (docente.correo.trim().isNotEmpty &&
        _localStore.existsCorreo(docente.correo)) {
      return 'El correo ya está registrado.';
    }

    final nuevoDocente = docente.copyWith(
      fechaCreacion: docente.fechaCreacion.isEmpty
          ? DateTime.now().toIso8601String()
          : docente.fechaCreacion,
      pendienteSync: true,
    );

    await _localStore.upsert(nuevoDocente);
    print('REPOSITORY: docente guardado localmente -> ${nuevoDocente.id}');

    try {
      await _remoteService.saveDocente(nuevoDocente);

      await _localStore.upsert(
        nuevoDocente.copyWith(
          pendienteSync: false,
        ),
      );

      print('REPOSITORY: docente sincronizado correctamente');
    } catch (e) {
      print('REPOSITORY ERROR save(): $e');
    }

    return null;
  }

  Future<String?> update(Docente docente) async {
    if (docente.cedula.trim().isNotEmpty &&
        _localStore.existsCedula(docente.cedula, excludeId: docente.id)) {
      return 'La cédula ya está registrada.';
    }

    if (docente.correo.trim().isNotEmpty &&
        _localStore.existsCorreo(docente.correo, excludeId: docente.id)) {
      return 'El correo ya está registrado.';
    }

    final docenteActualizado = docente.copyWith(
      pendienteSync: true,
    );

    await _localStore.upsert(docenteActualizado);
    print('REPOSITORY: docente actualizado localmente -> ${docente.id}');

    try {
      await _remoteService.updateDocente(docenteActualizado);

      await _localStore.upsert(
        docenteActualizado.copyWith(
          pendienteSync: false,
        ),
      );

      print('REPOSITORY: docente actualizado también en Firestore');
    } catch (e) {
      print('REPOSITORY ERROR update(): $e');
    }

    return null;
  }

  Future<void> cambiarEstado({
    required String id,
    required bool activo,
  }) async {
    final docente = _localStore.getById(id);
    if (docente == null) return;

    final actualizado = docente.copyWith(
      activo: activo,
      pendienteSync: true,
    );

    await _localStore.upsert(actualizado);

    try {
      await _remoteService.updateDocente(actualizado);

      await _localStore.upsert(
        actualizado.copyWith(
          pendienteSync: false,
        ),
      );
    } catch (e) {
      print('REPOSITORY ERROR cambiarEstado(): $e');
    }
  }

  Future<void> delete(String id) async {
    final docente = _localStore.getById(id);

    await _localStore.delete(id);

    if (docente == null) return;

    try {
      await _remoteService.deleteDocente(id);
    } catch (e) {
      print('REPOSITORY ERROR delete(): $e');
    }
  }

  Future<void> clear() async {
    await _localStore.clear();
  }
}
