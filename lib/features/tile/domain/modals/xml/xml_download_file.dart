import 'package:xml/xml.dart';

class DownloadFile {
  final String icon;
  final String title;
  final String type;
  final String size;
  final String link;

  DownloadFile({
    required this.icon,
    required this.title,
    required this.type,
    required this.size,
    required this.link,
  });

  factory DownloadFile.fromXml(XmlElement xmlElement) => DownloadFile(
        icon: xmlElement.getElement('icon')?.innerText ?? '',
        title: xmlElement.getElement('title')?.innerText ?? '',
        type: xmlElement.getElement('type')?.innerText ?? '',
        size: xmlElement.getElement('size')?.innerText ?? '',
        link: xmlElement.getElement('link')?.innerText ?? '',
      );

  factory DownloadFile.fromJson(Map<String, dynamic> json) => DownloadFile(
        icon: json['icon'],
        title: json['title'],
        type: json['type'],
        size: json['size'],
        link: json['link'],
      );

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'type': type,
        'size': size,
        'link': link,
      };
}
