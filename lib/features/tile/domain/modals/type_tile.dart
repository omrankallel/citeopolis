import 'dart:convert';

import 'package:hive/hive.dart';

part 'type_tile.g.dart';

List<TypeTile> typeFromJson(String str) => List<TypeTile>.from(json.decode(str).map((x) => TypeTile.fromJson(x)));

String typeToJson(List<TypeTile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 18)
class TypeTile extends HiveObject {
  @HiveField(0)
  String? slug;
  @HiveField(1)
  String? name;

  TypeTile({
    this.slug,
    this.name,
  });

  factory TypeTile.fromJson(Map<String, dynamic> json) => TypeTile(
        slug: json['slug'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'name': name,
      };
}
