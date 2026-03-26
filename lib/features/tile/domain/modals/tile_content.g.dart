// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileContentAdapter extends TypeAdapter<TileContent> {
  @override
  final int typeId = 26;

  @override
  TileContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileContent(
      type: fields[0] as String?,
      slug: fields[1] as String?,
      id: fields[2] as String?,
      idProject: fields[3] as String?,
      results: fields[4] as TileContentResults?,
    );
  }

  @override
  void write(BinaryWriter writer, TileContent obj) {
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
      other is TileContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileContentResultsAdapter extends TypeAdapter<TileContentResults> {
  @override
  final int typeId = 27;

  @override
  TileContentResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileContentResults(
      titleTile: fields[0] as String?,
      descTile: fields[1] as String?,
      imgTile: fields[2] as String?,
      contentTile: fields[3] as String?,
      publishTile: fields[4] as bool?,
      localPath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TileContentResults obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.titleTile)
      ..writeByte(1)
      ..write(obj.descTile)
      ..writeByte(2)
      ..write(obj.imgTile)
      ..writeByte(3)
      ..write(obj.contentTile)
      ..writeByte(4)
      ..write(obj.publishTile)
      ..writeByte(5)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileContentResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
