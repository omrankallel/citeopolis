// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigAppAdapter extends TypeAdapter<ConfigApp> {
  @override
  final int typeId = 2;

  @override
  ConfigApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigApp(
      id: fields[0] as int?,
      urlApp: fields[1] as String?,
      configuration: fields[2] as Configuration?,
    );
  }

  @override
  void write(BinaryWriter writer, ConfigApp obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.urlApp)
      ..writeByte(2)
      ..write(obj.configuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
