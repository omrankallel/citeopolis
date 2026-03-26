import 'package:flutter/material.dart';

import 'constants.dart' show Sizes, kNeutralColor;


class AppFonts {
  static const TextStyle helveticaH1Bold = TextStyle(
    fontFamily: 'Halvetica',
    color: kNeutralColor,
    fontSize: Sizes.x17,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle helveticaH2Bold = TextStyle(
    fontFamily: 'Halvetica',
    color: kNeutralColor,
    fontSize: Sizes.x13,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle helveticaH2Regular = TextStyle(
    fontFamily: 'Halvetica',
    color: kNeutralColor,
    fontSize: Sizes.x13,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle helveticaH2RegularUnderlined = TextStyle(
    fontFamily: 'Halvetica',
    color: kNeutralColor,
    fontSize: Sizes.x13,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
  static const TextStyle helveticaP1Bold = TextStyle(
    fontFamily: 'Halvetica',
    color: kNeutralColor,
    fontSize: Sizes.x12,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle helveticaP1Regular = TextStyle(
    fontFamily: 'Halvetica',
    color: kNeutralColor,
    fontSize: Sizes.x12,
    fontWeight: FontWeight.normal,
  );

  // Poppins font styles
  static const TextStyle poppinsBSemiBold = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontSize: Sizes.x11,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle poppinsBRegular = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontWeight: FontWeight.normal,
    fontSize: Sizes.x11,
  );
  static const TextStyle poppinsL1SemiBold = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontSize: Sizes.x11,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle poppinsL1Bold = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontSize: Sizes.x11,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle poppinsI1Bold = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontSize: Sizes.x12,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle poppinsI1Regular = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontSize: Sizes.x12,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle poppinsI2Regular = TextStyle(
    fontFamily: 'Poppins',
    color: kNeutralColor,
    fontSize: Sizes.x8,
    fontWeight: FontWeight.normal,
  );
}