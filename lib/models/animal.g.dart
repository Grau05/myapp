// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimalAdapter extends TypeAdapter<Animal> {
  @override
  final int typeId = 0;

  @override
  Animal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Animal(
      id: fields[0] as String,
      nombre: fields[1] as String?,
      historial: (fields[2] as List?)?.cast<Peso>(),
    );
  }

  @override
  void write(BinaryWriter writer, Animal obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.historial);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
