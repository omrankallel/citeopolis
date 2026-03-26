import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../thematic/thematic.dart';

part 'notification.g.dart';

List<Notification> notificationFromJson(String str) => List<Notification>.from(json.decode(str).map((x) => Notification.fromJson(x)));

String notificationToJson(List<Notification> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 15)
class Notification extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? body;

  @HiveField(3)
  String? typeLink;

  @HiveField(4)
  String? idTile;

  @HiveField(5)
  String? urlLink;

  @HiveField(6)
  String? displayStartDateNotif;

  @HiveField(7)
  String? displayEndDateNotif;

  @HiveField(8)
  bool? publishNotif;

  @HiveField(9)
  String? status;

  @HiveField(10)
  List<Thematic>? thematic;

  @HiveField(11)
  String? image;

  @HiveField(12)
  String? localPath;

  @HiveField(13)
  bool isRead;

  @HiveField(14)
  DateTime? readAt;

  @HiveField(15)
  bool isDeleted;

  @HiveField(16)
  DateTime? deletedAt;

  Notification({
    this.id,
    this.title,
    this.body,
    this.typeLink,
    this.idTile,
    this.urlLink,
    this.displayStartDateNotif,
    this.displayEndDateNotif,
    this.publishNotif,
    this.status,
    this.thematic,
    this.image,
    this.localPath,
    this.isRead = false,
    this.readAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: _parseId(json['ID']),
        title: json['title']?.toString(),
        body: json['body']?.toString(),
        typeLink: json['type_link']?.toString(),
        idTile: _parseTileId(json['tile']),
        urlLink: json['url_link']?.toString(),
        displayStartDateNotif: json['display_start_date_notif']?.toString(),
        displayEndDateNotif: json['display_end_date_notif']?.toString(),
        publishNotif: _parseBool(json['publish_notif']),
        status: json['status']?.toString(),
        thematic: _parseThematic(json['notification-thematic']),
        image: _parseImage(json['image']),
        localPath: json['localPath']?.toString(),
        isRead: _parseBool(json['isRead']) ?? false,
        readAt: _parseDateTime(json['readAt']),
    isDeleted: _parseBool(json['isDeleted']) ?? false,
    deletedAt: _parseDateTime(json['deletedAt']),
      );

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static String? _parseTileId(dynamic tile) {
    if (tile == null) return null;
    if (tile is Map<String, dynamic>) {
      final id = tile['id'];
      if (id != null) return id.toString();
    }
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is int) return value == 1;
    return null;
  }

  static List<Thematic>? _parseThematic(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.whereType<Map<String, dynamic>>().map((item) => Thematic.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error parsing thematic: $e');
        return [];
      }
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('Error parsing DateTime: $e');
        return null;
      }
    }
    return null;
  }

  static String? _parseImage(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'ID': id,
        'title': title,
        'body': body,
        'type_link': typeLink,
        'tile': idTile != null ? {'id': idTile} : null,
        'url_link': urlLink,
        'display_start_date_notif': displayStartDateNotif,
        'display_end_date_notif': displayEndDateNotif,
        'publish_notif': publishNotif,
        'status': status,
        'notification-thematic': thematic?.map((x) => x.toJson()).toList() ?? [],
        'image': image,
        'localPath': localPath,
        'isRead': isRead,
        'readAt': readAt?.toIso8601String(),
    'isDeleted': isDeleted,
    'deletedAt': deletedAt?.toIso8601String(),
      };

  Notification copyWith({
    int? id,
    String? title,
    String? body,
    String? typeLink,
    String? idTile,
    String? urlLink,
    String? displayStartDateNotif,
    String? displayEndDateNotif,
    String? project,
    bool? publishNotif,
    String? status,
    List<Thematic>? thematic,
    String? image,
    String? localPath,
    bool? isRead,
    DateTime? readAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) =>
      Notification(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        typeLink: typeLink ?? this.typeLink,
        idTile: idTile ?? this.idTile,
        urlLink: urlLink ?? this.urlLink,
        displayStartDateNotif: displayStartDateNotif ?? this.displayStartDateNotif,
        displayEndDateNotif: displayEndDateNotif ?? this.displayEndDateNotif,
        publishNotif: publishNotif ?? this.publishNotif,
        status: status ?? this.status,
        thematic: thematic ?? this.thematic,
        image: image ?? this.image,
        localPath: localPath ?? this.localPath,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  void markAsRead() {
    isRead = true;
    readAt = DateTime.now();
    save();
  }

  void markAsUnread() {
    isRead = false;
    readAt = null;
    save();
  }
  void markAsDeleted() {
    isDeleted = true;
    deletedAt = DateTime.now();
    save();
  }

  void restoreFromDeleted() {
    isDeleted = false;
    deletedAt = null;
    save();
  }

  bool get isVisible => !isDeleted;


  @override
  String toString() => 'Notification(id: $id, title: $title)';
}
