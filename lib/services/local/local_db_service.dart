// registra los adapters y abre las cajas locales de Hive
import 'package:hive/hive.dart';

import 'package:app_academica_offline/features/admin/models/docente_model.dart';
import 'package:app_academica_offline/features/admin/models/institucion_model.dart';
import 'package:app_academica_offline/features/docente/models/asignatura_model.dart';
import 'package:app_academica_offline/features/docente/models/asistencia_model.dart';
import 'package:app_academica_offline/features/docente/models/nota_model.dart';
import 'package:app_academica_offline/features/estudiantes/models/estudiante_model.dart';

class LocalDbService {
  static const String docentesBoxName = 'docentes_box';
  static const String asignaturasBoxName = 'asignaturas_box';
  static const String institucionesBoxName = 'instituciones_box';
  static const String asistenciasBoxName = 'asistencias_box';
  static const String estudiantesBoxName = 'estudiantes_box';
  static const String notasBoxName = 'notas_box';

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

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AsistenciaAdapter());
    }

    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(EstudianteAdapter());
    }

    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(NotaAdapter());
    }

    await Hive.openBox<Docente>(docentesBoxName);
    await Hive.openBox<Asignatura>(asignaturasBoxName);
    await Hive.openBox<Institucion>(institucionesBoxName);
    await Hive.openBox<Asistencia>(asistenciasBoxName);
    await Hive.openBox<Estudiante>(estudiantesBoxName);
    await Hive.openBox<Nota>(notasBoxName);
  }

  static Box<Docente> docentesBox() => Hive.box<Docente>(docentesBoxName);

  static Box<Asignatura> asignaturasBox() =>
      Hive.box<Asignatura>(asignaturasBoxName);

  static Box<Institucion> institucionesBox() =>
      Hive.box<Institucion>(institucionesBoxName);

  static Box<Asistencia> asistenciasBox() =>
      Hive.box<Asistencia>(asistenciasBoxName);

  static Box<Estudiante> estudiantesBox() =>
      Hive.box<Estudiante>(estudiantesBoxName);

  static Box<Nota> notasBox() => Hive.box<Nota>(notasBoxName);
}