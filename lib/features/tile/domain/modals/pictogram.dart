import 'package:hive/hive.dart';
part 'pictogram.g.dart';

@HiveType(typeId: 37)
class Pictogram extends HiveObject {
  @HiveField(0)
   String? url;
  @HiveField(1)
   String? localPath;

  Pictogram({
    this.url,
    this.localPath,
  });

  Pictogram copyWith({
    String? url,
    String? localPath,
  }) =>
      Pictogram(
        url: url ?? this.url,
        localPath: localPath ?? this.localPath,
      );

  factory Pictogram.fromJson(Map<String, dynamic> json) => Pictogram(
        url: json['url'],
        localPath: json['localPath'],
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'localPath': localPath,
      };
}
