import 'dart:convert';

import 'package:hive/hive.dart';
part 'repeater.g.dart';
List<Repeater> repeaterFromJson(String str) => List<Repeater>.from(json.decode(str).map((x) => Repeater.fromJson(x)));

String repeaterToJson(List<Repeater> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
const Object _unset = Object();

@HiveType(typeId: 9)
class Repeater extends HiveObject {
  @HiveField(0)
  String? repTitle;

  @HiveField(1)
  String? repThematic;

  @HiveField(2)
  String? repPictoImg;

  @HiveField(3)
  String? localPath;

  @HiveField(4)
  String? repStartDate;

  @HiveField(5)
  String? repEndDate;

  @HiveField(6)
  String? repTypeLink;

  @HiveField(7)
  String? repTile;

  @HiveField(8)
  String? repUrl;

  Repeater({
    this.repTitle,
    this.repThematic,
    this.repPictoImg,
    this.localPath,
    this.repStartDate,
    this.repEndDate,
    this.repTypeLink,
    this.repTile,
    this.repUrl,
  });

  factory Repeater.fromJson(Map<String, dynamic> json) => Repeater(
        repTitle: json['rep_title'],
        repThematic: json['rep_thematic'],
        repPictoImg: json['rep_picto_img'],
        localPath: json['localPath'],
        repStartDate: json['rep_start_date'],
        repEndDate: json['rep_end_date'],
        repTypeLink: json['rep_type_link'],
        repTile: json['rep_tile'],
        repUrl: json['rep_url'],
      );

  Map<String, dynamic> toJson() => {
        'rep_title': repTitle,
        'rep_thematic': repThematic,
        'rep_picto_img': repPictoImg,
        'localPath': localPath,
        'rep_start_date': repStartDate,
        'rep_end_date': repEndDate,
        'rep_type_link': repTypeLink,
        'rep_tile': repTile,
        'rep_url': repUrl,
      };

  Repeater copyWith({
    String? repTitle,
    String? repThematic,
    Object? repPictoImg = _unset,
    String? localPath,
    String? repStartDate,
    String? repEndDate,
    String? repTypeLink,
    String? repTile,
    String? repUrl,
  }) =>
      Repeater(
        repTitle: repTitle ?? this.repTitle,
        repThematic: repThematic ?? this.repThematic,
        repPictoImg: repPictoImg == _unset ? this.repPictoImg : (repPictoImg as String?),
        localPath: localPath ?? this.localPath,
        repStartDate: repStartDate ?? this.repStartDate,
        repEndDate: repEndDate ?? this.repEndDate,
        repTypeLink: repTypeLink ?? this.repTypeLink,
        repTile: repTile ?? this.repTile,
        repUrl: repUrl ?? this.repUrl,
      );
}
