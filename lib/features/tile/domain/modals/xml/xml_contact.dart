import 'package:xml/xml.dart';

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

  String get fullName => '$firstName $lastName';

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    email: json['email'],
  );
  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
  };
}
