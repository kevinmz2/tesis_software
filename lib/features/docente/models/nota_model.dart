import 'package:hive/hive.dart';

part 'nota_model.g.dart';

@HiveType(typeId: 6)
class Nota extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String asignaturaId;

  @HiveField(2)
  final String estudianteId;

  @HiveField(3)
  final String fecha;

  @HiveField(4)
  final String tipo; // tarea | examen | final

  @HiveField(5)
  final double nota;

  @HiveField(6)
  final String? observacion;

  @HiveField(7)
  final String actividadId;

  Nota({
    required this.id,
    required this.asignaturaId,
    required this.estudianteId,
    required this.fecha,
    required this.tipo,
    required this.nota,
    this.observacion,
    required this.actividadId,
  });
}