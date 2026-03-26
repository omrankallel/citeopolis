import 'package:flutter/material.dart';

import '../constants/colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: surfaceLight,
  scaffoldBackgroundColor: surfaceLight,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(
      color: onSurfaceLight,
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: surfaceContainerLight,
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryLight;
      }
      return onSurfaceLight;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? surfaceContainerLight : outlineDark,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? primaryLight : surfaceContainerLight,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryLight;
      }
      return surfaceContainerLight;
    }),
    checkColor: WidgetStateProperty.all(surfaceContainerLight),
  ),
  dividerTheme: const DividerThemeData(
    color: outlineLight,
    endIndent: 10,
    thickness: 0.6,
    indent: 10,
  ),
  iconTheme: const IconThemeData(
    color: onSurfaceLight,
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      height: 32 / 24.0,
    ),
    headlineLarge: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 32.0,
      fontWeight: FontWeight.w400,
      height: 32 / 32.0,
    ),
    titleLarge: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
      height: 28 / 22.0,
    ),
    titleMedium: TextStyle(
      color: primaryLight,
      fontFamily: 'Roboto',
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      height: 24 / 16.0,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      color: primaryLight,
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 20 / 14.0,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      height: 24 / 16.0,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      color: onPrimaryLight,
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      height: 20 / 14.0,
      letterSpacing: .25,
    ),
    bodySmall: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      height: 16 / 12.0,
      letterSpacing: .4,
    ),
    labelLarge: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 20 / 14.0,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      color: primaryLight,
      fontFamily: 'Roboto',
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      height: 16 / 12.0,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      color: onSurfaceLight,
      fontFamily: 'Roboto',
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      height: 16 / 11.0,
      letterSpacing: 0.1,
    ),
  ),
  drawerTheme: const DrawerThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    backgroundColor: surfaceContainerLight,
  ),
  dialogTheme: const DialogThemeData(backgroundColor: surfaceContainerLight),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: surfaceDark,
  scaffoldBackgroundColor: surfaceDark,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(
      color: onSurfaceDark,
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: surfaceContainerLight,
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryDark;
      }
      return onSurfaceDark;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? surfaceContainerDark : outlineLight,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? primaryDark : surfaceContainerDark,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryDark;
      }
      return surfaceContainerDark;
    }),
    checkColor: WidgetStateProperty.all(surfaceContainerDark),
  ),
  dividerTheme: const DividerThemeData(
    color: outlineDark,
    endIndent: 10,
    thickness: 0.6,
    indent: 10,
  ),
  iconTheme: const IconThemeData(
    color: onSurfaceDark,
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      height: 32 / 24.0,
    ),
    headlineLarge: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 32.0,
      fontWeight: FontWeight.w400,
      height: 32 / 32.0,
    ),
    titleLarge: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
      height: 28 / 22.0,
    ),
    titleMedium: TextStyle(
      color: primaryDark,
      fontFamily: 'Roboto',
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      height: 24 / 16.0,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      color: primaryDark,
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 20 / 14.0,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      height: 24 / 16.0,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      color: onPrimaryDark,
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      height: 20 / 14.0,
      letterSpacing: .25,
    ),
    bodySmall: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      height: 16 / 12.0,
      letterSpacing: .4,
    ),
    labelLarge: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 20 / 14.0,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      color: primaryDark,
      fontFamily: 'Roboto',
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      height: 16 / 12.0,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      color: onSurfaceDark,
      fontFamily: 'Roboto',
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      height: 16 / 11.0,
      letterSpacing: 0.1,
    ),
  ),
  drawerTheme: const DrawerThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(16.0),
      ),
    ),
    backgroundColor: surfaceContainerDark,
  ),
  dialogTheme: const DialogThemeData(backgroundColor: surfaceContainerDark),
);
