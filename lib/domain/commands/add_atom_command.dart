import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/domain/commands/command.dart';

/// Adds an [Atom] to a [Molecule].
final class AddAtomCommand implements Command {
  AddAtomCommand({required this.atom});

  final Atom atom;

  @override
  Molecule execute(Molecule molecule) {
    if (molecule.containsAtom(atom.id)) {
      throw StateError('Atom with id "${atom.id}" already exists');
    }

    return molecule.copyWith(
      atoms: [...molecule.atoms, atom],
    );
  }

  @override
  Molecule undo(Molecule molecule) {
    if (!molecule.containsAtom(atom.id)) {
      throw StateError('Atom with id "${atom.id}" does not exist');
    }

    return molecule.copyWith(
      atoms: molecule.atoms.where((a) => a.id != atom.id).toList(),
    );
  }
}
