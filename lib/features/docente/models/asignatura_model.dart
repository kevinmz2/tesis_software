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

  @HiveField(5)
  final String docenteNombre;

  @HiveField(6)
  final String moduloNombre;

  @HiveField(7)
  final bool activo;

  Asignatura({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.docenteId,
    required this.numeroEstudiantes,
    this.docenteNombre = '',
    this.moduloNombre = '',
    this.activo = true,
  });

  Asignatura copyWith({
    String? id,
    String? nombre,
    String? curso,
    String? docenteId,
    int? numeroEstudiantes,
    String? docenteNombre,
    String? moduloNombre,
    bool? activo,
  }) {
    return Asignatura(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      curso: curso ?? this.curso,
      docenteId: docenteId ?? this.docenteId,
      numeroEstudiantes: numeroEstudiantes ?? this.numeroEstudiantes,
      docenteNombre: docenteNombre ?? this.docenteNombre,
      moduloNombre: moduloNombre ?? this.moduloNombre,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'curso': curso,
      'docenteId': docenteId,
      'numeroEstudiantes': numeroEstudiantes,
      'docenteNombre': docenteNombre,
      'moduloNombre': moduloNombre,
      'activo': activo,
    };
  }

  factory Asignatura.fromMap(Map<String, dynamic> map) {
    return Asignatura(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      curso: map['curso']?.toString() ?? '',
      docenteId: map['docenteId']?.toString() ?? '',
      numeroEstudiantes:
          int.tryParse(map['numeroEstudiantes']?.toString() ?? '0') ?? 0,
      docenteNombre: map['docenteNombre']?.toString() ?? '',
      moduloNombre: map['moduloNombre']?.toString() ?? '',
      activo: map['activo'] is bool ? map['activo'] : true,
    );
  }
}
