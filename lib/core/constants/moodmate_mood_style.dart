import 'package:flutter/material.dart';

class MoodMateMoodStyle {
  const MoodMateMoodStyle._();

  static const backgroundColors = <String, Color>{
    'happy': Color(0xFFFDEADB),
    'angry': Color(0xFFF4C8C8),
    'sad': Color(0xFFE2ECF5),
    'neutral': Color(0xFFEFECE2),
  };

  static const foregroundColor = Color(0xFF333333);

  static Color backgroundColorFor(String mood) =>
      backgroundColors[mood] ?? backgroundColors['neutral']!;
}
