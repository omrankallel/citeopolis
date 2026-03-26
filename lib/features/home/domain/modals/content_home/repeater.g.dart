// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repeater.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepeaterAdapter extends TypeAdapter<Repeater> {
  @override
  final int typeId = 9;

  @override
  Repeater read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Repeater(
      repTitle: fields[0] as String?,
      repThematic: fields[1] as String?,
      repPictoImg: fields[2] as String?,
      localPath: fields[3] as String?,
      repStartDate: fields[4] as String?,
      repEndDate: fields[5] as String?,
      repTypeLink: fields[6] as String?,
      repTile: fields[7] as String?,
      repUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Repeater obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.repTitle)
      ..writeByte(1)
      ..write(obj.repThematic)
      ..writeByte(2)
      ..write(obj.repPictoImg)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.repStartDate)
      ..writeByte(5)
      ..write(obj.repEndDate)
      ..writeByte(6)
      ..write(obj.repTypeLink)
      ..writeByte(7)
      ..write(obj.repTile)
      ..writeByte(8)
      ..write(obj.repUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeaterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
