import 'dart:convert';

import 'package:hive/hive.dart';

part 'thematic.g.dart';

List<Thematic> thematicFromJson(String str) => List<Thematic>.from(json.decode(str).map((x) => Thematic.fromJson(x)));

String thematicToJson(List<Thematic> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 16)
class Thematic extends HiveObject {
  @HiveField(0)
  int? termId;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? slug;

  @HiveField(3)
  int? termGroup;

  @HiveField(4)
  int? termTaxonomyId;

  @HiveField(5)
  String? taxonomy;

  @HiveField(6)
  String? description;

  @HiveField(7)
  int? parent;

  @HiveField(8)
  int? count;

  @HiveField(9)
  String? filter;

  @HiveField(10)
  bool checked;

  Thematic({
    this.termId,
    this.name,
    this.slug,
    this.termGroup,
    this.termTaxonomyId,
    this.taxonomy,
    this.description,
    this.parent,
    this.count,
    this.filter,
    this.checked = false,
  });

  factory Thematic.fromJson(Map<String, dynamic> json) => Thematic(
        termId: json['term_id'],
        name: json['name'],
        slug: json['slug'],
        termGroup: json['term_group'],
        termTaxonomyId: json['term_taxonomy_id'],
        taxonomy: json['taxonomy'],
        description: json['description'],
        parent: json['parent'],
        count: json['count'],
        filter: json['filter'],
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'term_id': termId,
        'name': name,
        'slug': slug,
        'term_group': termGroup,
        'term_taxonomy_id': termTaxonomyId,
        'taxonomy': taxonomy,
        'description': description,
        'parent': parent,
        'count': count,
        'filter': filter,
        'checked': checked,
      };

  Thematic copyWith({
    int? termId,
    String? name,
    String? slug,
    int? termGroup,
    int? termTaxonomyId,
    String? taxonomy,
    String? description,
    int? parent,
    int? count,
    String? filter,
    bool? checked,
  }) =>
      Thematic(
        termId: termId ?? this.termId,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        termGroup: termGroup ?? this.termGroup,
        termTaxonomyId: termTaxonomyId ?? this.termTaxonomyId,
        taxonomy: taxonomy ?? this.taxonomy,
        description: description ?? this.description,
        parent: parent ?? this.parent,
        count: count ?? this.count,
        filter: filter ?? this.filter,
        checked: checked ?? this.checked,
      );
}
