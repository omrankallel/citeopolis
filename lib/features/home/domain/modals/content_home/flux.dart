import 'dart:convert';

import 'package:hive/hive.dart';
part 'flux.g.dart';

Flux fluxFromJson(String str) => Flux.fromJson(json.decode(str));

String fluxToJson(Flux data) => json.encode(data.toJson());

@HiveType(typeId: 8)
class Flux extends HiveObject {
  @HiveField(0)
  String? numberElement;

  @HiveField(1)
  String? fluxLink;

  Flux({
    this.numberElement,
    this.fluxLink,
  });

  factory Flux.fromJson(Map<String, dynamic> json) => Flux(
        numberElement: json['number_element'],
        fluxLink: json['flux_link'],
      );

  Map<String, dynamic> toJson() => {
        'number_element': numberElement,
        'flux_link': fluxLink,
      };

  Flux copyWith({
    String? numberElement,
    String? fluxLink,
  }) =>
      Flux(
        numberElement: numberElement ?? this.numberElement,
        fluxLink: fluxLink ?? this.fluxLink,
      );
}
