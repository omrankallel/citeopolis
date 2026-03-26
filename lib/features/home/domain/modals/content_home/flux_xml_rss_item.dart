import 'package:hive/hive.dart';
import 'package:xml/xml.dart';

part 'flux_xml_rss_item.g.dart';

@HiveType(typeId: 35)
class FluxXmlRSSItem extends HiveObject {
  @HiveField(0)
  String? title;
  @HiveField(1)
  String? category;
  @HiveField(2)
  String? mainImage;
  @HiveField(3)
  String? eventStartDate;
  @HiveField(4)
  String? eventEndDate;
  @HiveField(5)
  String? link;
  @HiveField(6)
  String? description;
  @HiveField(7)
  String? pubDate;
  @HiveField(8)
  String? guid;

  @HiveField(9)
  String? localPath;

  FluxXmlRSSItem({
    this.title,
    this.category,
    this.mainImage,
    this.eventStartDate,
    this.eventEndDate,
    this.link,
    this.description,
    this.pubDate,
    this.guid,
    this.localPath,
  });

  factory FluxXmlRSSItem.fromXml(XmlElement xmlElement) => FluxXmlRSSItem(
        title: xmlElement.getElement('title')?.innerText ?? '',
        category: xmlElement.getElement('category')?.innerText ?? '',
        mainImage: xmlElement.getElement('mainImage')?.innerText ?? '',
        eventStartDate: xmlElement.getElement('eventStartDate')?.innerText ?? '',
        eventEndDate: xmlElement.getElement('eventEndDate')?.innerText ?? '',
        link: xmlElement.getElement('link')?.innerText ?? '',
        description: xmlElement.getElement('description')?.innerText ?? '',
        pubDate: xmlElement.getElement('pubDate')?.innerText ?? '',
        guid: xmlElement.getElement('guid')?.innerText ?? '',
      );

  factory FluxXmlRSSItem.fromJson(Map<String, dynamic> json) =>
      FluxXmlRSSItem(
        title:json['title'],
        category: json['category'],
        mainImage: json['mainImage'],
        eventStartDate: json['eventStartDate'],
        eventEndDate: json['eventEndDate'],
        link: json['link'],
        description: json['description'],
        pubDate: json['pubDate'],
        guid: json['guid'],
      );


  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'mainImage': mainImage,
        'eventStartDate': eventStartDate,
        'eventEndDate': eventEndDate,
        'link': link,
        'description': description,
        'pubDate': pubDate,
        'guid': guid,
        'localPath': localPath,
      };

  FluxXmlRSSItem copyWith({
    String? title,
    String? category,
    String? mainImage,
    String? eventStartDate,
    String? eventEndDate,
    String? link,
    String? description,
    String? pubDate,
    String? guid,
    String? localPath,
  }) =>
      FluxXmlRSSItem(
        title: title ?? this.title,
        category: category ?? this.category,
        mainImage: mainImage ?? this.mainImage,
        eventStartDate: eventStartDate ?? this.eventStartDate,
        eventEndDate: eventEndDate ?? this.eventEndDate,
        link: link ?? this.link,
        description: description ?? this.description,
        pubDate: pubDate ?? this.pubDate,
        guid: guid ?? this.guid,
        localPath: localPath ?? this.localPath,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FluxXmlRSSItem && other.title == title && other.category == category && other.mainImage == mainImage && other.eventStartDate == eventStartDate && other.eventEndDate == eventEndDate && other.link == link && other.description == description && other.pubDate == pubDate && other.guid == guid;
  }

  @override
  int get hashCode => Object.hash(
        title,
        category,
        mainImage,
        eventStartDate,
        eventEndDate,
        link,
        description,
        pubDate,
        guid,
      );
}
