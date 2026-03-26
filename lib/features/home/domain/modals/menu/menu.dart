import 'dart:convert';

import 'package:hive/hive.dart';

part 'menu.g.dart';

List<Menu> menuFromJson(String str) => List<Menu>.from(json.decode(str).map((x) => Menu.fromJson(x)));

String menuToJson(List<Menu> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 14)
class Menu extends HiveObject {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? typeLinkMenu;
  @HiveField(3)
  String? tile;
  @HiveField(4)
  String? urlLink;
  @HiveField(5)
  bool? publicMenu;

  Menu({
    this.id,
    this.title,
    this.typeLinkMenu,
    this.tile,
    this.urlLink,
    this.publicMenu,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json['ID'],
        title: json['title'],
        typeLinkMenu: json['type_link_menu'],
        tile: json['tile'],
        urlLink: json['url_link'],
        publicMenu: json['public_menu'],
      );

  Map<String, dynamic> toJson() => {
        'ID': id,
        'title': title,
        'type_link_menu': typeLinkMenu,
        'tile': tile,
        'url_link': urlLink,
        'public_menu': publicMenu,
      };

  Menu copyWith({
    int? id,
    String? title,
    String? typeLinkMenu,
    String? tile,
    String? urlLink,
    bool? publicMenu,
  }) =>
      Menu(
        id: id ?? this.id,
        title: title ?? this.title,
        typeLinkMenu: typeLinkMenu ?? this.typeLinkMenu,
        tile: tile ?? this.tile,
        urlLink: urlLink ?? this.urlLink,
        publicMenu: publicMenu ?? this.publicMenu,
      );
}
