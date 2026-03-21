// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actividad_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActividadAdapter extends TypeAdapter<Actividad> {
  @override
  final int typeId = 7;

  @override
  Actividad read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Actividad(
      id: fields[0] as String,
      asignaturaId: fields[1] as String,
      titulo: fields[2] as String,
      descripcion: fields[3] as String,
      tipo: fields[4] as String,
      fecha: fields[5] as String,
      puntajeMaximo: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Actividad obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.asignaturaId)
      ..writeByte(2)
      ..write(obj.titulo)
      ..writeByte(3)
      ..write(obj.descripcion)
      ..writeByte(4)
      ..write(obj.tipo)
      ..writeByte(5)
      ..write(obj.fecha)
      ..writeByte(6)
      ..write(obj.puntajeMaximo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActividadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
