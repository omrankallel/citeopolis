import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/services/image_app/modals/image_app.dart';

part 'publicity.g.dart';
Publicity publicityFromJson(String str) => Publicity.fromJson(json.decode(str));

String publicityToJson(Publicity data) => json.encode(data.toJson());

@HiveType(typeId: 0)
class Publicity extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? positionTitlePublicity;

  @HiveField(2)
  String? titlePublicity;

  @HiveField(3)
  String? leadPublicity;

  @HiveField(4)
  ImageApp? imgPublicity;

  @HiveField(5)
  bool? showButton;

  @HiveField(6)
  String? buttonText;

  @HiveField(7)
  String? typeLinkPublicity;

  @HiveField(8)
  String? urlLink;

  @HiveField(9)
  String? tile;

  @HiveField(10)
  String? displayStartDatePublicity;

  @HiveField(11)
  String? displayEndDatePublicity;

  @HiveField(12)
  String? displayTimeSeconds;


  Publicity({
    this.id,
    this.positionTitlePublicity,
    this.titlePublicity,
    this.leadPublicity,
    this.imgPublicity,
    this.showButton,
    this.buttonText,
    this.typeLinkPublicity,
    this.urlLink,
    this.tile,
    this.displayStartDatePublicity,
    this.displayEndDatePublicity,
    this.displayTimeSeconds,
  });

  factory Publicity.fromJson(Map<String, dynamic> json) => Publicity(
        id: json['ID'],
        positionTitlePublicity: json['position_title_publicity'],
        titlePublicity: json['title_publicity'],
        leadPublicity: json['lead_publicity'],
        imgPublicity: json['img_publicity'] == null ? null : ImageApp.fromJson(json['img_publicity']),
        showButton: json['show_button'],
        buttonText: json['button_text'],
        typeLinkPublicity: json['type_link_publicity'],
        urlLink: json['url_link'],
        tile: json['tile'],
        displayStartDatePublicity: json['display_start_date_publicity'],
        displayEndDatePublicity: json['display_end_date_publicity'],
        displayTimeSeconds: json['display_time_seconds'],
      );

  Map<String, dynamic> toJson() => {
        'ID': id,
        'position_title_publicity': positionTitlePublicity,
        'title_publicity': titlePublicity,
        'lead_publicity': leadPublicity,
        'img_publicity': imgPublicity?.toJson(),
        'show_button': showButton,
        'button_text': buttonText,
        'type_link_publicity': typeLinkPublicity,
        'url_link': urlLink,
        'tile': tile,
        'display_start_date_publicity': displayStartDatePublicity,
        'display_end_date_publicity': displayEndDatePublicity,
        'display_time_seconds': displayTimeSeconds,
      };

}
