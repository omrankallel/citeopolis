import 'dart:convert';

import 'package:hive/hive.dart';

part 'tile_xml.g.dart';

List<TileXml> tileXmlFromJson(String str) => List<TileXml>.from(json.decode(str).map((x) => TileXml.fromJson(x)));

String tileXmlToJson(List<TileXml> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 31)
class TileXml extends HiveObject {
  @HiveField(0)
  String? type;

  @HiveField(1)
  String? slug;

  @HiveField(2)
  String? id;

  @HiveField(3)
  String? idProject;

  @HiveField(4)
  TileXmlResults? results;

  TileXml({
    this.type,
    this.slug,
    this.id,
    this.idProject,
    this.results,
  });

  factory TileXml.fromJson(Map<String, dynamic> json) => TileXml(
    type: json['type']?.toString(),
    slug: json['slug']?.toString(),
    id: json['id']?.toString(),
    idProject: json['id_project']?.toString(),
    results: json['results'] == null ? null : TileXmlResults.fromJson(json['results']),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'slug': slug,
    'id': id,
    'id_project': idProject,
    'results': results?.toJson(),
  };

  TileXml copyWith({
    String? type,
    String? slug,
    String? id,
    String? idProject,
    TileXmlResults? results,
  }) =>
      TileXml(
        type: type ?? this.type,
        slug: slug ?? this.slug,
        id: id ?? this.id,
        idProject: idProject ?? this.idProject,
        results: results ?? this.results,
      );

  @override
  String toString() => 'TileXml(id: $id, type: $type)';
}

@HiveType(typeId: 32)
class TileXmlResults extends HiveObject {
  @HiveField(0)
  String? titleTile;

  @HiveField(1)
  String? urlTile;

  @HiveField(2)
  String? numberElement;

  @HiveField(3)
  String? feedThematic;

  @HiveField(4)
  List<TileXmlId>? idsList;

  @HiveField(5)
  List<TileXmlId>? idsSingle;

  @HiveField(6)
  bool? publishTile;

  TileXmlResults({
    this.titleTile,
    this.urlTile,
    this.numberElement,
    this.feedThematic,
    this.idsList,
    this.idsSingle,
    this.publishTile,
  });

  factory TileXmlResults.fromJson(Map<String, dynamic> json) => TileXmlResults(
    titleTile: json['title_tile']?.toString(),
    urlTile: json['url_tile']?.toString(),
    numberElement: json['number_element']?.toString(),
    feedThematic: json['feed_thematic']?.toString(),
    idsList: json['ids_list'] == null
        ? []
        : List<TileXmlId>.from(json['ids_list'].map((x) => TileXmlId.fromJson(x))),
    idsSingle: json['ids_single'] == null
        ? []
        : List<TileXmlId>.from(json['ids_single'].map((x) => TileXmlId.fromJson(x))),
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
    'feed_thematic': feedThematic,
    'ids_list': idsList?.map((x) => x.toJson()).toList() ?? [],
    'ids_single': idsSingle?.map((x) => x.toJson()).toList() ?? [],
    'publish_tile': publishTile,
  };

  TileXmlResults copyWith({
    String? titleTile,
    String? urlTile,
    String? numberElement,
    String? feedThematic,
    List<TileXmlId>? idsList,
    List<TileXmlId>? idsSingle,
    bool? publishTile,
  }) =>
      TileXmlResults(
        titleTile: titleTile ?? this.titleTile,
        urlTile: urlTile ?? this.urlTile,
        numberElement: numberElement ?? this.numberElement,
        feedThematic: feedThematic ?? this.feedThematic,
        idsList: idsList ?? this.idsList,
        idsSingle: idsSingle ?? this.idsSingle,
        publishTile: publishTile ?? this.publishTile,
      );

  @override
  String toString() => 'TileXmlResults(titleTile: $titleTile)';
}

@HiveType(typeId: 33)
class TileXmlId extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? balise;

  @HiveField(3)
  int? status;

  TileXmlId({
    this.id,
    this.title,
    this.balise,
    this.status,
  });

  factory TileXmlId.fromJson(Map<String, dynamic> json) => TileXmlId(
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

  TileXmlId copyWith({
    int? id,
    String? title,
    String? balise,
    int? status,
  }) =>
      TileXmlId(
        id: id ?? this.id,
        title: title ?? this.title,
        balise: balise ?? this.balise,
        status: status ?? this.status,
      );

  @override
  String toString() => 'TileXmlId(id: $id, title: $title)';
}