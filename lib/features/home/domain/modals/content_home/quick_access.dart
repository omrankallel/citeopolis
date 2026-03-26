import 'dart:convert';

import 'package:hive/hive.dart';

import 'row.dart';
part 'quick_access.g.dart';

QuickAccess quickAccessFromJson(String str) => QuickAccess.fromJson(json.decode(str));

String quickAccessToJson(QuickAccess data) => json.encode(data.toJson());

@HiveType(typeId: 5)
class QuickAccess extends HiveObject {
  @HiveField(0)
  List<Row>? rows;



  QuickAccess({
    this.rows,
  });

  factory QuickAccess.fromJson(Map<String, dynamic> json) => QuickAccess(
        rows: json['rows'] == null ? [] : List<Row>.from(json['rows']!.map((x) => Row.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'rows': rows == null ? [] : List<dynamic>.from(rows!.map((x) => x.toJson())),
      };

  QuickAccess copyWith({
    List<Row>? rows,
    int? order,
    bool? hidden,
  }) =>
      QuickAccess(
        rows: rows ?? this.rows,
      );
}
