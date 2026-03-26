// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectionAdapter extends TypeAdapter<Section> {
  @override
  final int typeId = 36;

  @override
  Section read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Section(
      type: fields[0] as String?,
      order: fields[1] as int?,
      hidden: fields[2] as bool?,
      carrousel: fields[3] as Carrousel?,
      quickAccess: fields[4] as QuickAccess?,
      news: fields[5] as News?,
      event: fields[6] as Event?,
      publication: fields[7] as Publication?,
    );
  }

  @override
  void write(BinaryWriter writer, Section obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.order)
      ..writeByte(2)
      ..write(obj.hidden)
      ..writeByte(3)
      ..write(obj.carrousel)
      ..writeByte(4)
      ..write(obj.quickAccess)
      ..writeByte(5)
      ..write(obj.news)
      ..writeByte(6)
      ..write(obj.event)
      ..writeByte(7)
      ..write(obj.publication);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
