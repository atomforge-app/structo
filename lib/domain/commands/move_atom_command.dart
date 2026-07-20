import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/domain/commands/command.dart';

/// Moves an existing [Atom] to a new position.
final class MoveAtomCommand implements Command {
  MoveAtomCommand({
    required this.atomId,
    required this.fromPosition,
    required this.toPosition,
  });

  final String atomId;
  final Point2D fromPosition;
  final Point2D toPosition;

  @override
  Molecule execute(Molecule molecule) {
    return _moveAtom(molecule, toPosition);
  }

  @override
  Molecule undo(Molecule molecule) {
    return _moveAtom(molecule, fromPosition);
  }

  Molecule _moveAtom(Molecule molecule, Point2D position) {
    final atom = molecule.atomById(atomId);
    if (atom == null) {
      throw StateError('Atom with id "$atomId" does not exist');
    }

    final updatedAtom = atom.copyWith(position: position);
    final updatedAtoms = molecule.atoms
        .map((a) => a.id == atomId ? updatedAtom : a)
        .toList();

    return molecule.copyWith(atoms: updatedAtoms);
  }
}
