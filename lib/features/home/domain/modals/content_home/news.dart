import 'dart:convert';

import 'package:hive/hive.dart';

import 'flux.dart';
import 'flux_xml_rss_channel.dart';
import 'repeater.dart';

part 'news.g.dart';

News newsFromJson(String str) => News.fromJson(json.decode(str));

String newsToJson(News data) => json.encode(data.toJson());

@HiveType(typeId: 11)
class News extends HiveObject {
  @HiveField(0)
  String? titleNews;
  @HiveField(1)
  String? typeLinkNews;
  @HiveField(2)
  String? tile;
  @HiveField(3)
  String? urlLink;
  @HiveField(4)
  String? displayMode;
  @HiveField(5)
  Flux? flux;
  @HiveField(6)
  List<Repeater>? newsRepeater;
  @HiveField(7)
  FluxXmlRSSChannel? fluxXmlRSSChannel;

  News({
    this.titleNews,
    this.typeLinkNews,
    this.tile,
    this.urlLink,
    this.displayMode,
    this.flux,
    this.newsRepeater,
    this.fluxXmlRSSChannel,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
        titleNews: json['title_news'],
        typeLinkNews: json['type_link_news'],
        tile: json['tile'],
        urlLink: json['url_link'],
        displayMode: json['display_mode'],
        flux: json['flux'] == null ? null : Flux.fromJson(json['flux']),
        newsRepeater: json['news_repeater'] == null ? [] : List<Repeater>.from(json['news_repeater']!.map((x) => Repeater.fromJson(x))),
        fluxXmlRSSChannel: json['fluxXmlRSSChannel'],
      );

  Map<String, dynamic> toJson() => {
        'title_news': titleNews,
        'type_link_news': typeLinkNews,
        'tile': tile,
        'url_link': urlLink,
        'display_mode': displayMode,
        'flux': flux?.toJson(),
        'news_repeater': newsRepeater == null ? [] : List<dynamic>.from(newsRepeater!.map((x) => x.toJson())),
        'fluxXmlRSSChannel': fluxXmlRSSChannel,
      };

  News copyWith({
    String? titleNews,
    String? typeLinkNews,
    String? tile,
    String? urlLink,
    String? displayMode,
    Flux? flux,
    List<Repeater>? newsRepeater,
    FluxXmlRSSChannel? fluxXmlRSSChannel,
  }) =>
      News(
        titleNews: titleNews ?? this.titleNews,
        typeLinkNews: typeLinkNews ?? this.typeLinkNews,
        tile: tile ?? this.tile,
        urlLink: urlLink ?? this.urlLink,
        displayMode: displayMode ?? this.displayMode,
        flux: flux ?? this.flux,
        newsRepeater: newsRepeater ?? this.newsRepeater,
        fluxXmlRSSChannel: fluxXmlRSSChannel ?? this.fluxXmlRSSChannel,
      );
}
