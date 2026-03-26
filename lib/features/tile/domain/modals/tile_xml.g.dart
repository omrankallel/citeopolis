// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_xml.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileXmlAdapter extends TypeAdapter<TileXml> {
  @override
  final int typeId = 31;

  @override
  TileXml read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileXml(
      type: fields[0] as String?,
      slug: fields[1] as String?,
      id: fields[2] as String?,
      idProject: fields[3] as String?,
      results: fields[4] as TileXmlResults?,
    );
  }

  @override
  void write(BinaryWriter writer, TileXml obj) {
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
      other is TileXmlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileXmlResultsAdapter extends TypeAdapter<TileXmlResults> {
  @override
  final int typeId = 32;

  @override
  TileXmlResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileXmlResults(
      titleTile: fields[0] as String?,
      urlTile: fields[1] as String?,
      numberElement: fields[2] as String?,
      feedThematic: fields[3] as String?,
      idsList: (fields[4] as List?)?.cast<TileXmlId>(),
      idsSingle: (fields[5] as List?)?.cast<TileXmlId>(),
      publishTile: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, TileXmlResults obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.titleTile)
      ..writeByte(1)
      ..write(obj.urlTile)
      ..writeByte(2)
      ..write(obj.numberElement)
      ..writeByte(3)
      ..write(obj.feedThematic)
      ..writeByte(4)
      ..write(obj.idsList)
      ..writeByte(5)
      ..write(obj.idsSingle)
      ..writeByte(6)
      ..write(obj.publishTile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileXmlResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileXmlIdAdapter extends TypeAdapter<TileXmlId> {
  @override
  final int typeId = 33;

  @override
  TileXmlId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileXmlId(
      id: fields[0] as int?,
      title: fields[1] as String?,
      balise: fields[2] as String?,
      status: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TileXmlId obj) {
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
      other is TileXmlIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
