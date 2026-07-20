import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/domain/commands/command.dart';

/// Deletes an [Atom] and any bonds connected to it.
///
/// Captures the removed atom and bonds when executed, so [undo] can restore
/// them exactly.
final class DeleteAtomCommand implements Command {
  DeleteAtomCommand({required this.atomId});

  final String atomId;

  Atom? _removedAtom;
  List<Bond> _removedBonds = const [];

  @override
  Molecule execute(Molecule molecule) {
    final atom = molecule.atomById(atomId);
    if (atom == null) {
      throw StateError('Atom with id "$atomId" does not exist');
    }

    _removedAtom = atom;
    _removedBonds = molecule.bondsForAtom(atomId).toList();

    return molecule.copyWith(
      atoms: molecule.atoms.where((a) => a.id != atomId).toList(),
      bonds: molecule.bonds.where((b) => !b.connects(atomId)).toList(),
    );
  }

  @override
  Molecule undo(Molecule molecule) {
    final removedAtom = _removedAtom;
    if (removedAtom == null) {
      throw StateError('DeleteAtomCommand has not been executed yet');
    }

    return molecule.copyWith(
      atoms: [...molecule.atoms, removedAtom],
      bonds: [...molecule.bonds, ..._removedBonds],
    );
  }
}
