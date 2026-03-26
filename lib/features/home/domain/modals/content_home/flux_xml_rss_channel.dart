import 'package:hive/hive.dart';
import 'package:xml/xml.dart';

import 'flux_xml_rss_item.dart';

part 'flux_xml_rss_channel.g.dart';

@HiveType(typeId: 34)
class FluxXmlRSSChannel extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  String? link;

  @HiveField(3)
  String? language;

  @HiveField(4)
  String? lastBuildDate;

  @HiveField(5)
  List<FluxXmlRSSItem> items;

  FluxXmlRSSChannel({
    this.title,
    this.description,
    this.link,
    this.language,
    this.lastBuildDate,
    this.items = const [],
  });

  factory FluxXmlRSSChannel.fromXml(XmlElement xmlElement) {
    final itemElements = xmlElement.findElements('item');
    final items = itemElements.map((itemElement) => FluxXmlRSSItem.fromXml(itemElement)).toList();

    return FluxXmlRSSChannel(
      title: xmlElement.getElement('title')?.innerText ?? '',
      description: xmlElement.getElement('description')?.innerText ?? '',
      link: xmlElement.getElement('link')?.innerText ?? '',
      language: xmlElement.getElement('language')?.innerText ?? '',
      lastBuildDate: xmlElement.getElement('lastBuildDate')?.innerText ?? '',
      items: items,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'link': link,
        'language': language,
        'lastBuildDate': lastBuildDate,
        'items': items.map((item) => item.toMap()).toList(),
      };

  FluxXmlRSSChannel copyWith({
    String? title,
    String? description,
    String? link,
    String? language,
    String? lastBuildDate,
    List<FluxXmlRSSItem>? items,
  }) =>
      FluxXmlRSSChannel(
        title: title ?? this.title,
        description: description ?? this.description,
        link: link ?? this.link,
        language: language ?? this.language,
        lastBuildDate: lastBuildDate ?? this.lastBuildDate,
        items: items ?? this.items,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FluxXmlRSSChannel &&
        other.title == title &&
        other.description == description &&
        other.link == link &&
        other.language == language &&
        other.lastBuildDate == lastBuildDate &&
        _listEquals(
          other.items,
          items,
        );
  }

  @override
  int get hashCode => Object.hash(
        title,
        description,
        link,
        language,
        lastBuildDate,
        Object.hashAll(items),
      );

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() => 'FluxXmlRSSChannel{title: $title, description: $description, itemsCount: ${items.length}}';
}
