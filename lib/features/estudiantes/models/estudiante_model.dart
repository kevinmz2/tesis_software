import 'package:hive/hive.dart';

part 'estudiante_model.g.dart';

@HiveType(typeId: 5)
class Estudiante {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombres;

  @HiveField(2)
  final String curso;

  @HiveField(3)
  final String asignaturaId;

  @HiveField(4)
  final String apellidos;

  @HiveField(5)
  final int edad;

  @HiveField(6)
  final String celular;

  @HiveField(7)
  final String tipoSangre;

  @HiveField(8)
  final String contactoEmergenciaNombre;

  @HiveField(9)
  final String contactoEmergenciaCelular;

  Estudiante({
    required this.id,
    required this.nombres,
    required this.curso,
    required this.asignaturaId,
    this.apellidos = '',
    this.edad = 0,
    this.celular = '',
    this.tipoSangre = '',
    this.contactoEmergenciaNombre = '',
    this.contactoEmergenciaCelular = '',
  });

  String get nombreCompleto => '$apellidos $nombres'.trim();

  Estudiante copyWith({
    String? id,
    String? nombres,
    String? curso,
    String? asignaturaId,
    String? apellidos,
    int? edad,
    String? celular,
    String? tipoSangre,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaCelular,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      curso: curso ?? this.curso,
      asignaturaId: asignaturaId ?? this.asignaturaId,
      apellidos: apellidos ?? this.apellidos,
      edad: edad ?? this.edad,
      celular: celular ?? this.celular,
      tipoSangre: tipoSangre ?? this.tipoSangre,
      contactoEmergenciaNombre:
          contactoEmergenciaNombre ?? this.contactoEmergenciaNombre,
      contactoEmergenciaCelular:
          contactoEmergenciaCelular ?? this.contactoEmergenciaCelular,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'curso': curso,
      'asignaturaId': asignaturaId,
      'apellidos': apellidos,
      'edad': edad,
      'celular': celular,
      'tipoSangre': tipoSangre,
      'contactoEmergenciaNombre': contactoEmergenciaNombre,
      'contactoEmergenciaCelular': contactoEmergenciaCelular,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id']?.toString() ?? '',
      nombres: map['nombres']?.toString() ?? map['nombre']?.toString() ?? '',
      curso: map['curso']?.toString() ?? '',
      asignaturaId: map['asignaturaId']?.toString() ?? '',
      apellidos: map['apellidos']?.toString() ?? '',
      edad: int.tryParse(map['edad']?.toString() ?? '0') ?? 0,
      celular: map['celular']?.toString() ?? '',
      tipoSangre: map['tipoSangre']?.toString() ?? '',
      contactoEmergenciaNombre:
          map['contactoEmergenciaNombre']?.toString() ?? '',
      contactoEmergenciaCelular:
          map['contactoEmergenciaCelular']?.toString() ?? '',
    );
  }
}

//modelo de estudiante segun el campo nuevo que me pidio tutor
//con numero de emergencia y eso 
