import 'package:flutter/material.dart';

Color getTextColorBasedOnBackground(Color backgroundColor) {
  final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
  return brightness == Brightness.light ? Colors.black : Colors.white;
}