// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_page.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildPageAdapter extends TypeAdapter<BuildPage> {
  @override
  final int typeId = 4;

  @override
  BuildPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildPage(
      sections: (fields[0] as List?)?.cast<Section>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildPage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.sections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
