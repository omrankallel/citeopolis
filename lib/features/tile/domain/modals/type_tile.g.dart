// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_tile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeTileAdapter extends TypeAdapter<TypeTile> {
  @override
  final int typeId = 18;

  @override
  TypeTile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeTile(
      slug: fields[0] as String?,
      name: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TypeTile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.slug)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeTileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
