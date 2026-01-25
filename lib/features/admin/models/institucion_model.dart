import 'package:hive/hive.dart';

part 'institucion_model.g.dart';

@HiveType(typeId: 3)
class Institucion {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  Institucion({
    required this.id,
    required this.nombre,
  });
}
