import 'package:xml/xml.dart';

class Article {
  final String title;
  final String category;
  final String summary;
  final String pubDate;
  final String updateDate;
  final String mainImage;
  final String imageCaption;
  final String content;

  Article({
    required this.title,
    required this.category,
    required this.summary,
    required this.pubDate,
    required this.updateDate,
    required this.mainImage,
    required this.imageCaption,
    required this.content,
  });

  factory Article.fromXml(XmlElement xmlElement) => Article(
        title: xmlElement.getElement('title')?.innerText ?? '',
        category: xmlElement.getElement('category')?.innerText ?? '',
        summary: xmlElement.getElement('summary')?.innerText ?? '',
        pubDate: xmlElement.getElement('pubDate')?.innerText ?? '',
        updateDate: xmlElement.getElement('updateDate')?.innerText ?? '',
        mainImage: xmlElement.getElement('mainImage')?.innerText ?? '',
        imageCaption: xmlElement.getElement('imageCaption')?.innerText ?? '',
        content: xmlElement.getElement('content')?.innerXml  ?? '',
      );

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        title: json['title'],
        category: json['category'],
        summary: json['summary'],
        pubDate: json['pubDate'],
        updateDate: json['updateDate'],
        mainImage: json['mainImage'],
        imageCaption: json['imageCaption'],
        content: json['content'],
      );
}
