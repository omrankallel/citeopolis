import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'carrousel.dart';
import 'event.dart';
import 'news.dart';
import 'publication.dart';
import 'quick_access.dart';

part 'section.g.dart';

const _uuid = Uuid();

@HiveType(typeId: 36)
class Section extends HiveObject {
  final String? id;
  @HiveField(0)
  String? type;
  @HiveField(1)
  int? order;
  @HiveField(2)
  bool? hidden;
  @HiveField(3)
  Carrousel? carrousel;
  @HiveField(4)
  QuickAccess? quickAccess;
  @HiveField(5)
  News? news;
  @HiveField(6)
  Event? event;
  @HiveField(7)
  Publication? publication;

  Section({
    String? id,
    this.type,
    this.order,
    this.hidden,
    this.carrousel,
    this.quickAccess,
    this.news,
    this.event,
    this.publication,
  }) : id = id ?? _uuid.v4();

  Section copyWith({
    String? type,
    int? order,
    bool? hidden,
    Carrousel? carrousel,
    QuickAccess? quickAccess,
    News? news,
    Event? event,
    Publication? publication,
  }) =>
      Section(
        type: type ?? this.type,
        order: order ?? this.order,
        hidden: hidden ?? this.hidden,
        carrousel: carrousel ?? this.carrousel,
        quickAccess: quickAccess ?? this.quickAccess,
        news: news ?? this.news,
        event: event ?? this.event,
        publication: publication ?? this.publication,
      );

  factory Section.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] ?? '';
    final Map<String, dynamic>? data = json['data'];

    Carrousel carrousel = Carrousel();
    QuickAccess quickAccess = QuickAccess();
    News news = News();
    Event event = Event();
    Publication publication = Publication();

    switch (type) {
      case 'carousel':
        if (data != null) {
          carrousel = Carrousel.fromJson(data);
        }
        break;

      case 'quick_access':
        if (data != null) {
          quickAccess = QuickAccess.fromJson(data);
        }
        break;

      case 'news':
        if (data != null) {
          news = News.fromJson(data);
        }
        break;

      case 'event':
        if (data != null) {
          event = Event.fromJson(data);
        }
        break;

      case 'publication':
        if (data != null) {
          publication = Publication.fromJson(data);
        }
        break;
    }

    return Section(
      type: type,
      order: json['order'],
      hidden: json['hidden'],
      carrousel: carrousel,
      quickAccess: quickAccess,
      news: news,
      event: event,
      publication: publication,
    );
  }

  Map<String, dynamic> toJson() {
    dynamic data;

    switch (type) {
      case 'carousel':
        data = carrousel?.toJson();
        break;
      case 'quick_access':
        data = quickAccess?.toJson();
        break;
      case 'news':
        data = news?.toJson();
        break;
      case 'event':
        data = event?.toJson();
        break;
      case 'publication':
        data = publication?.toJson();
        break;
    }

    return {
      'type': type,
      'order': order,
      'hidden': hidden,
      'data': data,
    };
  }

  @override
  String toString() => 'Section{type: $type, order: $order, hidden: $hidden, carrousel: $carrousel, quickAccess: $quickAccess, news: $news, event: $event, publication: $publication}';
}
