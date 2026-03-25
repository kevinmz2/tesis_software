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

  @HiveField(7)
  final String institucionNombre;

  @HiveField(8)
  final bool activo;

  @HiveField(9)
  final String fechaCreacion;

  @HiveField(10)
  final bool pendienteSync;

  Docente({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.edad,
    required this.correo,
    required this.telefono,
    required this.institucionId,
    this.institucionNombre = '',
    this.activo = true,
    this.fechaCreacion = '',
    this.pendienteSync = true,
  });

  Docente copyWith({
    String? id,
    String? nombre,
    String? cedula,
    int? edad,
    String? correo,
    String? telefono,
    String? institucionId,
    String? institucionNombre,
    bool? activo,
    String? fechaCreacion,
    bool? pendienteSync,
  }) {
    return Docente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cedula: cedula ?? this.cedula,
      edad: edad ?? this.edad,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      institucionId: institucionId ?? this.institucionId,
      institucionNombre: institucionNombre ?? this.institucionNombre,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      pendienteSync: pendienteSync ?? this.pendienteSync,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cedula': cedula,
      'edad': edad,
      'correo': correo,
      'telefono': telefono,
      'institucionId': institucionId,
      'institucionNombre': institucionNombre,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
      'pendienteSync': pendienteSync,
    };
  }

  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      cedula: map['cedula']?.toString() ?? '',
      edad: int.tryParse(map['edad']?.toString() ?? '0') ?? 0,
      correo: map['correo']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      institucionId: map['institucionId']?.toString() ?? '',
      institucionNombre: map['institucionNombre']?.toString() ?? '',
      activo: map['activo'] is bool ? map['activo'] : true,
      fechaCreacion: map['fechaCreacion']?.toString() ?? '',
      pendienteSync:
          map['pendienteSync'] is bool ? map['pendienteSync'] : true,
    );
  }
}

