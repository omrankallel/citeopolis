// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_xml_rss_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FluxXmlRSSItemAdapter extends TypeAdapter<FluxXmlRSSItem> {
  @override
  final int typeId = 35;

  @override
  FluxXmlRSSItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FluxXmlRSSItem(
      title: fields[0] as String?,
      category: fields[1] as String?,
      mainImage: fields[2] as String?,
      eventStartDate: fields[3] as String?,
      eventEndDate: fields[4] as String?,
      link: fields[5] as String?,
      description: fields[6] as String?,
      pubDate: fields[7] as String?,
      guid: fields[8] as String?,
      localPath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FluxXmlRSSItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.mainImage)
      ..writeByte(3)
      ..write(obj.eventStartDate)
      ..writeByte(4)
      ..write(obj.eventEndDate)
      ..writeByte(5)
      ..write(obj.link)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.pubDate)
      ..writeByte(8)
      ..write(obj.guid)
      ..writeByte(9)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluxXmlRSSItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
