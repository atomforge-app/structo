import 'package:flutter/material.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/features/editor/painters/molecule_painter.dart';

/// Displays a [Molecule] on a canvas.
class MoleculeCanvas extends StatelessWidget {
  const MoleculeCanvas({
    super.key,
    required this.molecule,
  });

  final Molecule molecule;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MoleculePainter(molecule: molecule),
      child: const SizedBox.expand(),
    );
  }
}
