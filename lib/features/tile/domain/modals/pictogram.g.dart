// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pictogram.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PictogramAdapter extends TypeAdapter<Pictogram> {
  @override
  final int typeId = 37;

  @override
  Pictogram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pictogram(
      url: fields[0] as String?,
      localPath: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Pictogram obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PictogramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
