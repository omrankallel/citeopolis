// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationAdapter extends TypeAdapter<Notification> {
  @override
  final int typeId = 15;

  @override
  Notification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notification(
      id: fields[0] as int?,
      title: fields[1] as String?,
      body: fields[2] as String?,
      typeLink: fields[3] as String?,
      idTile: fields[4] as String?,
      urlLink: fields[5] as String?,
      displayStartDateNotif: fields[6] as String?,
      displayEndDateNotif: fields[7] as String?,
      publishNotif: fields[8] as bool?,
      status: fields[9] as String?,
      thematic: (fields[10] as List?)?.cast<Thematic>(),
      image: fields[11] as String?,
      localPath: fields[12] as String?,
      isRead: fields[13] as bool,
      readAt: fields[14] as DateTime?,
      isDeleted: fields[15] as bool,
      deletedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Notification obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.typeLink)
      ..writeByte(4)
      ..write(obj.idTile)
      ..writeByte(5)
      ..write(obj.urlLink)
      ..writeByte(6)
      ..write(obj.displayStartDateNotif)
      ..writeByte(7)
      ..write(obj.displayEndDateNotif)
      ..writeByte(8)
      ..write(obj.publishNotif)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.thematic)
      ..writeByte(11)
      ..write(obj.image)
      ..writeByte(12)
      ..write(obj.localPath)
      ..writeByte(13)
      ..write(obj.isRead)
      ..writeByte(14)
      ..write(obj.readAt)
      ..writeByte(15)
      ..write(obj.isDeleted)
      ..writeByte(16)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
