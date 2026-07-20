import 'package:flutter/material.dart';
import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/features/editor/painters/molecule_painter.dart';

/// Called when a completed drag moves an atom from [fromPosition] to
/// [toPosition].
typedef AtomMoveCallback = void Function(
  String atomId,
  Point2D fromPosition,
  Point2D toPosition,
);

/// Called when the user taps empty canvas space at [position]. The caller is
/// expected to create the new atom through the Command Pattern and return
/// its id so it can become selected.
typedef EmptySpaceTappedCallback = String Function(Point2D position);

/// Called when the user taps [secondAtomId] while [firstAtomId] was already
/// selected, requesting a bond between them.
typedef AtomsSelectedForBondCallback = void Function(
  String firstAtomId,
  String secondAtomId,
);

/// Called when the user long-presses the atom identified by [atomId],
/// requesting its deletion.
typedef AtomLongPressedCallback = void Function(String atomId);

/// Called when the user long-presses the bond identified by [bondId],
/// requesting its deletion.
typedef BondLongPressedCallback = void Function(String bondId);

/// Displays a [Molecule] on a canvas and lets the user select and drag an
/// atom, or create a new one by tapping empty space.
///
/// This widget never mutates [molecule]. When a drag ends with a real
/// position change, it reports the move via [onAtomMoved]; when empty space
/// is tapped, it reports the position via [onEmptySpaceTapped]. Either way,
/// the caller applies the change through the Command Pattern.
class MoleculeCanvas extends StatefulWidget {
  const MoleculeCanvas({
    super.key,
    required this.molecule,
    this.onAtomMoved,
    this.onEmptySpaceTapped,
    this.onAtomsSelectedForBond,
    this.onAtomLongPressed,
    this.onBondLongPressed,
  });

  final Molecule molecule;

  /// Called when a drag ends and the atom's position actually changed.
  final AtomMoveCallback? onAtomMoved;

  /// Called when the user taps canvas space with no atom underneath.
  final EmptySpaceTappedCallback? onEmptySpaceTapped;

  /// Called when the user taps a second, different atom while one was
  /// already selected.
  final AtomsSelectedForBondCallback? onAtomsSelectedForBond;

  /// Called when the user long-presses an existing atom, requesting deletion.
  final AtomLongPressedCallback? onAtomLongPressed;

  /// Called when the user long-presses an existing bond, requesting deletion.
  final BondLongPressedCallback? onBondLongPressed;

  @override
  State<MoleculeCanvas> createState() => _MoleculeCanvasState();
}

class _MoleculeCanvasState extends State<MoleculeCanvas> {
  static const double _hitTestRadius = 20;
  static const double _bondHitTestRadius = 12;

  String? _selectedAtomId;
  String? _selectedBondId;
  String? _draggingAtomId;
  Point2D? _dragStartPosition;
  Offset? _dragPosition;

  /// The atom selected before the current gesture began, captured so a
  /// plain tap on a second atom can be reported as a bond request.
  String? _pendingBondSourceAtomId;

