import 'package:hive/hive.dart';

part 'docente_model.g.dart';

@HiveType(typeId: 1)
class Docente {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String cedula;

  @HiveField(3)
  final int edad;

  @HiveField(4)
  final String correo;

  @HiveField(5)
  final String telefono;

  @HiveField(6)
  final String institucionId;

  Docente({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.edad,
    required this.correo,
    required this.telefono,
    required this.institucionId,
  });
}
