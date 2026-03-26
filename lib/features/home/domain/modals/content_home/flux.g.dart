// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FluxAdapter extends TypeAdapter<Flux> {
  @override
  final int typeId = 8;

  @override
  Flux read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flux(
      numberElement: fields[0] as String?,
      fluxLink: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Flux obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.numberElement)
      ..writeByte(1)
      ..write(obj.fluxLink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
