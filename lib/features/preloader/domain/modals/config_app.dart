import 'dart:convert';

import 'package:hive/hive.dart';

import 'configuration.dart';
part 'config_app.g.dart';

ConfigApp configAppFromJson(String str) => ConfigApp.fromJson(json.decode(str));

String configAppToJson(ConfigApp data) => json.encode(data.toJson());

@HiveType(typeId: 2)
class ConfigApp extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? urlApp;

  @HiveField(2)
  Configuration? configuration;

  ConfigApp({
    this.id,
    this.urlApp,
    this.configuration,
  });

  factory ConfigApp.fromJson(Map<String, dynamic> json) => ConfigApp(
        id: json['ID'],
        urlApp: json['url_app'],
        configuration: json['configuration'] == null ? null : Configuration.fromJson(json['configuration']),
      );

  Map<String, dynamic> toJson() => {
        'ID': id,
        'url_app': urlApp,
        'configuration': configuration?.toJson(),
      };
}
