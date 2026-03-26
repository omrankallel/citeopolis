import 'dart:convert';

import 'package:hive/hive.dart';

import 'section.dart';
part 'build_page.g.dart';
BuildPage buildPageFromJson(String str) => BuildPage.fromJson(json.decode(str));

String buildPageToJson(BuildPage data) => json.encode(data.toJson());

@HiveType(typeId: 4)
class BuildPage extends HiveObject {
  @HiveField(0)
  final List<Section>? sections;

  BuildPage({
    this.sections,
  });

  factory BuildPage.fromJson(Map<String, dynamic> json) => BuildPage(
        sections: json['sections'] == null ? [] : List<Section>.from(json['sections']!.map((x) => Section.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'sections': sections == null ? [] : List<dynamic>.from(sections!.map((x) => x.toJson())),
      };

  BuildPage copyWith({
    List<Section>? sections,
  }) =>
      BuildPage(
        sections: sections ?? this.sections,
      );
}
