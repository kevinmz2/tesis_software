// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotaAdapter extends TypeAdapter<Nota> {
  @override
  final int typeId = 6;

  @override
  Nota read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nota(
      id: fields[0] as String,
      asignaturaId: fields[1] as String,
      estudianteId: fields[2] as String,
      fecha: fields[3] as String,
      tipo: fields[4] as String,
      nota: fields[5] as double,
      observacion: fields[6] as String?,
      actividadId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Nota obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.asignaturaId)
      ..writeByte(2)
      ..write(obj.estudianteId)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.tipo)
      ..writeByte(5)
      ..write(obj.nota)
      ..writeByte(6)
      ..write(obj.observacion)
      ..writeByte(7)
      ..write(obj.actividadId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
