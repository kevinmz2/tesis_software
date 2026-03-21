import 'package:hive/hive.dart';

part 'actividad_model.g.dart';

@HiveType(typeId: 7)
class Actividad extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String asignaturaId;

  @HiveField(2)
  final String titulo;

  @HiveField(3)
  final String descripcion;

  @HiveField(4)
  final String tipo; // tarea | examen | participacion | proyecto

  @HiveField(5)
  final String fecha;

  @HiveField(6)
  final double puntajeMaximo;

  Actividad({
    required this.id,
    required this.asignaturaId,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.fecha,
    required this.puntajeMaximo,
  });
}