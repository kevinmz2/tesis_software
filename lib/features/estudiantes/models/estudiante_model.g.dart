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
      nombres: fields[1] as String,
      curso: fields[2] as String,
      asignaturaId: fields[3] as String,
      apellidos: fields[4] as String,
      edad: fields[5] as int,
      celular: fields[6] as String,
      tipoSangre: fields[7] as String,
      contactoEmergenciaNombre: fields[8] as String,
      contactoEmergenciaCelular: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Estudiante obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombres)
      ..writeByte(2)
      ..write(obj.curso)
      ..writeByte(3)
      ..write(obj.asignaturaId)
      ..writeByte(4)
      ..write(obj.apellidos)
      ..writeByte(5)
      ..write(obj.edad)
      ..writeByte(6)
      ..write(obj.celular)
      ..writeByte(7)
      ..write(obj.tipoSangre)
      ..writeByte(8)
      ..write(obj.contactoEmergenciaNombre)
      ..writeByte(9)
      ..write(obj.contactoEmergenciaCelular);
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
