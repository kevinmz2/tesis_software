import 'package:hive/hive.dart';

part 'asistencia_model.g.dart';

@HiveType(typeId: 4) // usa aquí el typeId REAL que ya tenías antes
class Asistencia extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String asignaturaId;

  @HiveField(2)
  final String estudianteId;

  @HiveField(3)
  final String fecha;

  @HiveField(4)
  final String estado;

  @HiveField(5)
  final String? observacion;

  Asistencia({
    required this.id,
    required this.asignaturaId,
    required this.estudianteId,
    required this.fecha,
    required this.estado,
    this.observacion,
  });
}