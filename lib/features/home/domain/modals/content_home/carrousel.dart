import 'dart:convert';

import 'package:hive/hive.dart';

import 'repeater.dart';
part 'carrousel.g.dart';

Carrousel carrouselFromJson(String str) => Carrousel.fromJson(json.decode(str));

String carrouselToJson(Carrousel data) => json.encode(data.toJson());

@HiveType(typeId: 12)
class Carrousel extends HiveObject {
  @HiveField(0)
  List<Repeater>? carrouselRepeater;



  Carrousel({
    this.carrouselRepeater,
  });

  factory Carrousel.fromJson(Map<String, dynamic> json) => Carrousel(
        carrouselRepeater: json['carrousel_repeater'] == null ? [] : List<Repeater>.from(json['carrousel_repeater']!.map((x) => Repeater.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'carrousel_repeater': carrouselRepeater == null ? [] : List<dynamic>.from(carrouselRepeater!.map((x) => x.toJson())),
      };

  Carrousel copyWith({
    List<Repeater>? carrouselRepeater,
    int? order,
    bool? hidden,
  }) =>
      Carrousel(
        carrouselRepeater: carrouselRepeater ?? this.carrouselRepeater,
      );
}
