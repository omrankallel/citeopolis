import 'dart:convert';

import 'package:hive/hive.dart';

import 'type_tile.dart';

part 'tile.g.dart';

List<Tile> tileFromJson(String str) => List<Tile>.from(json.decode(str).map((x) => Tile.fromJson(x)));

String tileToJson(List<Tile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 17)
class Tile extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? projectId;

  @HiveField(3)
  bool? publishTile;

  @HiveField(4)
  TypeTile? type;

  @HiveField(5)
  Map<String, dynamic>? details;

  Tile({
    this.id,
    this.title,
    this.projectId,
    this.publishTile,
    this.type,
    this.details,
  });

  factory Tile.fromJson(Map<String, dynamic> json) =>
      Tile(
        id: json['id'],
        title: json['Title'],
        projectId: json['project_id'],
        publishTile: json['publish_tile'],
        type: json['type'] == null ? TypeTile() : TypeTile.fromJson(json['type']),
        details: json['details'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'Title': title,
        'project_id': projectId,
        'publish_tile': publishTile,
        'type': type!.toJson(),
        'details': details,
      };

  Tile copyWith({
    int? id,
    String? title,
    String? projectId,
    bool? publishTile,
    TypeTile? type,
    Map<String, dynamic>? details,
  }) =>
      Tile(
        id: id ?? this.id,
        title: title ?? this.title,
        projectId: projectId ?? this.projectId,
        publishTile: publishTile ?? this.publishTile,
        type: type ?? this.type,
        details: details ?? this.details,
      );


}
