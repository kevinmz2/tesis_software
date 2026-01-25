import 'package:hive/hive.dart';

import 'package:app_academica_offline/features/admin/models/docente_model.dart';
import 'package:app_academica_offline/features/admin/models/institucion_model.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';

class LocalDbService {
  static const String docentesBoxName = 'docentes_box';
  static const String asignaturasBoxName = 'asignaturas_box';
  static const String institucionesBoxName = 'instituciones_box';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DocenteAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AsignaturaAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(InstitucionAdapter());
    }

    await Hive.openBox<Docente>(docentesBoxName);
    await Hive.openBox<Asignatura>(asignaturasBoxName);
    await Hive.openBox<Institucion>(institucionesBoxName);
  }

  static Box<Docente> docentesBox() =>
      Hive.box<Docente>(docentesBoxName);

  static Box<Asignatura> asignaturasBox() =>
      Hive.box<Asignatura>(asignaturasBoxName);

  static Box<Institucion> institucionesBox() =>
      Hive.box<Institucion>(institucionesBoxName);
}
