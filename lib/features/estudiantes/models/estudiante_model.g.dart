// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estudiante_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EstudianteAdapter extends TypeAdapter<Estudiante> {
  @override
  final int typeId = 5;

  @override
  Estudiante read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Estudiante(
      id: fields[0] as String,
      nombre: fields[1] as String,
      curso: fields[2] as String,
      asignaturaId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Estudiante obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.curso)
      ..writeByte(3)
      ..write(obj.asignaturaId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstudianteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
