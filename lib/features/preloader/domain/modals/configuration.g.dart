// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigurationAdapter extends TypeAdapter<Configuration> {
  @override
  final int typeId = 3;

  @override
  Configuration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Configuration(
      positionTitle: fields[0] as String?,
      titleApp: fields[1] as String?,
      backgroundApp: fields[2] as ImageApp?,
      logoApp: fields[3] as ImageApp?,
      leadApp: fields[4] as String?,
      positionLead: fields[5] as String?,
      partnerRepeater: (fields[6] as List?)?.cast<ImageApp>(),
      mailBug: fields[7] as String?,
      mailContactCommunity: fields[8] as String?,
      urlLegalPage: fields[9] as String?,
      urlProtectionPage: fields[10] as String?,
      urlFacebook: fields[11] as String?,
      urlTwitter: fields[12] as String?,
      urlLinkedin: fields[13] as String?,
      urlYoutube: fields[14] as String?,
      urlInstagram: fields[15] as String?,
      adress: fields[16] as String?,
      zipCode: fields[17] as String?,
      city: fields[18] as String?,
      website: fields[19] as String?,
      phone: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Configuration obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.positionTitle)
      ..writeByte(1)
      ..write(obj.titleApp)
      ..writeByte(2)
      ..write(obj.backgroundApp)
      ..writeByte(3)
      ..write(obj.logoApp)
      ..writeByte(4)
      ..write(obj.leadApp)
      ..writeByte(5)
      ..write(obj.positionLead)
      ..writeByte(6)
      ..write(obj.partnerRepeater)
      ..writeByte(7)
      ..write(obj.mailBug)
      ..writeByte(8)
      ..write(obj.mailContactCommunity)
      ..writeByte(9)
      ..write(obj.urlLegalPage)
      ..writeByte(10)
      ..write(obj.urlProtectionPage)
      ..writeByte(11)
      ..write(obj.urlFacebook)
      ..writeByte(12)
      ..write(obj.urlTwitter)
      ..writeByte(13)
      ..write(obj.urlLinkedin)
      ..writeByte(14)
      ..write(obj.urlYoutube)
      ..writeByte(15)
      ..write(obj.urlInstagram)
      ..writeByte(16)
      ..write(obj.adress)
      ..writeByte(17)
      ..write(obj.zipCode)
      ..writeByte(18)
      ..write(obj.city)
      ..writeByte(19)
      ..write(obj.website)
      ..writeByte(20)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
