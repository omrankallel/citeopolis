import 'dart:convert';

import 'package:hive/hive.dart';

part 'image_app.g.dart';

ImageApp imageAppFromJson(String str) => ImageApp.fromJson(json.decode(str));

String imageAppToJson(ImageApp data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class ImageApp extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? filename;

  @HiveField(2)
  String? url;

  @HiveField(3)
  String? localPath;

  @HiveField(4)
  double? width;
  @HiveField(5)
  double? height;

  ImageApp({
    this.id,
    this.filename,
    this.url,
    this.localPath,
    this.width,
    this.height,
  });

  factory ImageApp.fromJson(Map<String, dynamic> json) => ImageApp(
        id: json['ID'],
        filename: json['filename'],
        url: json['url'],
        localPath: json['local_path'],
        width: json['width'] == null ? 0.0 : json['width'] * 1.0,
        height: json['height'] == null ? 0.0 : json['height'] * 1.0,
      );

  Map<String, dynamic> toJson() => {
        'ID': id,
        'filename': filename,
        'url': url,
        'local_path': localPath,
        'width': width,
        'height': height,
      };
}
