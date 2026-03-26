import 'dart:convert';

import 'package:hive/hive.dart';

part 'tile_map.g.dart';

List<TileMap> tileMapFromJson(String str) => List<TileMap>.from(json.decode(str).map((x) => TileMap.fromJson(x)));

String tileMapToJson(List<TileMap> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 28)
class TileMap extends HiveObject {
  @HiveField(0)
  String? type;

  @HiveField(1)
  String? slug;

  @HiveField(2)
  String? id;

  @HiveField(3)
  String? idProject;

  @HiveField(4)
  TileMapResults? results;

  TileMap({
    this.type,
    this.slug,
    this.id,
    this.idProject,
    this.results,
  });

  factory TileMap.fromJson(Map<String, dynamic> json) => TileMap(
    type: json['type']?.toString(),
    slug: json['slug']?.toString(),
    id: json['id']?.toString(),
    idProject: json['id_project']?.toString(),
    results: json['results'] == null ? null : TileMapResults.fromJson(json['results']),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'slug': slug,
    'id': id,
    'id_project': idProject,
    'results': results?.toJson(),
  };

  TileMap copyWith({
    String? type,
    String? slug,
    String? id,
    String? idProject,
    TileMapResults? results,
  }) =>
      TileMap(
        type: type ?? this.type,
        slug: slug ?? this.slug,
        id: id ?? this.id,
        idProject: idProject ?? this.idProject,
        results: results ?? this.results,
      );

  @override
  String toString() => 'TileMap(id: $id, type: $type)';
}

@HiveType(typeId: 29)
class TileMapResults extends HiveObject {
  @HiveField(0)
  String? titleTile;

  @HiveField(1)
  String? urlTile;

  @HiveField(2)
  String? numberElement;

  @HiveField(3)
  List<TileMapId>? idsList;

  @HiveField(4)
  List<TileMapId>? idsSingle;

  @HiveField(5)
  bool? publishTile;

  TileMapResults({
    this.titleTile,
    this.urlTile,
    this.numberElement,
    this.idsList,
    this.idsSingle,
    this.publishTile,
  });

  factory TileMapResults.fromJson(Map<String, dynamic> json) => TileMapResults(
    titleTile: json['title_tile']?.toString(),
    urlTile: json['url_tile']?.toString(),
    numberElement: json['number_element']?.toString(),
    idsList: json['ids_list'] == null
        ? []
        : List<TileMapId>.from(json['ids_list'].map((x) => TileMapId.fromJson(x))),
    idsSingle: json['ids_single'] == null
        ? []
        : List<TileMapId>.from(json['ids_single'].map((x) => TileMapId.fromJson(x))),
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
    'url_tile': urlTile,
    'number_element': numberElement,
    'ids_list': idsList?.map((x) => x.toJson()).toList() ?? [],
    'ids_single': idsSingle?.map((x) => x.toJson()).toList() ?? [],
    'publish_tile': publishTile,
  };

  TileMapResults copyWith({
    String? titleTile,
    String? urlTile,
    String? numberElement,
    List<TileMapId>? idsList,
    List<TileMapId>? idsSingle,
    bool? publishTile,
  }) =>
      TileMapResults(
        titleTile: titleTile ?? this.titleTile,
        urlTile: urlTile ?? this.urlTile,
        numberElement: numberElement ?? this.numberElement,
        idsList: idsList ?? this.idsList,
        idsSingle: idsSingle ?? this.idsSingle,
        publishTile: publishTile ?? this.publishTile,
      );

  @override
  String toString() => 'TileMapResults(titleTile: $titleTile)';
}

@HiveType(typeId: 30)
class TileMapId extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? balise;

  @HiveField(3)
  int? status;

  TileMapId({
    this.id,
    this.title,
    this.balise,
    this.status,
  });

  factory TileMapId.fromJson(Map<String, dynamic> json) => TileMapId(
    id: _parseInt(json['ID']),
    title: json['title']?.toString(),
    balise: json['balise']?.toString(),
    status: _parseInt(json['status']),
  );

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'title': title,
    'balise': balise,
    'status': status,
  };

  TileMapId copyWith({
    int? id,
    String? title,
    String? balise,
    int? status,
  }) =>
      TileMapId(
        id: id ?? this.id,
        title: title ?? this.title,
        balise: balise ?? this.balise,
        status: status ?? this.status,
      );

  @override
  String toString() => 'TileMapId(id: $id, title: $title)';
}