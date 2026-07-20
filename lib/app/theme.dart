import 'package:flutter/material.dart';

abstract final class StructoTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: .fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: .light,
      ),
      useMaterial3: true,
    );
  }
}
