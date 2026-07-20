/// Bond order between two atoms.
enum BondOrder {
  single(1),
  double(2),
  triple(3);

  const BondOrder(this.value);

  /// Number of electron pairs in the bond.
  final int value;
}

/// A bond connecting two atoms in a molecule graph.
final class Bond {
  const Bond({
    required this.id,
    required this.atom1Id,
    required this.atom2Id,
    required this.order,
  }) : assert(atom1Id != atom2Id, 'A bond must connect two distinct atoms');

  final String id;
  final String atom1Id;
  final String atom2Id;
  final BondOrder order;

  Bond copyWith({
    String? id,
    String? atom1Id,
    String? atom2Id,
    BondOrder? order,
  }) {
    return Bond(
      id: id ?? this.id,
      atom1Id: atom1Id ?? this.atom1Id,
      atom2Id: atom2Id ?? this.atom2Id,
      order: order ?? this.order,
    );
  }

  /// Returns the id of the atom at the opposite end of this bond.
  String otherAtomId(String atomId) {
    if (atomId == atom1Id) {
      return atom2Id;
    }
    if (atomId == atom2Id) {
      return atom1Id;
    }
    throw ArgumentError.value(atomId, 'atomId', 'Atom is not part of this bond');
  }

  /// Whether this bond connects the given atom.
  bool connects(String atomId) => atomId == atom1Id || atomId == atom2Id;

  @override
  bool operator ==(Object other) {
    return other is Bond &&
        other.id == id &&
        other.atom1Id == atom1Id &&
        other.atom2Id == atom2Id &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(id, atom1Id, atom2Id, order);

  @override
  String toString() {
    return 'Bond(id: $id, atom1Id: $atom1Id, atom2Id: $atom2Id, order: $order)';
  }
}
