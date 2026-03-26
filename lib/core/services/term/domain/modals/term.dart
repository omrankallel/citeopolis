import 'dart:convert';

import 'package:hive/hive.dart';

part 'term.g.dart';

List<Term> termFromJson(String str) => List<Term>.from(json.decode(str).map((x) => Term.fromJson(x)));

String termToJson(List<Term> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 20)
class Term extends HiveObject {
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

  Term({
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
  });

  factory Term.fromJson(Map<String, dynamic> json) => Term(
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
      };
}
