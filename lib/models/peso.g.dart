// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peso.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PesoAdapter extends TypeAdapter<Peso> {
  @override
  final int typeId = 1;

  @override
  Peso read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Peso(
      fecha: fields[0] as DateTime,
      peso: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Peso obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.fecha)
      ..writeByte(1)
      ..write(obj.peso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PesoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
