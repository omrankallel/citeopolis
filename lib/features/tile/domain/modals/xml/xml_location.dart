import 'package:xml/xml.dart';

class Location {
  final String title;
  final String address;
  final String postalCode;
  final String city;
  final double latitude;
  final double longitude;

  Location({
    required this.title,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromXml(XmlElement xmlElement) => Location(
    title: xmlElement.getElement('title')?.innerText ?? '',
    address: xmlElement.getElement('address')?.innerText ?? '',
    postalCode: xmlElement.getElement('postalCode')?.innerText ?? '',
    city: xmlElement.getElement('city')?.innerText ?? '',
    latitude: double.tryParse(xmlElement.getElement('latitude')?.innerText ?? '0') ?? 0.0,
    longitude: double.tryParse(xmlElement.getElement('longitude')?.innerText ?? '0') ?? 0.0,
  );

  String get fullAddress => '$address, $postalCode $city';

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    title: json['title'],
    address: json['address'],
    postalCode: json['postalCode'],
    city: json['city'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'address': address,
    'postalCode': postalCode,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
  };
}