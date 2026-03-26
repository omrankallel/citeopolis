import 'package:hive/hive.dart';

part 'favorite.g.dart';

@HiveType(typeId: 50)
class Favorite extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? subtitle;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  String? localImagePath;

  @HiveField(6)
  Map<String, dynamic> originalData;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  Favorite({
    required this.id,
    required this.type,
    required this.title,
    required this.originalData,
    required this.createdAt,
    this.subtitle,
    this.imageUrl,
    this.localImagePath,
    this.updatedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'],
        type: json['type'],
        title: json['title'],
        subtitle: json['subtitle'],
        imageUrl: json['imageUrl'],
        localImagePath: json['localImagePath'],
        originalData: Map<String, dynamic>.from(json['originalData']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'localImagePath': localImagePath,
        'originalData': originalData,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Favorite copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? localImagePath,
    Map<String, dynamic>? originalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Favorite(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        imageUrl: imageUrl ?? this.imageUrl,
        localImagePath: localImagePath ?? this.localImagePath,
        originalData: originalData ?? this.originalData,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'Favorite{id: $id, type: $type, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, localImagePath: $localImagePath, originalData: $originalData, createdAt: $createdAt, updatedAt: $updatedAt}';
}
