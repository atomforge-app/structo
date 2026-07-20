import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/domain/commands/command.dart';

/// Adds a [Bond] between two existing atoms.
final class AddBondCommand implements Command {
  AddBondCommand({required this.bond});

  final Bond bond;

  @override
  Molecule execute(Molecule molecule) {
    _validateBondCanBeAdded(molecule);

    return molecule.copyWith(
      bonds: [...molecule.bonds, bond],
    );
  }

  @override
  Molecule undo(Molecule molecule) {
    if (!_containsBond(molecule, bond.id)) {
      throw StateError('Bond with id "${bond.id}" does not exist');
    }

    return molecule.copyWith(
      bonds: molecule.bonds.where((b) => b.id != bond.id).toList(),
    );
  }

  void _validateBondCanBeAdded(Molecule molecule) {
    if (_containsBond(molecule, bond.id)) {
      throw StateError('Bond with id "${bond.id}" already exists');
    }

    if (!molecule.containsAtom(bond.atom1Id)) {
      throw StateError('Atom with id "${bond.atom1Id}" does not exist');
    }

    if (!molecule.containsAtom(bond.atom2Id)) {
      throw StateError('Atom with id "${bond.atom2Id}" does not exist');
    }

    if (_bondExistsBetween(molecule, bond.atom1Id, bond.atom2Id)) {
      throw StateError(
        'A bond already exists between '
        '"${bond.atom1Id}" and "${bond.atom2Id}"',
      );
    }
  }

  bool _containsBond(Molecule molecule, String bondId) {
    return molecule.bonds.any((b) => b.id == bondId);
  }

  bool _bondExistsBetween(Molecule molecule, String atom1Id, String atom2Id) {
    return molecule.bonds.any(
      (b) =>
          (b.atom1Id == atom1Id && b.atom2Id == atom2Id) ||
          (b.atom1Id == atom2Id && b.atom2Id == atom1Id),
    );
  }
}
