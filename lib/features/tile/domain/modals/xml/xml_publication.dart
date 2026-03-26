import 'package:xml/xml.dart';

import 'xml_download_file.dart';

class Publication {
  final String title;
  final String category;
  final String summary;
  final String pubDate;
  final String updateDate;
  final String mainImage;
  final String imageCaption;
  final String content;
  final DownloadFile downloadFile;

  Publication({
    required this.title,
    required this.category,
    required this.summary,
    required this.pubDate,
    required this.updateDate,
    required this.mainImage,
    required this.imageCaption,
    required this.content,
    required this.downloadFile,
  });

  factory Publication.fromXml(XmlElement xmlElement) => Publication(
        title: xmlElement.getElement('title')?.innerText ?? '',
        category: xmlElement.getElement('category')?.innerText ?? '',
        summary: xmlElement.getElement('summary')?.innerText ?? '',
        pubDate: xmlElement.getElement('pubDate')?.innerText ?? '',
        updateDate: xmlElement.getElement('updateDate')?.innerText ?? '',
        mainImage: xmlElement.getElement('mainImage')?.innerText ?? '',
        imageCaption: xmlElement.getElement('imageCaption')?.innerText ?? '',
        content: xmlElement.getElement('content')?.innerXml ?? '',
        downloadFile: xmlElement.getElement('download') != null
            ? DownloadFile.fromXml(xmlElement.getElement('download')!)
            : DownloadFile(
                icon: '',
                title: '',
                type: '',
                size: '',
                link: '',
              ),
      );

  factory Publication.fromJson(Map<String, dynamic> json) => Publication(
        title: json['title'],
        category: json['category'],
        summary: json['summary'],
        pubDate: json['pubDate'],
        updateDate: json['updateDate'],
        mainImage: json['mainImage'],
        imageCaption: json['imageCaption'],
        content: json['content'],
        downloadFile: DownloadFile.fromJson(json['downloadFile']),
      );
}
