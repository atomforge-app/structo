import 'package:structo/domain/models/molecule.dart';

/// A reversible edit operation on a [Molecule].
abstract interface class Command {
  /// Returns a new [Molecule] with this command applied.
  Molecule execute(Molecule molecule);

  /// Returns a new [Molecule] with this command reversed.
  Molecule undo(Molecule molecule);
}
