// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_map.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileMapAdapter extends TypeAdapter<TileMap> {
  @override
  final int typeId = 28;

  @override
  TileMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileMap(
      type: fields[0] as String?,
      slug: fields[1] as String?,
      id: fields[2] as String?,
      idProject: fields[3] as String?,
      results: fields[4] as TileMapResults?,
    );
  }

  @override
  void write(BinaryWriter writer, TileMap obj) {
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
      other is TileMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileMapResultsAdapter extends TypeAdapter<TileMapResults> {
  @override
  final int typeId = 29;

  @override
  TileMapResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileMapResults(
      titleTile: fields[0] as String?,
      urlTile: fields[1] as String?,
      numberElement: fields[2] as String?,
      idsList: (fields[3] as List?)?.cast<TileMapId>(),
      idsSingle: (fields[4] as List?)?.cast<TileMapId>(),
      publishTile: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, TileMapResults obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.titleTile)
      ..writeByte(1)
      ..write(obj.urlTile)
      ..writeByte(2)
      ..write(obj.numberElement)
      ..writeByte(3)
      ..write(obj.idsList)
      ..writeByte(4)
      ..write(obj.idsSingle)
      ..writeByte(5)
      ..write(obj.publishTile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileMapResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileMapIdAdapter extends TypeAdapter<TileMapId> {
  @override
  final int typeId = 30;

  @override
  TileMapId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileMapId(
      id: fields[0] as int?,
      title: fields[1] as String?,
      balise: fields[2] as String?,
      status: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TileMapId obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.balise)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileMapIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
