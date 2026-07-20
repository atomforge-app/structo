import 'package:structo/domain/models/molecule.dart';
import 'package:structo/domain/commands/command.dart';

/// Manages undo and redo stacks for [Command] execution.
final class CommandHistory {
  CommandHistory({required Molecule initial}) : _current = initial;

  Molecule _current;
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  /// The current molecule state.
  Molecule get current => _current;

  /// Whether an undo operation is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether a redo operation is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Applies [command] to [current], pushes it onto the undo stack, and clears redo.
  Molecule execute(Command command) {
    _current = command.execute(_current);
    _undoStack.add(command);
    _redoStack.clear();
    return _current;
  }

  /// Reverses the most recent command, if any.
  Molecule? undo() {
    if (_undoStack.isEmpty) {
      return null;
    }

    final command = _undoStack.removeLast();
    _current = command.undo(_current);
    _redoStack.add(command);
    return _current;
  }

  /// Re-applies the most recently undone command, if any.
  Molecule? redo() {
    if (_redoStack.isEmpty) {
      return null;
    }

    final command = _redoStack.removeLast();
    _current = command.execute(_current);
    _undoStack.add(command);
    return _current;
  }

  /// Replaces the current molecule and clears the undo/redo history.
  ///
  /// Intended for loading a document: the loaded molecule becomes the new
  /// baseline, and there is nothing meaningful left to undo/redo back to.
  void reset(Molecule molecule) {
    _current = molecule;
    _undoStack.clear();
    _redoStack.clear();
  }
}
