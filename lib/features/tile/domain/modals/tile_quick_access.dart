import 'dart:convert';

import 'package:hive/hive.dart';

import 'pictogram.dart';

part 'tile_quick_access.g.dart';

List<TileQuickAccess> tileQuickAccessFromJson(String str) => List<TileQuickAccess>.from(json.decode(str).map((x) => TileQuickAccess.fromJson(x)));

String tileQuickAccessToJson(List<TileQuickAccess> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 23)
class TileQuickAccess extends HiveObject {
  @HiveField(0)
  String? type;

  @HiveField(1)
  String? slug;

  @HiveField(2)
  String? id;

  @HiveField(3)
  String? idProject;

  @HiveField(4)
  TileQuickAccessResults? results;

  TileQuickAccess({
    this.type,
    this.slug,
    this.id,
    this.idProject,
    this.results,
  });

  factory TileQuickAccess.fromJson(Map<String, dynamic> json) => TileQuickAccess(
        type: json['type']?.toString(),
        slug: json['slug']?.toString(),
        id: json['id']?.toString(),
        idProject: json['id_project']?.toString(),
        results: json['results'] == null ? null : TileQuickAccessResults.fromJson(json['results']),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'slug': slug,
        'id': id,
        'id_project': idProject,
        'results': results?.toJson(),
      };

  TileQuickAccess copyWith({
    String? type,
    String? slug,
    String? id,
    String? idProject,
    TileQuickAccessResults? results,
  }) =>
      TileQuickAccess(
        type: type ?? this.type,
        slug: slug ?? this.slug,
        id: id ?? this.id,
        idProject: idProject ?? this.idProject,
        results: results ?? this.results,
      );

  @override
  String toString() => 'TileQuickAccess(id: $id, type: $type)';
}

@HiveType(typeId: 24)
class TileQuickAccessResults extends HiveObject {
  @HiveField(0)
  List<QuickAccessData>? data;

  TileQuickAccessResults({
    this.data,
  });

  factory TileQuickAccessResults.fromJson(Map<String, dynamic> json) => TileQuickAccessResults(
        data: json['data'] == null ? [] : List<QuickAccessData>.from(json['data'].map((x) => QuickAccessData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'data': data?.map((x) => x.toJson()).toList() ?? [],
      };

  TileQuickAccessResults copyWith({
    List<QuickAccessData>? data,
  }) =>
      TileQuickAccessResults(
        data: data ?? this.data,
      );

  @override
  String toString() => 'TileQuickAccessResults(data: ${data?.length} items)';
}

@HiveType(typeId: 25)
class QuickAccessData extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? titleColor;

  @HiveField(2)
  String? secondaryTitle;

  @HiveField(3)
  String? radiusBorder;

  @HiveField(4)
  String? edgeBorder;

  @HiveField(5)
  String? borderColor;

  @HiveField(6)
  String? colorBackground;

  @HiveField(7)
  String? automaticPictogram;

  @HiveField(8)
  Pictogram? pictogram;

  @HiveField(9)
  String? sizeQuickAccess;

  @HiveField(10)
  String? typeLink;

  @HiveField(11)
  String? urlLink;

  @HiveField(12)
  String? tile;

  QuickAccessData({
    this.title,
    this.titleColor,
    this.secondaryTitle,
    this.radiusBorder,
    this.edgeBorder,
    this.borderColor,
    this.colorBackground,
    this.automaticPictogram,
    this.pictogram,
    this.sizeQuickAccess,
    this.typeLink,
    this.urlLink,
    this.tile,
  });

  factory QuickAccessData.fromJson(Map<String, dynamic> json) => QuickAccessData(
        title: json['title']?.toString(),
        titleColor: json['title_color']?.toString(),
        secondaryTitle: json['secondary_title']?.toString(),
        radiusBorder: json['radius_border']?.toString(),
        edgeBorder: json['edge_border']?.toString(),
        borderColor: json['border_color']?.toString(),
        colorBackground: json['color_background']?.toString(),
        automaticPictogram: json['automatic_pictogram']?.toString(),
        pictogram: json['pictogram']?.toString() == 'false' || json['pictogram']?.toString() == 'true' ? null : Pictogram.fromJson(json['pictogram']),
        sizeQuickAccess: json['size_quick_access']?.toString(),
        typeLink: json['type_link']?.toString(),
        urlLink: json['url_link']?.toString(),
        tile: json['tile']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'title_color': titleColor,
        'secondary_title': secondaryTitle,
        'radius_border': radiusBorder,
        'edge_border': edgeBorder,
        'border_color': borderColor,
        'color_background': colorBackground,
        'automatic_pictogram': automaticPictogram,
        'pictogram': pictogram!.toJson(),
        'size_quick_access': sizeQuickAccess,
        'type_link': typeLink,
        'url_link': urlLink,
        'tile': tile,
      };

  QuickAccessData copyWith({
    String? title,
    String? titleColor,
    String? secondaryTitle,
    String? radiusBorder,
    String? edgeBorder,
    String? borderColor,
    String? colorBackground,
    String? automaticPictogram,
    Pictogram? pictogram,
    String? sizeQuickAccess,
    String? typeLink,
    String? urlLink,
    String? tile,
  }) =>
      QuickAccessData(
        title: title ?? this.title,
        titleColor: titleColor ?? this.titleColor,
        secondaryTitle: secondaryTitle ?? this.secondaryTitle,
        radiusBorder: radiusBorder ?? this.radiusBorder,
        edgeBorder: edgeBorder ?? this.edgeBorder,
        borderColor: borderColor ?? this.borderColor,
        colorBackground: colorBackground ?? this.colorBackground,
        automaticPictogram: automaticPictogram ?? this.automaticPictogram,
        pictogram: pictogram ?? this.pictogram,
        sizeQuickAccess: sizeQuickAccess ?? this.sizeQuickAccess,
        typeLink: typeLink ?? this.typeLink,
        urlLink: urlLink ?? this.urlLink,
        tile: tile ?? this.tile,
      );

  @override
  String toString() => 'QuickAccessData(title: $title)';
}
