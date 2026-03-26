import 'dart:convert';

import 'package:hive/hive.dart';

part 'row.g.dart';

List<Row> rowFromJson(String str) => List<Row>.from(json.decode(str).map((x) => Row.fromJson(x)));

String rowToJson(List<Row> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 6)
class Row extends HiveObject {
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
  String? pictogram;

  @HiveField(9)
  String? localPath;

  @HiveField(10)
  String? pictogramName;

  @HiveField(11)
  String? sizeQuickAccess;

  @HiveField(12)
  String? typeLink;

  @HiveField(13)
  String? urlLink;

  @HiveField(14)
  String? tile;

  Row({
    this.title,
    this.titleColor,
    this.secondaryTitle,
    this.radiusBorder,
    this.edgeBorder,
    this.borderColor,
    this.colorBackground,
    this.automaticPictogram,
    this.pictogram,
    this.localPath,
    this.pictogramName,
    this.sizeQuickAccess,
    this.typeLink,
    this.urlLink,
    this.tile,
  });

  factory Row.fromJson(Map<String, dynamic> json) => Row(
        title: json['title'],
        titleColor: json['title_color'],
        secondaryTitle: json['secondary_title'],
        radiusBorder: json['radius_border'],
        edgeBorder: json['edge_border'],
        borderColor: json['border_color'],
        colorBackground: json['color_background'],
        automaticPictogram: json['automatic_pictogram'],
        pictogram: json['pictogram'],
        localPath: json['localPath'],
        sizeQuickAccess: json['size_quick_access'],
        typeLink: json['type_link'],
        urlLink: json['url_link'],
        tile: json['tile'],
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
        'pictogram': pictogram,
        'localPath': localPath,
        'size_quick_access': sizeQuickAccess,
        'type_link': typeLink,
        'url_link': urlLink,
        'tile': tile,
      };

  Row copyWith({
    String? title,
    String? titleColor,
    String? secondaryTitle,
    String? radiusBorder,
    String? edgeBorder,
    String? borderColor,
    String? colorBackground,
    String? automaticPictogram,
    String? pictogram,
    String? localPath,
    String? pictogramName,
    String? sizeQuickAccess,
    String? typeLink,
    String? urlLink,
    String? tile,
  }) =>
      Row(
        title: title ?? this.title,
        titleColor: titleColor ?? this.titleColor,
        secondaryTitle: secondaryTitle ?? this.secondaryTitle,
        radiusBorder: radiusBorder ?? this.radiusBorder,
        edgeBorder: edgeBorder ?? this.edgeBorder,
        borderColor: borderColor ?? this.borderColor,
        colorBackground: colorBackground ?? this.colorBackground,
        automaticPictogram: automaticPictogram ?? this.automaticPictogram,
        pictogram: pictogram ?? this.pictogram,
        localPath: localPath ?? this.localPath,
        pictogramName: pictogramName ?? this.pictogramName,
        sizeQuickAccess: sizeQuickAccess ?? this.sizeQuickAccess,
        typeLink: typeLink ?? this.typeLink,
        urlLink: urlLink ?? this.urlLink,
        tile: tile ?? this.tile,
      );
}
