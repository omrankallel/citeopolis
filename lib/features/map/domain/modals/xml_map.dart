import 'package:xml/xml.dart';

class MapXml {
  final String title;
  final String category;
  final String summary;
  final String pubDate;
  final String updateDate;
  final String eventStartDate;
  final String eventEndDate;
  final String eventStartTime;
  final String eventEndTime;
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
  final DownloadFile downloadFile;

  MapXml({
    required this.title,
    required this.category,
    required this.summary,
    required this.pubDate,
    required this.updateDate,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.eventStartTime,
    required this.eventEndTime,
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
    required this.downloadFile,
  });

  factory MapXml.fromXml(XmlElement xmlElement) {
    final locationElement = xmlElement.getElement('location');
    final contactElement = xmlElement.getElement('contact');
    final scheduleElement = xmlElement.getElement('schedule');
    final scheduleElements = scheduleElement?.findElements('day') ?? [];
    final downloadElement = xmlElement.getElement('download');

    return MapXml(
      title: xmlElement.getElement('title')?.innerText ?? '',
      category: xmlElement.getElement('category')?.innerText ?? '',
      summary: xmlElement.getElement('summary')?.innerText ?? '',
      pubDate: xmlElement.getElement('pubDate')?.innerText ?? '',
      updateDate: xmlElement.getElement('updateDate')?.innerText ?? '',
      eventStartDate: xmlElement.getElement('eventStartDate')?.innerText ?? '',
      eventEndDate: xmlElement.getElement('eventEndDate')?.innerText ?? '',
      eventStartTime: xmlElement.getElement('eventStartTime')?.innerText ?? '',
      eventEndTime: xmlElement.getElement('eventEndTime')?.innerText ?? '',
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
      downloadFile: downloadElement != null
          ? DownloadFile.fromXml(downloadElement)
          : DownloadFile(
              icon: '',
              title: '',
              type: '',
              size: '',
              link: '',
            ),
    );
  }

  factory MapXml.fromJson(Map<String, dynamic> json) => MapXml(
        title: json['title'] ?? '',
        category: json['category'] ?? '',
        summary: json['summary'] ?? '',
        pubDate: json['pubDate'] ?? '',
        updateDate: json['updateDate'] ?? '',
        eventStartDate: json['eventStartDate'] ?? '',
        eventEndDate: json['eventEndDate'] ?? '',
        eventStartTime: json['eventStartTime'] ?? '',
        eventEndTime: json['eventEndTime'] ?? '',
        mainImage: json['mainImage'] ?? '',
        imageCaption: json['imageCaption'] ?? '',
        content: json['content'] ?? '',
        location: json['location'] != null
            ? Location.fromJson(json['location'])
            : Location(
                title: '',
                address: '',
                postalCode: '',
                city: '',
                latitude: 0.0,
                longitude: 0.0,
              ),
        additionalInformation: json['additionalInformation'] ?? '',
        schedule: (json['schedule'] as List<dynamic>?)?.map((e) => Schedule.fromJson(e)).toList() ?? [],
        website: json['website'] ?? '',
        phone1: json['phone1'] ?? '',
        phone2: json['phone2'] ?? '',
        email: json['email'] ?? '',
        contact: json['contact'] != null
            ? Contact.fromJson(json['contact'])
            : Contact(
                firstName: '',
                lastName: '',
                phone: '',
                email: '',
              ),
        facebook: json['facebook'] ?? '',
        twitter: json['twitter'] ?? '',
        instagram: json['instagram'] ?? '',
        linkedin: json['linkedin'] ?? '',
        youtube: json['youtube'] ?? '',
        downloadFile: json['downloadFile'] != null
            ? DownloadFile.fromJson(json['downloadFile'])
            : DownloadFile(
                icon: '',
                title: '',
                type: '',
                size: '',
                link: '',
              ),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'summary': summary,
        'pubDate': pubDate,
        'updateDate': updateDate,
        'eventStartDate': eventStartDate,
        'eventEndDate': eventEndDate,
        'eventStartTime': eventStartTime,
        'eventEndTime': eventEndTime,
        'mainImage': mainImage,
        'imageCaption': imageCaption,
        'content': content,
        'location': location.toJson(),
        'additionalInformation': additionalInformation,
        'schedule': schedule.map((e) => e.toJson()).toList(),
        'website': website,
        'phone1': phone1,
        'phone2': phone2,
        'email': email,
        'contact': contact.toJson(),
        'facebook': facebook,
        'twitter': twitter,
        'instagram': instagram,
        'linkedin': linkedin,
        'youtube': youtube,
        'downloadFile': downloadFile.toJson(),
      };
}

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

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        title: json['title'] ?? '',
        address: json['address'] ?? '',
        postalCode: json['postalCode'] ?? '',
        city: json['city'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'postalCode': postalCode,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'fullAddress': fullAddress,
      };

  String get fullAddress => '$address, $postalCode $city';
}

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
        dayName: json['dayName'] ?? '',
        datetime: json['datetime'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'dayName': dayName,
        'datetime': datetime,
      };
}

class Contact {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory Contact.fromXml(XmlElement xmlElement) => Contact(
        firstName: xmlElement.getElement('firstName')?.innerText ?? '',
        lastName: xmlElement.getElement('lastName')?.innerText ?? '',
        phone: xmlElement.getElement('phone')?.innerText ?? '',
        email: xmlElement.getElement('email')?.innerText ?? '',
      );

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'fullName': fullName,
      };

  String get fullName => '$firstName $lastName';
}

class DownloadFile {
  final String icon;
  final String title;
  final String type;
  final String size;
  final String link;

  DownloadFile({
    required this.icon,
    required this.title,
    required this.type,
    required this.size,
    required this.link,
  });

  factory DownloadFile.fromXml(XmlElement xmlElement) => DownloadFile(
        icon: xmlElement.getElement('icon')?.innerText ?? '',
        title: xmlElement.getElement('title')?.innerText ?? '',
        type: xmlElement.getElement('type')?.innerText ?? '',
        size: xmlElement.getElement('size')?.innerText ?? '',
        link: xmlElement.getElement('link')?.innerText ?? '',
      );

  factory DownloadFile.fromJson(Map<String, dynamic> json) => DownloadFile(
        icon: json['icon'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        size: json['size'] ?? '',
        link: json['link'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'type': type,
        'size': size,
        'link': link,
      };
}
