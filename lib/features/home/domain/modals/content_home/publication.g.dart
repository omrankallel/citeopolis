// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublicationAdapter extends TypeAdapter<Publication> {
  @override
  final int typeId = 10;

  @override
  Publication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Publication(
      titlePublication: fields[0] as String?,
      typeLinkPublication: fields[1] as String?,
      tile: fields[2] as String?,
      urlLink: fields[3] as String?,
      displayMode: fields[4] as String?,
      flux: fields[5] as Flux?,
      publicationRepeater: (fields[6] as List?)?.cast<Repeater>(),
      fluxXmlRSSChannel: fields[7] as FluxXmlRSSChannel?,
    );
  }

  @override
  void write(BinaryWriter writer, Publication obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.titlePublication)
      ..writeByte(1)
      ..write(obj.typeLinkPublication)
      ..writeByte(2)
      ..write(obj.tile)
      ..writeByte(3)
      ..write(obj.urlLink)
      ..writeByte(4)
      ..write(obj.displayMode)
      ..writeByte(5)
      ..write(obj.flux)
      ..writeByte(6)
      ..write(obj.publicationRepeater)
      ..writeByte(7)
      ..write(obj.fluxXmlRSSChannel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
