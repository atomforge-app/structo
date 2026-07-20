import 'dart:ui';

import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/molecule.dart';

/// Renders a [Molecule] using canvas drawing primitives.
class MoleculePainter extends CustomPainter {
  MoleculePainter({required this.molecule});

  final Molecule molecule;

  static const double atomRadius = 18;
  static const double bondStrokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    for (final bond in molecule.bonds) {
      _drawBond(canvas, bond);
    }

    for (final atom in molecule.atoms) {
      _drawAtom(canvas, atom);
    }
  }

  void _drawBond(Canvas canvas, Bond bond) {
    final atom1 = molecule.atomById(bond.atom1Id);
    final atom2 = molecule.atomById(bond.atom2Id);
    if (atom1 == null || atom2 == null) {
      return;
    }

    final start = _toOffset(atom1.position);
    final end = _toOffset(atom2.position);
    final trimmedStart = _trimToAtomEdge(start, end);
    final trimmedEnd = _trimToAtomEdge(end, start);

    final paint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = bondStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(trimmedStart, trimmedEnd, paint);
  }

  void _drawAtom(Canvas canvas, Atom atom) {
    final center = _toOffset(atom.position);

    final fillPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, atomRadius, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, atomRadius, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: atom.element.symbol,
        style: const TextStyle(
          color: Color(0xFF212121),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = center -
        Offset(
          textPainter.width / 2,
          textPainter.height / 2,
        );
    textPainter.paint(canvas, textOffset);
  }

  Offset _trimToAtomEdge(Offset from, Offset to) {
    final direction = to - from;
    final distance = direction.distance;
    if (distance == 0) {
      return from;
    }

    final unit = direction / distance;
    return from + unit * atomRadius;
  }

  Offset _toOffset(Point2D point) => Offset(point.x, point.y);

  @override
  bool shouldRepaint(covariant MoleculePainter oldDelegate) {
    return oldDelegate.molecule != molecule;
  }
}
