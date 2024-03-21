import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      background: Color(0xFFFFFFFF),
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFF1497E8),
      tertiary: Color(0xFF000000)
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      background: Color(0xFF010D23),
      primary: Color(0xFF041648),
      secondary: Color(0xFF081E65),
      tertiary: Color(0xFFFFFFFF)
  ),
);


// Color Lists
// 0xFF081E65 Dark Blue
// 0xFF13A4FF Blue
