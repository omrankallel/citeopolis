import 'dart:convert';

import 'package:hive/hive.dart';

import 'flux.dart';
import 'flux_xml_rss_channel.dart';
import 'repeater.dart';

part 'event.g.dart';

Event eventFromJson(String str) => Event.fromJson(json.decode(str));

String eventToJson(Event data) => json.encode(data.toJson());

@HiveType(typeId: 7)
class Event extends HiveObject {
  @HiveField(0)
  String? titleEvent;

  @HiveField(1)
  String? typeLinkEvent;

  @HiveField(2)
  String? tile;

  @HiveField(3)
  String? urlLink;

  @HiveField(4)
  String? displayMode;

  @HiveField(5)
  Flux? flux;

  @HiveField(6)
  List<Repeater>? eventRepeater;

  @HiveField(7)
  FluxXmlRSSChannel? fluxXmlRSSChannel;

  Event({
    this.titleEvent,
    this.typeLinkEvent,
    this.tile,
    this.urlLink,
    this.displayMode,
    this.flux,
    this.eventRepeater,
    this.fluxXmlRSSChannel,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        titleEvent: json['title_event'],
        typeLinkEvent: json['type_link_event'],
        tile: json['tile'],
        urlLink: json['url_link'],
        displayMode: json['display_mode'],
        flux: json['flux'] == null ? null : Flux.fromJson(json['flux']),
        eventRepeater: json['event_repeater'] == null ? [] : List<Repeater>.from(json['event_repeater']!.map((x) => Repeater.fromJson(x))),
        fluxXmlRSSChannel: json['fluxXmlRSSChannel'],
      );

  Map<String, dynamic> toJson() => {
        'title_event': titleEvent,
        'type_link_event': typeLinkEvent,
        'tile': tile,
        'url_link': urlLink,
        'display_mode': displayMode,
        'flux': flux?.toJson(),
        'event_repeater': eventRepeater == null ? [] : List<dynamic>.from(eventRepeater!.map((x) => x.toJson())),
        'fluxXmlRSSChannel': fluxXmlRSSChannel,
      };

  Event copyWith({
    String? titleEvent,
    String? typeLinkEvent,
    String? tile,
    String? urlLink,
    String? displayMode,
    Flux? flux,
    List<Repeater>? eventRepeater,
    FluxXmlRSSChannel? fluxXmlRSSChannel,
  }) =>
      Event(
        titleEvent: titleEvent ?? this.titleEvent,
        typeLinkEvent: typeLinkEvent ?? this.typeLinkEvent,
        tile: tile ?? this.tile,
        urlLink: urlLink ?? this.urlLink,
        displayMode: displayMode ?? this.displayMode,
        flux: flux ?? this.flux,
        eventRepeater: eventRepeater ?? this.eventRepeater,
        fluxXmlRSSChannel: fluxXmlRSSChannel ?? this.fluxXmlRSSChannel,
      );
}
