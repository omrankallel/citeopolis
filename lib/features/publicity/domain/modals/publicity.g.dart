// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publicity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublicityAdapter extends TypeAdapter<Publicity> {
  @override
  final int typeId = 0;

  @override
  Publicity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Publicity(
      id: fields[0] as int?,
      positionTitlePublicity: fields[1] as String?,
      titlePublicity: fields[2] as String?,
      leadPublicity: fields[3] as String?,
      imgPublicity: fields[4] as ImageApp?,
      showButton: fields[5] as bool?,
      buttonText: fields[6] as String?,
      typeLinkPublicity: fields[7] as String?,
      urlLink: fields[8] as String?,
      tile: fields[9] as String?,
      displayStartDatePublicity: fields[10] as String?,
      displayEndDatePublicity: fields[11] as String?,
      displayTimeSeconds: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Publicity obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.positionTitlePublicity)
      ..writeByte(2)
      ..write(obj.titlePublicity)
      ..writeByte(3)
      ..write(obj.leadPublicity)
      ..writeByte(4)
      ..write(obj.imgPublicity)
      ..writeByte(5)
      ..write(obj.showButton)
      ..writeByte(6)
      ..write(obj.buttonText)
      ..writeByte(7)
      ..write(obj.typeLinkPublicity)
      ..writeByte(8)
      ..write(obj.urlLink)
      ..writeByte(9)
      ..write(obj.tile)
      ..writeByte(10)
      ..write(obj.displayStartDatePublicity)
      ..writeByte(11)
      ..write(obj.displayEndDatePublicity)
      ..writeByte(12)
      ..write(obj.displayTimeSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
