import 'dart:convert';

import 'package:hive/hive.dart';

part 'tile_content.g.dart';

List<TileContent> tileContentFromJson(String str) => List<TileContent>.from(json.decode(str).map((x) => TileContent.fromJson(x)));

String tileContentToJson(List<TileContent> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 26)
class TileContent extends HiveObject {
  @HiveField(0)
  String? type;

  @HiveField(1)
  String? slug;

  @HiveField(2)
  String? id;

  @HiveField(3)
  String? idProject;

  @HiveField(4)
  TileContentResults? results;



  TileContent({
    this.type,
    this.slug,
    this.id,
    this.idProject,
    this.results,
  });

  factory TileContent.fromJson(Map<String, dynamic> json) => TileContent(
    type: json['type']?.toString(),
    slug: json['slug']?.toString(),
    id: json['id']?.toString(),
    idProject: json['id_project']?.toString(),
    results: json['results'] == null ? null : TileContentResults.fromJson(json['results']),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'slug': slug,
    'id': id,
    'id_project': idProject,
    'results': results?.toJson(),
  };

  TileContent copyWith({
    String? type,
    String? slug,
    String? id,
    String? idProject,
    TileContentResults? results,
    String? localPath,
  }) =>
      TileContent(
        type: type ?? this.type,
        slug: slug ?? this.slug,
        id: id ?? this.id,
        idProject: idProject ?? this.idProject,
        results: results ?? this.results,
      );

  @override
  String toString() => 'TileContent(id: $id, type: $type)';
}

@HiveType(typeId: 27)
class TileContentResults extends HiveObject {
  @HiveField(0)
  String? titleTile;

  @HiveField(1)
  String? descTile;

  @HiveField(2)
  String? imgTile;

  @HiveField(3)
  String? contentTile;

  @HiveField(4)
  bool? publishTile;

  @HiveField(5)
  String? localPath;

  TileContentResults({
    this.titleTile,
    this.descTile,
    this.imgTile,
    this.contentTile,
    this.publishTile,
    this.localPath,
  });

  factory TileContentResults.fromJson(Map<String, dynamic> json) => TileContentResults(
    titleTile: json['title_tile']?.toString(),
    descTile: json['desc_tile']?.toString(),
    imgTile: json['img_tile']?.toString(),
    contentTile: json['content_tile']?.toString(),
    publishTile: _parseBool(json['publish_tile']),
    localPath: json['localPath'],
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
    'desc_tile': descTile,
    'img_tile': imgTile,
    'content_tile': contentTile,
    'publish_tile': publishTile,
    'localPath': localPath,
  };

  TileContentResults copyWith({
    String? titleTile,
    String? descTile,
    String? imgTile,
    String? contentTile,
    bool? publishTile,
    String? localPath,
  }) =>
      TileContentResults(
        titleTile: titleTile ?? this.titleTile,
        descTile: descTile ?? this.descTile,
        imgTile: imgTile ?? this.imgTile,
        contentTile: contentTile ?? this.contentTile,
        publishTile: publishTile ?? this.publishTile,
        localPath: localPath ?? this.localPath,
      );

  @override
  String toString() => 'TileContentResults(titleTile: $titleTile)';
}