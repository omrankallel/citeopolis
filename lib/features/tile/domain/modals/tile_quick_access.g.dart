// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_quick_access.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileQuickAccessAdapter extends TypeAdapter<TileQuickAccess> {
  @override
  final int typeId = 23;

  @override
  TileQuickAccess read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileQuickAccess(
      type: fields[0] as String?,
      slug: fields[1] as String?,
      id: fields[2] as String?,
      idProject: fields[3] as String?,
      results: fields[4] as TileQuickAccessResults?,
    );
  }

  @override
  void write(BinaryWriter writer, TileQuickAccess obj) {
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
      other is TileQuickAccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TileQuickAccessResultsAdapter
    extends TypeAdapter<TileQuickAccessResults> {
  @override
  final int typeId = 24;

  @override
  TileQuickAccessResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileQuickAccessResults(
      data: (fields[0] as List?)?.cast<QuickAccessData>(),
    );
  }

  @override
  void write(BinaryWriter writer, TileQuickAccessResults obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileQuickAccessResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuickAccessDataAdapter extends TypeAdapter<QuickAccessData> {
  @override
  final int typeId = 25;

  @override
  QuickAccessData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuickAccessData(
      title: fields[0] as String?,
      titleColor: fields[1] as String?,
      secondaryTitle: fields[2] as String?,
      radiusBorder: fields[3] as String?,
      edgeBorder: fields[4] as String?,
      borderColor: fields[5] as String?,
      colorBackground: fields[6] as String?,
      automaticPictogram: fields[7] as String?,
      pictogram: fields[8] as Pictogram?,
      sizeQuickAccess: fields[9] as String?,
      typeLink: fields[10] as String?,
      urlLink: fields[11] as String?,
      tile: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuickAccessData obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.titleColor)
      ..writeByte(2)
      ..write(obj.secondaryTitle)
      ..writeByte(3)
      ..write(obj.radiusBorder)
      ..writeByte(4)
      ..write(obj.edgeBorder)
      ..writeByte(5)
      ..write(obj.borderColor)
      ..writeByte(6)
      ..write(obj.colorBackground)
      ..writeByte(7)
      ..write(obj.automaticPictogram)
      ..writeByte(8)
      ..write(obj.pictogram)
      ..writeByte(9)
      ..write(obj.sizeQuickAccess)
      ..writeByte(10)
      ..write(obj.typeLink)
      ..writeByte(11)
      ..write(obj.urlLink)
      ..writeByte(12)
      ..write(obj.tile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickAccessDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
