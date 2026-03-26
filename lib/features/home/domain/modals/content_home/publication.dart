import 'dart:convert';

import 'package:hive/hive.dart';

import 'flux.dart';
import 'flux_xml_rss_channel.dart';
import 'repeater.dart';

part 'publication.g.dart';

Publication publicationFromJson(String str) => Publication.fromJson(json.decode(str));

String publicationToJson(Publication data) => json.encode(data.toJson());

@HiveType(typeId: 10)
class Publication extends HiveObject {
  @HiveField(0)
  String? titlePublication;

  @HiveField(1)
  String? typeLinkPublication;

  @HiveField(2)
  String? tile;

  @HiveField(3)
  String? urlLink;

  @HiveField(4)
  String? displayMode;

  @HiveField(5)
  Flux? flux;

  @HiveField(6)
  List<Repeater>? publicationRepeater;

  @HiveField(7)
  FluxXmlRSSChannel? fluxXmlRSSChannel;

  Publication({
    this.titlePublication,
    this.typeLinkPublication,
    this.tile,
    this.urlLink,
    this.displayMode,
    this.flux,
    this.publicationRepeater,
    this.fluxXmlRSSChannel,
  });

  factory Publication.fromJson(Map<String, dynamic> json) => Publication(
        titlePublication: json['title_publcation'],
        typeLinkPublication: json['type_link_publication'],
        tile: json['tile'],
        urlLink: json['url_link'],
        displayMode: json['display_mode'],
        flux: json['flux'] == null ? null : Flux.fromJson(json['flux']),
        publicationRepeater: json['publcation_repeater'] == null ? [] : List<Repeater>.from(json['publcation_repeater']!.map((x) => Repeater.fromJson(x))),
        fluxXmlRSSChannel: json['fluxXmlRSSChannel'],
      );

  Map<String, dynamic> toJson() => {
        'title_publcation': titlePublication,
        'type_link_publication': typeLinkPublication,
        'tile': tile,
        'url_link': urlLink,
        'display_mode': displayMode,
        'flux': flux?.toJson(),
        'publcation_repeater': publicationRepeater == null ? [] : List<dynamic>.from(publicationRepeater!.map((x) => x.toJson())),
        'fluxXmlRSSChannel': fluxXmlRSSChannel,
      };

  Publication copyWith({
    String? titlePublication,
    String? typeLinkPublication,
    String? tile,
    String? urlLink,
    String? displayMode,
    Flux? flux,
    List<Repeater>? publicationRepeater,
    FluxXmlRSSChannel? fluxXmlRSSChannel,
  }) =>
      Publication(
        titlePublication: titlePublication ?? this.titlePublication,
        typeLinkPublication: typeLinkPublication ?? this.typeLinkPublication,
        tile: tile ?? this.tile,
        urlLink: urlLink ?? this.urlLink,
        displayMode: displayMode ?? this.displayMode,
        flux: flux ?? this.flux,
        publicationRepeater: publicationRepeater ?? this.publicationRepeater,
        fluxXmlRSSChannel: fluxXmlRSSChannel ?? this.fluxXmlRSSChannel,
      );
}
