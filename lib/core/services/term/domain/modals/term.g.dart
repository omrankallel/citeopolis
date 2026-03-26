// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TermAdapter extends TypeAdapter<Term> {
  @override
  final int typeId = 20;

  @override
  Term read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Term(
      termId: fields[0] as int?,
      name: fields[1] as String?,
      slug: fields[2] as String?,
      termGroup: fields[3] as int?,
      termTaxonomyId: fields[4] as int?,
      taxonomy: fields[5] as String?,
      description: fields[6] as String?,
      parent: fields[7] as int?,
      count: fields[8] as int?,
      filter: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Term obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.termId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.termGroup)
      ..writeByte(4)
      ..write(obj.termTaxonomyId)
      ..writeByte(5)
      ..write(obj.taxonomy)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.parent)
      ..writeByte(8)
      ..write(obj.count)
      ..writeByte(9)
      ..write(obj.filter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
