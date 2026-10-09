import 'package:flutter/material.dart';

Map<int, Color> _swatchOpacity = {
  50: Color.fromRGBO(139,195,74,.1),
  100: Color.fromRGBO(139,195,74,.2),
  200: Color.fromRGBO(139,195,74,.3),
  300: Color.fromRGBO(139,195,74,.4),
  400: Color.fromRGBO(139,195,74,.5),
  500: Color.fromRGBO(139,195,74,.6),
  600: Color.fromRGBO(139,195,74,.7),
  700: Color.fromRGBO(139,195,74,.8),
  800: Color.fromRGBO(139,195,74,.9),
  900: Color.fromRGBO(139,195,74,1),
};

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFFF6F6F6);
  static MaterialColor customSwatchColor = MaterialColor(
    0xff8BC34a,
    _swatchOpacity,
  );
}
