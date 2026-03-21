import 'package:hive/hive.dart';

part 'estudiante_model.g.dart';

@HiveType(typeId: 5)
class Estudiante {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String curso;

  @HiveField(3)
  final String asignaturaId;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.asignaturaId,
  });
}