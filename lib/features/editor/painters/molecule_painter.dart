import 'package:flutter/material.dart';
import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/molecule.dart';

/// Renders a [Molecule] onto the canvas.
class MoleculePainter extends CustomPainter {
  MoleculePainter({
    required this.molecule,
    this.selectedAtomId,
    this.selectedBondId,
    this.draggingAtomId,
    this.dragPosition,
  });

  final Molecule molecule;

  /// Id of the currently selected atom, if any. UI-only state; not part of
  /// the domain model.
  final String? selectedAtomId;

  /// Id of the currently selected bond, if any. UI-only state; not part of
  /// the domain model.
  final String? selectedBondId;

  /// Id of the atom currently being dragged, if any. UI-only state.
  final String? draggingAtomId;

  /// Temporary on-screen position of [draggingAtomId] while dragging.
  final Offset? dragPosition;

  static final Paint _bondPaint = Paint()
    ..color = const Color(0xFF212121)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  /// Perpendicular spacing between parallel lines in double/triple bonds.
  ///
  /// Exposed publicly so [MoleculeCanvas] can reproduce the same parallel
  /// line offsets when hit-testing bonds.
  static const double bondLineSpacing = 3.5;

  static final Paint _selectionPaint = Paint()
    ..color = const Color(0xFF1565C0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static const double _selectionRadius = 15;

  static final Paint _bondSelectionPaint = Paint()
    ..color = const Color(0xFF1565C0)
    ..strokeWidth = 8.0
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBonds(canvas);
    _drawAtoms(canvas);
  }

  void _drawBonds(Canvas canvas) {
    for (final bond in molecule.bonds) {
      _drawBond(canvas, bond);
    }
  }

  void _drawBond(Canvas canvas, Bond bond) {
    final atom1 = molecule.atomById(bond.atom1Id);
    final atom2 = molecule.atomById(bond.atom2Id);
    if (atom1 == null || atom2 == null) {
      return;
    }

    final start = _positionOf(atom1);
    final end = _positionOf(atom2);

    final trimmedStart = _trimLineToLabel(start, end, _labelBounds(atom1));
    final trimmedEnd = _trimLineToLabel(end, start, _labelBounds(atom2));

    if (bond.id == selectedBondId) {
      _drawBondSelectionHighlight(canvas, trimmedStart, trimmedEnd);
    }

    switch (bond.order) {
      case BondOrder.single:
        _drawSingleBond(canvas, trimmedStart, trimmedEnd);
      case BondOrder.double:
        _drawDoubleBond(canvas, trimmedStart, trimmedEnd);
      case BondOrder.triple:
        _drawTripleBond(canvas, trimmedStart, trimmedEnd);
    }
  }

  void _drawSingleBond(Canvas canvas, Offset start, Offset end) {
    canvas.drawLine(start, end, _bondPaint);
  }

  void _drawDoubleBond(Canvas canvas, Offset start, Offset end) {
    final offset = _perpendicularOffset(start, end, bondLineSpacing / 2);
    canvas.drawLine(start + offset, end + offset, _bondPaint);
    canvas.drawLine(start - offset, end - offset, _bondPaint);
  }

  void _drawTripleBond(Canvas canvas, Offset start, Offset end) {
    final offset = _perpendicularOffset(start, end, bondLineSpacing);
    canvas.drawLine(start + offset, end + offset, _bondPaint);
    canvas.drawLine(start, end, _bondPaint);
    canvas.drawLine(start - offset, end - offset, _bondPaint);
  }

  /// Draws a wide, rounded stroke beneath the bond line(s) to indicate that
  /// this bond is selected. Wide enough to halo all parallel lines of a
  /// double or triple bond.
  void _drawBondSelectionHighlight(Canvas canvas, Offset start, Offset end) {
    canvas.drawLine(start, end, _bondSelectionPaint);
  }

  /// Returns an offset vector perpendicular to the line from [start] to
  /// [end], scaled to [spacing].
  Offset _perpendicularOffset(Offset start, Offset end, double spacing) {
    final direction = end - start;
    final distance = direction.distance;
    if (distance == 0) {
      return Offset.zero;
    }

    final unit = direction / distance;
    final perpendicular = Offset(-unit.dy, unit.dx);
    return perpendicular * spacing;
  }

  /// Moves [atomCenter] toward [towards] until it reaches the edge of
  /// [labelBounds], which is assumed to be centered on [atomCenter].
  Offset _trimLineToLabel(Offset atomCenter, Offset towards, Rect labelBounds) {
    final direction = towards - atomCenter;
    if (direction.distance == 0) {
      return atomCenter;
    }

    final halfWidth = labelBounds.width / 2;
    final halfHeight = labelBounds.height / 2;

    final scaleX = direction.dx == 0 ? double.infinity : halfWidth / direction.dx.abs();
    final scaleY = direction.dy == 0 ? double.infinity : halfHeight / direction.dy.abs();
    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.0, 1.0);

    return atomCenter + direction * scale;
  }

  /// Approximate bounding rectangle of the rendered label, centered on the atom.
  Rect _labelBounds(Atom atom) {
    final textPainter = _createTextPainter(atom);
    final center = _positionOf(atom);
    return Rect.fromCenter(
      center: center,
      width: textPainter.width,
      height: textPainter.height,
    );
  }

  void _drawAtoms(Canvas canvas) {
    for (final atom in molecule.atoms) {
      if (atom.id == selectedAtomId) {
        _drawSelectionHighlight(canvas, atom);
      }
      _drawAtomSymbol(canvas, atom);
    }
  }

  void _drawSelectionHighlight(Canvas canvas, Atom atom) {
    final center = _positionOf(atom);
    canvas.drawCircle(center, _selectionRadius, _selectionPaint);
  }

  void _drawAtomSymbol(Canvas canvas, Atom atom) {
    final textPainter = _createTextPainter(atom);
    final center = _positionOf(atom);
    final textOffset = center - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  /// Returns the position at which [atom] should be rendered: the temporary
  /// drag position if [atom] is currently being dragged, otherwise its real
  /// position from the (unmodified) domain model.
  Offset _positionOf(Atom atom) {
    if (atom.id == draggingAtomId && dragPosition != null) {
      return dragPosition!;
    }
    return Offset(atom.position.x, atom.position.y);
  }

  /// Builds and lays out the [TextPainter] for an atom's chemical symbol.
  ///
  /// Shared by both label measurement (for bond trimming) and painting.
  TextPainter _createTextPainter(Atom atom) {
    return TextPainter(
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
  }

  @override
  bool shouldRepaint(covariant MoleculePainter oldDelegate) {
    return oldDelegate.molecule != molecule ||
        oldDelegate.selectedAtomId != selectedAtomId ||
        oldDelegate.selectedBondId != selectedBondId ||
        oldDelegate.draggingAtomId != draggingAtomId ||
        oldDelegate.dragPosition != dragPosition;
  }
}
