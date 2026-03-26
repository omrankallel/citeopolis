// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_url.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileUrlAdapter extends TypeAdapter<TileUrl> {
  @override
  final int typeId = 21;

  @override
  TileUrl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileUrl(
      type: fields[0] as String?,
      slug: fields[1] as String?,
      id: fields[2] as String?,
      idProject: fields[3] as String?,
      results: fields[4] as TileUrlResults?,
    );
  }

  @override
  void write(BinaryWriter writer, TileUrl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.slug)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.idProject)
      ..writeByte(4)
      ..write(obj.results);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileUrlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileUrlResultsAdapter extends TypeAdapter<TileUrlResults> {
  @override
  final int typeId = 22;

  @override
  TileUrlResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileUrlResults(
      titleTile: fields[0] as String?,
      typeLink: fields[1] as String?,
      tile: fields[2] as String?,
      urlTile: fields[3] as String?,
      publishTile: fields[4] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, TileUrlResults obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.titleTile)
      ..writeByte(1)
      ..write(obj.typeLink)
      ..writeByte(2)
      ..write(obj.tile)
      ..writeByte(3)
      ..write(obj.urlTile)
      ..writeByte(4)
      ..write(obj.publishTile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileUrlResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
