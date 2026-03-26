// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_xml_rss_channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FluxXmlRSSChannelAdapter extends TypeAdapter<FluxXmlRSSChannel> {
  @override
  final int typeId = 34;

  @override
  FluxXmlRSSChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FluxXmlRSSChannel(
      title: fields[0] as String?,
      description: fields[1] as String?,
      link: fields[2] as String?,
      language: fields[3] as String?,
      lastBuildDate: fields[4] as String?,
      items: (fields[5] as List).cast<FluxXmlRSSItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, FluxXmlRSSChannel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.link)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.lastBuildDate)
      ..writeByte(5)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluxXmlRSSChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
