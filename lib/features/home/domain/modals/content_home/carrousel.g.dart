// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carrousel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarrouselAdapter extends TypeAdapter<Carrousel> {
  @override
  final int typeId = 12;

  @override
  Carrousel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Carrousel(
      carrouselRepeater: (fields[0] as List?)?.cast<Repeater>(),
    );
  }

  @override
  void write(BinaryWriter writer, Carrousel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.carrouselRepeater);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarrouselAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
