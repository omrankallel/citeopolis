// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'row.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RowAdapter extends TypeAdapter<Row> {
  @override
  final int typeId = 6;

  @override
  Row read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Row(
      title: fields[0] as String?,
      titleColor: fields[1] as String?,
      secondaryTitle: fields[2] as String?,
      radiusBorder: fields[3] as String?,
      edgeBorder: fields[4] as String?,
      borderColor: fields[5] as String?,
      colorBackground: fields[6] as String?,
      automaticPictogram: fields[7] as String?,
      pictogram: fields[8] as String?,
      localPath: fields[9] as String?,
      pictogramName: fields[10] as String?,
      sizeQuickAccess: fields[11] as String?,
      typeLink: fields[12] as String?,
      urlLink: fields[13] as String?,
      tile: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Row obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.localPath)
      ..writeByte(10)
      ..write(obj.pictogramName)
      ..writeByte(11)
      ..write(obj.sizeQuickAccess)
      ..writeByte(12)
      ..write(obj.typeLink)
      ..writeByte(13)
      ..write(obj.urlLink)
      ..writeByte(14)
      ..write(obj.tile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
