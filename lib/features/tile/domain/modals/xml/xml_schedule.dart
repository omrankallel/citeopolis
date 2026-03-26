import 'package:xml/xml.dart';

class Schedule {
  final String dayName;
  final String datetime;

  Schedule({
    required this.dayName,
    required this.datetime,
  });

  factory Schedule.fromXml(XmlElement xmlElement) => Schedule(
    dayName: xmlElement.getAttribute('name') ?? '',
    datetime: xmlElement.getElement('datetime')?.innerText ?? '',
  );
  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    dayName: json['dayName'],
    datetime: json['datetime'],
  );
  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'datetime': datetime,
  };
}
