import 'dart:convert';

import 'package:hive/hive.dart';

part 'feed.g.dart';

List<Feed> feedFromJson(String str) => List<Feed>.from(json.decode(str).map((x) => Feed.fromJson(x)));

String feedToJson(List<Feed> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 19)
class Feed extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? balise;

  @HiveField(3)
  List<String>? type;

  @HiveField(4)
  bool? status;

  Feed({
    this.id,
    this.title,
    this.balise,
    this.type,
    this.status,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json['ID'],
        title: json['title'],
        balise: json['balise'],
        type: json['type'] == null ? [] : List<String>.from(json['type'].map((x) => x)),
        status: false,
      );

  Map<String, dynamic> toJson() => {
        'ID': id,
        'title': title,
        'balise': balise,
        'type': type == null ? [] : List<dynamic>.from(type!.map((x) => x)),
      };

  Feed copyWith({
    int? id,
    String? title,
    String? balise,
    List<String>? type,
    bool? status,
  }) =>
      Feed(
        id: id ?? this.id,
        title: title ?? this.title,
        balise: balise ?? this.balise,
        type: type ?? this.type,
        status: status ?? this.status,
      );
}
