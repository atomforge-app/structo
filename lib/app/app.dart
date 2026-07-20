import 'package:flutter/material.dart';
import 'package:structo/app/theme.dart';
import 'package:structo/features/editor/editor_screen.dart';

class StructoApp extends StatelessWidget {
  const StructoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Structo',
      theme: StructoTheme.light(),
      home: const EditorScreen(),
    );
  }
}
