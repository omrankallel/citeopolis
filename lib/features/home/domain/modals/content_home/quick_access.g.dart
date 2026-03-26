// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_access.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuickAccessAdapter extends TypeAdapter<QuickAccess> {
  @override
  final int typeId = 5;

  @override
  QuickAccess read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuickAccess(
      rows: (fields[0] as List?)?.cast<Row>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuickAccess obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.rows);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickAccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
