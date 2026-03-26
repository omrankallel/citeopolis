// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_bar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TabBarAdapter extends TypeAdapter<TabBar> {
  @override
  final int typeId = 13;

  @override
  TabBar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabBar(
      titleTabBar: fields[0] as String?,
      pictoImg: fields[1] as ImageApp?,
      typeLinkTabBar: fields[2] as String?,
      tile: fields[3] as String?,
      urlLink: fields[4] as String?,
      publicTabBar: fields[5] as bool?,
      icon: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TabBar obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.titleTabBar)
      ..writeByte(1)
      ..write(obj.pictoImg)
      ..writeByte(2)
      ..write(obj.typeLinkTabBar)
      ..writeByte(3)
      ..write(obj.tile)
      ..writeByte(4)
      ..write(obj.urlLink)
      ..writeByte(5)
      ..write(obj.publicTabBar)
      ..writeByte(6)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabBarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
