import 'package:flutter/material.dart';

abstract class ThemeState {
  final ThemeData themeData;
  const ThemeState(this.themeData);
}

class ThemeLight extends ThemeState {
  ThemeLight() : super(ThemeData.light());
}

class ThemeDark extends ThemeState {
  ThemeDark() : super(ThemeData.dark());
}
