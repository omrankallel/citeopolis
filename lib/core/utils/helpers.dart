import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:xml/xml.dart';

class Helpers {
  static Timer? _searchOnStoppedTyping;

  static double getResponsiveWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double getResponsiveHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double getDevicePixelRatio(BuildContext context) => MediaQuery.of(context).devicePixelRatio;

  static bool isNullEmptyOrFalse(dynamic o) {
    if (o is Map<String, dynamic> || o is List<dynamic>) {
      return o == null || o.length == 0;
    }
    return o == null || false == o || '' == o;
  }

  static bool isNotNullAndEmpty(String? value) => value != null && value.isNotEmpty;

  static void onSearchHandler(void Function() callback) {
    if (_searchOnStoppedTyping != null) _searchOnStoppedTyping!.cancel();
    _searchOnStoppedTyping = Timer(const Duration(milliseconds: 800), callback);
  }

  static String getEnumValue(e) => e.toString().split('.').last;

  static bool isValidBase64(String? base64String) {
    if (base64String == null) return true;

    String cleanedBase64 = base64String;
    if (base64String.startsWith('data:image/')) {
      final parts = base64String.split(',');
      if (parts.length < 2) return false;
      cleanedBase64 = parts[1];
    }

    final RegExp base64Regex = RegExp(
      r'^(?:[A-Za-z0-9+/\-=_]+)*(?:[A-Za-z0-9+/\-=_]{2,3}==|[A-Za-z0-9+/\-=_]{4})$',
    );

    return base64Regex.hasMatch(cleanedBase64);
  }

  static bool isSvgData(String? data, String? fileName) {
    if ((fileName ?? '').toLowerCase().endsWith('.svg')) return true;
    if (data == null) return false;

    try {
      final String decoded = utf8.decode(base64Decode(data));
      return decoded.toLowerCase().contains('<svg') || decoded.toLowerCase().contains('<!doctype svg');
    } catch (e) {
      return false;
    }
  }

  static String convertDateTimeToString(DateTime dateTime) {
    final DateFormat format = DateFormat('dd/MM/yyyy à HH:mm');
    return format.format(dateTime);
  }

  static Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }

  static String convertDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    final DateFormat format = DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  static String convertDateAmPmPreview(String dateString) {
    final dateTime = Jiffy.parse(dateString, pattern: 'yyyy-MM-dd hh:mm:ss');
    final String formattedDate = dateTime.format(pattern: 'dd/MM/yyyy - HH:mm');
    return formattedDate;
  }

  static String getRawHtml(XmlElement xmlElement, String tagName) {
    final element = xmlElement.getElement(tagName);
    if (element == null) return '';

    return element.children.map((node) => node.toXmlString()).join();
  }

  static void showSnackBar(BuildContext context, String message, Color backgroundColor) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
