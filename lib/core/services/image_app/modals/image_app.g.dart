// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageAppAdapter extends TypeAdapter<ImageApp> {
  @override
  final int typeId = 1;

  @override
  ImageApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageApp(
      id: fields[0] as int?,
      filename: fields[1] as String?,
      url: fields[2] as String?,
      localPath: fields[3] as String?,
      width: fields[4] as double?,
      height: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageApp obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filename)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.width)
      ..writeByte(5)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
