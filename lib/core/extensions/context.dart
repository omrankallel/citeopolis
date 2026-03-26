import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../constants/constants.dart' show DesignScreenSize;

extension BuildContextX on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  double? get iconSize => IconTheme.of(this).size;

  EdgeInsets get padding => MediaQuery.of(this).padding;

  double get getResponsiveWidth => MediaQuery.of(this).size.width * MediaQuery.of(this).devicePixelRatio;

  double get getResponsiveHeight => MediaQuery.of(this).size.height * MediaQuery.of(this).devicePixelRatio;

  double get getDevicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  double responsive(double size, {Axis axis = Axis.vertical}) {
    final currentSize = axis == Axis.horizontal ? screenSize.width : screenSize.height;
    final designSize = axis == Axis.horizontal ? DesignScreenSize.designScreenSize.width : DesignScreenSize.designScreenSize.height;

    return size * currentSize / designSize;
  }

  AppLocalizations? get localizations => AppLocalizations.of(this);
}


