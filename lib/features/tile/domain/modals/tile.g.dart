// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileAdapter extends TypeAdapter<Tile> {
  @override
  final int typeId = 17;

  @override
  Tile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tile(
      id: fields[0] as int?,
      title: fields[1] as String?,
      projectId: fields[2] as String?,
      publishTile: fields[3] as bool?,
      type: fields[4] as TypeTile?,
      details: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.projectId)
      ..writeByte(3)
      ..write(obj.publishTile)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
