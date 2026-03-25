// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docente_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocenteAdapter extends TypeAdapter<Docente> {
  @override
  final int typeId = 1;

  @override
  Docente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Docente(
      id: fields[0] as String,
      nombre: fields[1] as String,
      cedula: fields[2] as String,
      edad: fields[3] as int,
      correo: fields[4] as String,
      telefono: fields[5] as String,
      institucionId: fields[6] as String,
      institucionNombre: fields[7] as String,
      activo: fields[8] as bool,
      fechaCreacion: fields[9] as String,
      pendienteSync: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Docente obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.cedula)
      ..writeByte(3)
      ..write(obj.edad)
      ..writeByte(4)
      ..write(obj.correo)
      ..writeByte(5)
      ..write(obj.telefono)
      ..writeByte(6)
      ..write(obj.institucionId)
      ..writeByte(7)
      ..write(obj.institucionNombre)
      ..writeByte(8)
      ..write(obj.activo)
      ..writeByte(9)
      ..write(obj.fechaCreacion)
      ..writeByte(10)
      ..write(obj.pendienteSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocenteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
