import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/services/image_app/modals/image_app.dart';


part 'configuration.g.dart';

Configuration configurationFromJson(String str) => Configuration.fromJson(json.decode(str));

String configurationToJson(Configuration data) => json.encode(data.toJson());

@HiveType(typeId: 3)
class Configuration extends HiveObject {
  @HiveField(0)
  String? positionTitle;

  @HiveField(1)
  String? titleApp;

  @HiveField(2)
  ImageApp? backgroundApp;

  @HiveField(3)
  ImageApp? logoApp;

  @HiveField(4)
  String? leadApp;

  @HiveField(5)
  String? positionLead;

  @HiveField(6)
  List<ImageApp>? partnerRepeater;

  @HiveField(7)
  String? mailBug;

  @HiveField(8)
  String? mailContactCommunity;

  @HiveField(9)
  String? urlLegalPage;

  @HiveField(10)
  String? urlProtectionPage;

  @HiveField(11)
  String? urlFacebook;

  @HiveField(12)
  String? urlTwitter;

  @HiveField(13)
  String? urlLinkedin;

  @HiveField(14)
  String? urlYoutube;

  @HiveField(15)
  String? urlInstagram;

  @HiveField(16)
  String? adress;

  @HiveField(17)
  String? zipCode;

  @HiveField(18)
  String? city;

  @HiveField(19)
  String? website;

  @HiveField(20)
  String? phone;

  Configuration({
    this.positionTitle,
    this.titleApp,
    this.backgroundApp,
    this.logoApp,
    this.leadApp,
    this.positionLead,
    this.partnerRepeater,
    this.mailBug,
    this.mailContactCommunity,
    this.urlLegalPage,
    this.urlProtectionPage,
    this.urlFacebook,
    this.urlTwitter,
    this.urlLinkedin,
    this.urlYoutube,
    this.urlInstagram,
    this.adress,
    this.zipCode,
    this.city,
    this.website,
    this.phone,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
        positionTitle: json['position_title'],
        titleApp: json['title_app'],
        backgroundApp: json['background_app'] == null ? null : ImageApp.fromJson(json['background_app']),
        logoApp: json['logo_app'] == null ? null : ImageApp.fromJson(json['logo_app']),
        leadApp: json['lead_app'],
        positionLead: json['position_lead'],
        partnerRepeater: json['partner_repeater'] == null ? [] : List<ImageApp>.from(json['partner_repeater']!.map((x) => ImageApp.fromJson(x['partner_img']))),
        mailBug: json['mail_bug'],
        mailContactCommunity: json['mail_contact_community'],
        urlLegalPage: json['url_legal_page'],
        urlProtectionPage: json['url_protection_page'],
        urlFacebook: json['url_facebook'],
        urlTwitter: json['url_twitter'],
        urlLinkedin: json['url_linkedin'],
        urlYoutube: json['url_youtube'],
        urlInstagram: json['url_instagram'],
        adress: json['adress'],
        zipCode: json['zip_code'],
        city: json['city'],
        website: json['website'],
        phone: json['phone'],
      );

  Map<String, dynamic> toJson() => {
        'position_title': positionTitle,
        'title_app': titleApp,
        'background_app': backgroundApp?.toJson(),
        'logo_app': logoApp?.toJson(),
        'lead_app': leadApp,
        'position_lead': positionLead,
        'partner_repeater': partnerRepeater == null ? [] : List<dynamic>.from(partnerRepeater!.map((x) => x.toJson())),
        'mail_bug': mailBug,
        'mail_contact_community': mailContactCommunity,
        'url_legal_page': urlLegalPage,
        'url_protection_page': urlProtectionPage,
        'url_facebook': urlFacebook,
        'url_twitter': urlTwitter,
        'url_linkedin': urlLinkedin,
        'url_youtube': urlYoutube,
        'url_instagram': urlInstagram,
        'adress': adress,
        'zip_code': zipCode,
        'city': city,
        'website': website,
        'phone': phone,
      };
}
