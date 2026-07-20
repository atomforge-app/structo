import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/element.dart';

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

  /// An empty molecule with no atoms or bonds.
  factory Molecule.empty() => Molecule(atoms: [], bonds: []);

  /// Converts this molecule to a JSON-compatible map, containing only its
  /// atoms and bonds.
  Map<String, dynamic> toJson() {
    return {
      'atoms': atoms.map((atom) => atom.toJson()).toList(),
      'bonds': bonds.map((bond) => bond.toJson()).toList(),
    };
  }

  /// Restores a [Molecule] from a map produced by [toJson].
  factory Molecule.fromJson(Map<String, dynamic> json) {
    final atomsJson = json['atoms'] as List<dynamic>? ?? const [];
    final bondsJson = json['bonds'] as List<dynamic>? ?? const [];

    return Molecule(
      atoms: atomsJson
          .map((atomJson) => Atom.fromJson(atomJson as Map<String, dynamic>))
          .toList(),
      bonds: bondsJson
          .map((bondJson) => Bond.fromJson(bondJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns the atom with [id], or null if it does not exist.
  Atom? atomById(String id) => _atomsById[id];

  /// Returns the bond with [id], or null if it does not exist.
  Bond? bondById(String id) {
    for (final bond in bonds) {
      if (bond.id == id) {
        return bond;
      }
    }
    return null;
  }

  /// Returns all bonds connected to the atom with [atomId].
  Iterable<Bond> bondsForAtom(String atomId) {
    return bonds.where((bond) => bond.connects(atomId));
  }

  /// Whether a bond already exists between [atom1Id] and [atom2Id], in
  /// either direction.
  bool hasBondBetween(String atom1Id, String atom2Id) {
    return bonds.any(
      (bond) =>
          (bond.atom1Id == atom1Id && bond.atom2Id == atom2Id) ||
          (bond.atom1Id == atom2Id && bond.atom2Id == atom1Id),
    );
  }

  /// Whether the molecule contains an atom with [id].
  bool containsAtom(String id) => _atomsById.containsKey(id);

  /// Returns the molecular formula, using Hill system ordering: carbon
  /// first, hydrogen second (only when carbon is present), then all
  /// remaining elements alphabetically by symbol. Elements without carbon
  /// are ordered fully alphabetically, including hydrogen.
  ///
  /// Returns an empty string for a molecule with no atoms. Not cached; the
  /// formula is always recomputed from the current atoms.
  String molecularFormula() {
    if (atoms.isEmpty) {
      return '';
    }

    final counts = <ChemicalElement, int>{};
    for (final atom in atoms) {
      counts[atom.element] = (counts[atom.element] ?? 0) + 1;
    }

    final buffer = StringBuffer();
    for (final element in _hillOrder(counts.keys.toSet())) {
      final count = counts[element]!;
      buffer.write(element.symbol);
      if (count > 1) {
        buffer.write(count);
      }
    }

    return buffer.toString();
  }

  /// Returns the molecular weight as the sum of the atomic masses of every
  /// atom currently in the molecule. Not cached; always recomputed from the
  /// current atoms.
  double molecularWeight() {
    var totalMass = 0.0;
    for (final atom in atoms) {
      totalMass += atom.element.atomicMass;
    }
    return totalMass;
  }

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

/// Orders [elements] using Hill system conventions: carbon first, hydrogen
/// second (only when carbon is present), then all remaining elements
/// alphabetically by symbol.
List<ChemicalElement> _hillOrder(Set<ChemicalElement> elements) {
  final hasCarbon = elements.contains(ChemicalElement.carbon);

  final remaining = elements
      .where(
        (element) =>
            element != ChemicalElement.carbon &&
            !(hasCarbon && element == ChemicalElement.hydrogen),
      )
      .toList()
    ..sort((a, b) => a.symbol.compareTo(b.symbol));

  return [
    if (hasCarbon) ChemicalElement.carbon,
    if (hasCarbon && elements.contains(ChemicalElement.hydrogen))
      ChemicalElement.hydrogen,
    ...remaining,
  ];
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
