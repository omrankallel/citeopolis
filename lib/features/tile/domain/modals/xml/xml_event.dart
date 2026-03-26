import 'package:xml/xml.dart';

import 'xml_location.dart';

class Event {
  final String title;
  final String category;
  final String summary;
  final String pubDate;
  final String updateDate;
  final String eventStartDate;
  final String eventEndDate;
  final String eventStartTime;
  final String eventEndTime;
  final String mainImage;
  final String imageCaption;
  final String content;
  final Location location;

  Event({
    required this.title,
    required this.category,
    required this.summary,
    required this.pubDate,
    required this.updateDate,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.mainImage,
    required this.imageCaption,
    required this.content,
    required this.location,
  });

  factory Event.fromXml(XmlElement xmlElement) {
    final locationElement = xmlElement.getElement('location');

    return Event(
      title: xmlElement.getElement('title')?.innerText ?? '',
      category: xmlElement.getElement('category')?.innerText ?? '',
      summary: xmlElement.getElement('summary')?.innerText ?? '',
      pubDate: xmlElement.getElement('pubDate')?.innerText ?? '',
      updateDate: xmlElement.getElement('updateDate')?.innerText ?? '',
      eventStartDate: xmlElement.getElement('eventStartDate')?.innerText ?? '',
      eventEndDate: xmlElement.getElement('eventEndDate')?.innerText ?? '',
      eventStartTime: xmlElement.getElement('eventStartTime')?.innerText ?? '',
      eventEndTime: xmlElement.getElement('eventEndTime')?.innerText ?? '',
      mainImage: xmlElement.getElement('mainImage')?.innerText ?? '',
      imageCaption: xmlElement.getElement('imageCaption')?.innerText ?? '',
      content: xmlElement.getElement('content')?.innerXml ?? '',
      location: locationElement != null
          ? Location.fromXml(locationElement)
          : Location(
        title: '',
        address: '',
        postalCode: '',
        city: '',
        latitude: 0.0,
        longitude: 0.0,
      ),
    );
  }
  factory Event.fromJson(Map<String, dynamic> json) => Event(
        title: json['title'],
        category: json['category'],
        summary: json['summary'],
        pubDate: json['pubDate'],
        updateDate: json['updateDate'],
        eventStartDate: json['eventStartDate'],
        eventEndDate: json['eventEndDate'],
        eventStartTime: json['eventStartTime'],
        eventEndTime: json['eventEndTime'],
        mainImage: json['mainImage'],
        imageCaption: json['imageCaption'],
        content: json['content'],
        location: Location.fromJson(json['location']),
      );
}