// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asistencia_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AsistenciaAdapter extends TypeAdapter<Asistencia> {
  @override
  final int typeId = 4;

  @override
  Asistencia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Asistencia(
      id: fields[0] as String,
      asignaturaId: fields[1] as String,
      estudianteId: fields[2] as String,
      fecha: fields[3] as String,
      estado: fields[4] as String,
      observacion: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Asistencia obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.asignaturaId)
      ..writeByte(2)
      ..write(obj.estudianteId)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.estado)
      ..writeByte(5)
      ..write(obj.observacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsistenciaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
