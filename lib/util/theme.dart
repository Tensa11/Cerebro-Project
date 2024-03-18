import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      background: Color(0xFFFFFFFF),
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFF000000)
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      background: Color(0xFF020F2A),
      primary: Color(0xFF041648),
      secondary: Color(0xFF69C3F2),
      tertiary: Color(0xFFFFFFFF)
  ),
);
