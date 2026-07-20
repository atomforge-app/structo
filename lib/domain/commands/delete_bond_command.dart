import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/domain/commands/command.dart';

/// Deletes a [Bond] without affecting atoms or any other bond.
///
/// Captures the removed bond when executed, so [undo] can restore it
/// exactly.
final class DeleteBondCommand implements Command {
  DeleteBondCommand({required this.bondId});

  final String bondId;

  Bond? _removedBond;

  @override
  Molecule execute(Molecule molecule) {
    final bond = molecule.bondById(bondId);
    if (bond == null) {
      throw StateError('Bond with id "$bondId" does not exist');
    }

    _removedBond = bond;

    return molecule.copyWith(
      bonds: molecule.bonds.where((b) => b.id != bondId).toList(),
    );
  }

  @override
  Molecule undo(Molecule molecule) {
    final removedBond = _removedBond;
    if (removedBond == null) {
      throw StateError('DeleteBondCommand has not been executed yet');
    }

    return molecule.copyWith(
      bonds: [...molecule.bonds, removedBond],
    );
  }
}
