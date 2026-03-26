import 'dart:convert';

import 'package:hive/hive.dart';

part 'tile_url.g.dart';

List<TileUrl> tileUrlFromJson(String str) => List<TileUrl>.from(json.decode(str).map((x) => TileUrl.fromJson(x)));

String tileUrlToJson(List<TileUrl> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 21)
class TileUrl extends HiveObject {
  @HiveField(0)
  String? type;

  @HiveField(1)
  String? slug;

  @HiveField(2)
  String? id;

  @HiveField(3)
  String? idProject;

  @HiveField(4)
  TileUrlResults? results;

  TileUrl({
    this.type,
    this.slug,
    this.id,
    this.idProject,
    this.results,
  });

  factory TileUrl.fromJson(Map<String, dynamic> json) => TileUrl(
    type: json['type']?.toString(),
    slug: json['slug']?.toString(),
    id: json['id']?.toString(),
    idProject: json['id_project']?.toString(),
    results: json['results'] == null ? null : TileUrlResults.fromJson(json['results']),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'slug': slug,
    'id': id,
    'id_project': idProject,
    'results': results?.toJson(),
  };

  TileUrl copyWith({
    String? type,
    String? slug,
    String? id,
    String? idProject,
    TileUrlResults? results,
  }) =>
      TileUrl(
        type: type ?? this.type,
        slug: slug ?? this.slug,
        id: id ?? this.id,
        idProject: idProject ?? this.idProject,
        results: results ?? this.results,
      );

  @override
  String toString() => 'TileUrl(id: $id, type: $type)';
}

@HiveType(typeId: 22)
class TileUrlResults extends HiveObject {
  @HiveField(0)
  String? titleTile;

  @HiveField(1)
  String? typeLink;

  @HiveField(2)
  String? tile;

  @HiveField(3)
  String? urlTile;

  @HiveField(4)
  bool? publishTile;

  TileUrlResults({
    this.titleTile,
    this.typeLink,
    this.tile,
    this.urlTile,
    this.publishTile,
  });

  factory TileUrlResults.fromJson(Map<String, dynamic> json) => TileUrlResults(
    titleTile: json['title_tile']?.toString(),
    typeLink: json['type_link']?.toString(),
    tile: json['tile']?.toString(),
    urlTile: json['url_tile']?.toString(),
    publishTile: _parseBool(json['publish_tile']),
  );

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is int) return value == 1;
    return null;
  }

  Map<String, dynamic> toJson() => {
    'title_tile': titleTile,
    'type_link': typeLink,
    'tile': tile,
    'url_tile': urlTile,
    'publish_tile': publishTile,
  };

  TileUrlResults copyWith({
    String? titleTile,
    String? typeLink,
    String? tile,
    String? urlTile,
    bool? publishTile,
  }) =>
      TileUrlResults(
        titleTile: titleTile ?? this.titleTile,
        typeLink: typeLink ?? this.typeLink,
        tile: tile ?? this.tile,
        urlTile: urlTile ?? this.urlTile,
        publishTile: publishTile ?? this.publishTile,
      );

  @override
  String toString() => 'TileUrlResults(titleTile: $titleTile)';
}