  void _handlePanStart(DragStartDetails details) {
    final atomId = _hitTestAtom(details.localPosition);

    if (atomId != null) {
      _pendingBondSourceAtomId = _selectedAtomId;

      setState(() {
        _selectedAtomId = atomId;
        _selectedBondId = null;
        _draggingAtomId = atomId;
        _dragStartPosition = widget.molecule.atomById(atomId)?.position;
        _dragPosition = details.localPosition;
      });
      return;
    }

    final bondId = _hitTestBond(details.localPosition);
    if (bondId != null) {
      setState(() {
        _selectedAtomId = null;
        _selectedBondId = bondId;
        _draggingAtomId = null;
        _dragStartPosition = null;
        _dragPosition = null;
      });
      return;
    }

    final tapPosition = Point2D(
      x: details.localPosition.dx,
      y: details.localPosition.dy,
    );
    final newAtomId = widget.onEmptySpaceTapped?.call(tapPosition);
    setState(() {
      _selectedAtomId = newAtomId;
      _selectedBondId = null;
      _draggingAtomId = null;
      _dragStartPosition = null;
      _dragPosition = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_draggingAtomId == null) {
      return;
    }
    setState(() {
      _dragPosition = details.localPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final atomId = _draggingAtomId;
    final fromPosition = _dragStartPosition;
    final finalPosition = _dragPosition;
    final bondSourceAtomId = _pendingBondSourceAtomId;
    _pendingBondSourceAtomId = null;

    setState(() {
      _draggingAtomId = null;
      _dragStartPosition = null;
      _dragPosition = null;
    });

    if (atomId == null || fromPosition == null || finalPosition == null) {
      return;
    }

    final toPosition = Point2D(x: finalPosition.dx, y: finalPosition.dy);
    if (toPosition != fromPosition) {
      widget.onAtomMoved?.call(atomId, fromPosition, toPosition);
      return;
    }

    if (bondSourceAtomId != null && bondSourceAtomId != atomId) {
      widget.onAtomsSelectedForBond?.call(bondSourceAtomId, atomId);
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    final atomId = _hitTestAtom(details.localPosition);
    if (atomId != null) {
      setState(() {
        if (_selectedAtomId == atomId) {
          _selectedAtomId = null;
        }
        if (_draggingAtomId == atomId) {
          _draggingAtomId = null;
          _dragStartPosition = null;
          _dragPosition = null;
        }
      });

      widget.onAtomLongPressed?.call(atomId);
      return;
    }

    final bondId = _hitTestBond(details.localPosition);
    if (bondId == null) {
      return;
    }

    setState(() {
      if (_selectedBondId == bondId) {
        _selectedBondId = null;
      }
    });

    widget.onBondLongPressed?.call(bondId);
  }

  /// Returns the id of the nearest atom within [_hitTestRadius] of
  /// [position], or null if no atom is close enough.
  String? _hitTestAtom(Offset position) {
    String? nearestAtomId;
    var nearestDistance = double.infinity;

    for (final atom in widget.molecule.atoms) {
      final atomPosition = Offset(atom.position.x, atom.position.y);
      final distance = (position - atomPosition).distance;
      if (distance <= _hitTestRadius && distance < nearestDistance) {
        nearestDistance = distance;
        nearestAtomId = atom.id;
      }
    }

    return nearestAtomId;
  }

  /// Returns the id of the nearest bond within [_bondHitTestRadius] of
  /// [position], or null if no bond is close enough. Considers every
  /// parallel line rendered for double/triple bonds.
  String? _hitTestBond(Offset position) {
    String? nearestBondId;
    var nearestDistance = double.infinity;

    for (final bond in widget.molecule.bonds) {
      final atom1 = widget.molecule.atomById(bond.atom1Id);
      final atom2 = widget.molecule.atomById(bond.atom2Id);
      if (atom1 == null || atom2 == null) {
        continue;
      }

      final start = Offset(atom1.position.x, atom1.position.y);
      final end = Offset(atom2.position.x, atom2.position.y);
      final distance = _distanceToBondLines(position, start, end, bond.order);

      if (distance <= _bondHitTestRadius && distance < nearestDistance) {
        nearestDistance = distance;
        nearestBondId = bond.id;
      }
    }

    return nearestBondId;
  }

  /// Returns the shortest distance from [position] to any of the parallel
  /// lines that would be rendered for a bond of [order] between [start] and
  /// [end]. Mirrors the offsets used by [MoleculePainter].
  double _distanceToBondLines(
    Offset position,
    Offset start,
    Offset end,
    BondOrder order,
  ) {
    switch (order) {
      case BondOrder.single:
        return _distanceToSegment(position, start, end);
      case BondOrder.double:
        final offset = _perpendicularOffset(
          start,
          end,
          MoleculePainter.bondLineSpacing / 2,
        );
        return _minOf([
          _distanceToSegment(position, start + offset, end + offset),
          _distanceToSegment(position, start - offset, end - offset),
        ]);
      case BondOrder.triple:
        final offset = _perpendicularOffset(
          start,
          end,
          MoleculePainter.bondLineSpacing,
        );
        return _minOf([
          _distanceToSegment(position, start + offset, end + offset),
          _distanceToSegment(position, start, end),
          _distanceToSegment(position, start - offset, end - offset),
        ]);
    }
  }

  /// Returns the shortest distance from [point] to the line segment between
  /// [start] and [end].
  double _distanceToSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;
    final lengthSquared = segment.dx * segment.dx + segment.dy * segment.dy;
    if (lengthSquared == 0) {
      return (point - start).distance;
    }

    final toPoint = point - start;
    final t = (toPoint.dx * segment.dx + toPoint.dy * segment.dy) / lengthSquared;
    final clampedT = t.clamp(0.0, 1.0);
    final closestPoint = start + segment * clampedT;
    return (point - closestPoint).distance;
  }

  /// Returns an offset vector perpendicular to the line from [start] to
  /// [end], scaled to [spacing]. Mirrors [MoleculePainter]'s geometry so
  /// hit testing matches what is actually rendered.
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

  double _minOf(List<double> values) => values.reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onLongPressStart: _handleLongPressStart,
      child: CustomPaint(
        painter: MoleculePainter(
          molecule: widget.molecule,
          selectedAtomId: _selectedAtomId,
          selectedBondId: _selectedBondId,
          draggingAtomId: _draggingAtomId,
          dragPosition: _dragPosition,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
