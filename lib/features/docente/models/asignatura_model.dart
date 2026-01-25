import 'package:hive/hive.dart';

part 'asignatura_model.g.dart';

@HiveType(typeId: 2)
class Asignatura {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String curso;

  @HiveField(3)
  final String docenteId;

  @HiveField(4)
  final int numeroEstudiantes;

  Asignatura({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.docenteId,
    required this.numeroEstudiantes,
  });
}
