import 'package:structo/domain/models/element.dart';

/// A two-dimensional point in canvas coordinates.
final class Point2D {
  const Point2D({required this.x, required this.y});

  final double x;
  final double y;

  Point2D copyWith({double? x, double? y}) {
    return Point2D(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Point2D && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point2D($x, $y)';
}

/// An atom in a molecule graph.
final class Atom {
  const Atom({
    required this.id,
    required this.element,
    required this.position,
    this.formalCharge = 0,
  });

  final String id;
  final ChemicalElement element;
  final Point2D position;

  /// Formal charge on the atom. Zero for neutral atoms.
  final int formalCharge;

  Atom copyWith({
    String? id,
    ChemicalElement? element,
    Point2D? position,
    int? formalCharge,
  }) {
    return Atom(
      id: id ?? this.id,
      element: element ?? this.element,
      position: position ?? this.position,
      formalCharge: formalCharge ?? this.formalCharge,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Atom &&
        other.id == id &&
        other.element == element &&
        other.position == position &&
        other.formalCharge == formalCharge;
  }

  @override
  int get hashCode => Object.hash(id, element, position, formalCharge);

  @override
  String toString() {
    return 'Atom(id: $id, element: ${element.symbol}, '
        'position: $position, formalCharge: $formalCharge)';
  }
}
