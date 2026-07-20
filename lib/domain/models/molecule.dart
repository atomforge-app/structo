import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';

/// A molecule represented as an atom-bond graph.
final class Molecule {
  Molecule({
    required List<Atom> atoms,
    required List<Bond> bonds,
  })  : atoms = List.unmodifiable(atoms),
        bonds = List.unmodifiable(bonds),
        _atomsById = {for (final atom in atoms) atom.id: atom};

  final List<Atom> atoms;
  final List<Bond> bonds;

  final Map<String, Atom> _atomsById;

  /// Returns the atom with [id], or null if it does not exist.
  Atom? atomById(String id) => _atomsById[id];

  /// Returns all bonds connected to the atom with [atomId].
  Iterable<Bond> bondsForAtom(String atomId) {
    return bonds.where((bond) => bond.connects(atomId));
  }

  /// Whether the molecule contains an atom with [id].
  bool containsAtom(String id) => _atomsById.containsKey(id);

  Molecule copyWith({
    List<Atom>? atoms,
    List<Bond>? bonds,
  }) {
    return Molecule(
      atoms: atoms ?? this.atoms,
      bonds: bonds ?? this.bonds,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Molecule &&
        _listEquals(other.atoms, atoms) &&
        _listEquals(other.bonds, bonds);
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(atoms), Object.hashAll(bonds));

  @override
  String toString() {
    return 'Molecule(atoms: ${atoms.length}, bonds: ${bonds.length})';
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
