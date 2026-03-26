import 'package:xml/xml.dart';
import 'xml_contact.dart';
import 'xml_location.dart';
import 'xml_schedule.dart';

class Directory {
  final String title;
  final String category;
  final String summary;
  final String pubDate;
  final String updateDate;
  final String mainImage;
  final String imageCaption;
  final String content;
  final Location location;
  final String additionalInformation;
  final List<Schedule> schedule;
  final String website;
  final String phone1;
  final String phone2;
  final String email;
  final Contact contact;
  final String facebook;
  final String twitter;
  final String instagram;
  final String linkedin;
  final String youtube;

  Directory({
    required this.title,
    required this.category,
    required this.summary,
    required this.pubDate,
    required this.updateDate,
    required this.mainImage,
    required this.imageCaption,
    required this.content,
    required this.location,
    required this.additionalInformation,
    required this.schedule,
    required this.website,
    required this.phone1,
    required this.email,
    required this.contact,
    required this.phone2,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.linkedin,
    required this.youtube,
  });

  factory Directory.fromXml(XmlElement xmlElement) {
    final locationElement = xmlElement.getElement('location');
    final contactElement = xmlElement.getElement('contact');
    final scheduleElement = xmlElement.getElement('schedule');
    final scheduleElements = scheduleElement?.findElements('day') ?? [];

    return Directory(
      title: xmlElement.getElement('title')?.innerText ?? '',
      category: xmlElement.getElement('category')?.innerText ?? '',
      summary: xmlElement.getElement('summary')?.innerText ?? '',
      pubDate: xmlElement.getElement('pubDate')?.innerText ?? '',
      updateDate: xmlElement.getElement('updateDate')?.innerText ?? '',
      mainImage: xmlElement.getElement('mainImage')?.innerText ?? '',
      imageCaption: xmlElement.getElement('imageCaption')?.innerText ?? '',
      content: xmlElement.getElement('content')?.innerXml ?? '',
      location: locationElement != null
          ? Location.fromXml(locationElement)
          : Location(
              title: '',
              address: '',
              postalCode: '',
              city: '',
              latitude: 0.0,
              longitude: 0.0,
            ),
      additionalInformation: xmlElement.getElement('additionalInformation')?.innerText ?? '',
      schedule: scheduleElements.map((e) => Schedule.fromXml(e)).toList(),
      website: xmlElement.getElement('website')?.innerText ?? '',
      phone1: xmlElement.getElement('phone1')?.innerText ?? '',
      phone2: xmlElement.getElement('phone2')?.innerText ?? '',
      email: xmlElement.getElement('email')?.innerText ?? '',
      contact: contactElement != null
          ? Contact.fromXml(contactElement)
          : Contact(
              firstName: '',
              lastName: '',
              phone: '',
              email: '',
            ),
      facebook: xmlElement.getElement('facebook')?.innerText ?? '',
      twitter: xmlElement.getElement('twitter')?.innerText ?? '',
      instagram: xmlElement.getElement('instagram')?.innerText ?? '',
      linkedin: xmlElement.getElement('linkedin')?.innerText ?? '',
      youtube: xmlElement.getElement('youtube')?.innerText ?? '',
    );
  }

  factory Directory.fromJson(Map<String, dynamic> json) => Directory(
        title: json['title'],
        category: json['category'],
        summary: json['summary'],
        pubDate: json['pubDate'],
        updateDate: json['updateDate'],
        mainImage: json['mainImage'],
        imageCaption: json['imageCaption'],
        content: json['content'],
        location: Location.fromJson(json['location']),
        additionalInformation: json['additionalInformation'],
        schedule: (json['schedule'] as List<dynamic>).map((e) => Schedule.fromJson(e)).toList(),
        website: json['website'],
        phone1: json['phone1'],
        phone2: json['phone2'],
        email: json['email'],
        contact: Contact.fromJson(json['contact']),
        facebook: json['facebook'],
        twitter: json['twitter'],
        instagram: json['instagram'],
        linkedin: json['linkedin'],
        youtube: json['youtube'],
      );
}
