import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../../../core/services/image_app/modals/image_app.dart';

part 'tab_bar.g.dart';

List<TabBar> tabBarFromJson(String str) => List<TabBar>.from(json.decode(str).map((x) => TabBar.fromJson(x)));

String tabBarToJson(List<TabBar> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 13)
class TabBar extends HiveObject {
  @HiveField(0)
  String? titleTabBar;

  @HiveField(1)
  ImageApp? pictoImg;

  @HiveField(2)
  String? typeLinkTabBar;

  @HiveField(3)
  String? tile;

  @HiveField(4)
  String? urlLink;

  @HiveField(5)
  bool? publicTabBar;

  @HiveField(6)
  String? icon;

  TabBar({
    this.titleTabBar,
    this.pictoImg,
    this.typeLinkTabBar,
    this.tile,
    this.urlLink,
    this.publicTabBar,
    this.icon,
  });

  factory TabBar.fromJson(Map<String, dynamic> json) => TabBar(
        titleTabBar: json['title_tab_bar'],
        pictoImg: json['picto_img'] == null ? null : ImageApp.fromJson(json['picto_img']),
        typeLinkTabBar: json['type_link_tab_bar'],
        tile: json['tile'],
        urlLink: json['url_link'],
        publicTabBar: json['public_tab_bar'],
        icon: json['icon'],
      );

  Map<String, dynamic> toJson() => {
        'title_tab_bar': titleTabBar,
        'picto_img': pictoImg?.toJson(),
        'type_link_tab_bar': typeLinkTabBar,
        'tile': tile,
        'url_link': urlLink,
        'public_tab_bar': publicTabBar,
        'icon': icon,
      };

  TabBar copyWith({
    String? titleTabBar,
    ImageApp? pictoImg,
    String? typeLinkTabBar,
    String? tile,
    String? urlLink,
    bool? publicTabBar,
    String? icon,
  }) =>
      TabBar(
        titleTabBar: titleTabBar ?? this.titleTabBar,
        pictoImg: pictoImg ?? this.pictoImg,
        typeLinkTabBar: typeLinkTabBar ?? this.typeLinkTabBar,
        tile: tile ?? this.tile,
        urlLink: urlLink ?? this.urlLink,
        publicTabBar: publicTabBar ?? this.publicTabBar,
        icon: icon ?? this.icon,
      );
}
