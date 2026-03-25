// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asignatura_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AsignaturaAdapter extends TypeAdapter<Asignatura> {
  @override
  final int typeId = 2;

  @override
  Asignatura read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Asignatura(
      id: fields[0] as String,
      nombre: fields[1] as String,
      curso: fields[2] as String,
      docenteId: fields[3] as String,
      numeroEstudiantes: fields[4] as int,
      docenteNombre: fields[5] as String,
      moduloNombre: fields[6] as String,
      activo: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Asignatura obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.curso)
      ..writeByte(3)
      ..write(obj.docenteId)
      ..writeByte(4)
      ..write(obj.numeroEstudiantes)
      ..writeByte(5)
      ..write(obj.docenteNombre)
      ..writeByte(6)
      ..write(obj.moduloNombre)
      ..writeByte(7)
      ..write(obj.activo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsignaturaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
