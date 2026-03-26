class GeoLocationInfo {
  final String? name;
  final String? type;
  final String? description;
  final String? imageUrl;

  const GeoLocationInfo({
    this.name,
    this.type,
    this.description,
    this.imageUrl,
  });

  @override
  String toString() => 'GeoLocationInfo(name: $name, type: $type, description: $description, imageUrl: $imageUrl)';

  GeoLocationInfo copyWith({
    String? name,
    String? type,
    String? description,
    String? imageUrl,
  }) =>
      GeoLocationInfo(
        name: name ?? this.name,
        type: type ?? this.type,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  bool get isComplete => name != null && type != null && description != null;

  bool get hasAnyInfo => name != null || type != null || description != null;

  String get displayName => name ?? 'Lieu inconnu';

  String get displayType => type ?? 'Lieu';

  String get displayDescription => description ?? 'Informations sur ce lieu non disponibles.';

  bool get isEmpty => name == null && type == null && description == null && imageUrl == null;

  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocationInfo && other.name == name && other.type == type && other.description == description && other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ description.hashCode ^ imageUrl.hashCode;
}
