import 'package:flutter/material.dart';
import 'package:structo/domain/commands/add_atom_command.dart';
import 'package:structo/domain/commands/add_bond_command.dart';
import 'package:structo/domain/commands/command_history.dart';
import 'package:structo/domain/commands/delete_atom_command.dart';
import 'package:structo/domain/commands/delete_bond_command.dart';
import 'package:structo/domain/commands/move_atom_command.dart';
import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/element.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/features/editor/widgets/molecule_canvas.dart';
import 'package:structo/services/molecule_storage_service.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final CommandHistory _commandHistory = CommandHistory(
    initial: Molecule.empty(),
  );
  final MoleculeStorageService _storageService = MoleculeStorageService();

  int _nextAtomId = 0;
  int _nextBondId = 0;

  ChemicalElement _selectedElement = ChemicalElement.carbon;
  BondOrder _selectedBondOrder = BondOrder.single;

  void _handleElementSelected(ChemicalElement element) {
    setState(() {
      _selectedElement = element;
    });
  }

  void _handleBondOrderSelected(BondOrder order) {
    setState(() {
      _selectedBondOrder = order;
    });
  }

  String _bondOrderSymbol(BondOrder order) {
    switch (order) {
      case BondOrder.single:
        return '—';
      case BondOrder.double:
        return '=';
      case BondOrder.triple:
        return '≡';
    }
  }

  void _handleAtomMoved(String atomId, Point2D fromPosition, Point2D toPosition) {
    setState(() {
      _commandHistory.execute(
        MoveAtomCommand(
          atomId: atomId,
          fromPosition: fromPosition,
          toPosition: toPosition,
        ),
      );
    });
  }

  String _handleEmptySpaceTapped(Point2D position) {
    final atom = Atom(
      id: 'atom_${_nextAtomId++}',
      element: _selectedElement,
      position: position,
    );

    setState(() {
      _commandHistory.execute(AddAtomCommand(atom: atom));
    });

    return atom.id;
  }

  void _handleAtomsSelectedForBond(String firstAtomId, String secondAtomId) {
    final molecule = _commandHistory.current;
    if (molecule.hasBondBetween(firstAtomId, secondAtomId)) {
      return;
    }

    final bond = Bond(
      id: 'bond_${_nextBondId++}',
      atom1Id: firstAtomId,
      atom2Id: secondAtomId,
      order: _selectedBondOrder,
    );

    setState(() {
      _commandHistory.execute(AddBondCommand(bond: bond));
    });
  }

  void _handleAtomLongPressed(String atomId) {
    setState(() {
      _commandHistory.execute(DeleteAtomCommand(atomId: atomId));
    });
  }

  void _handleBondLongPressed(String bondId) {
    setState(() {
      _commandHistory.execute(DeleteBondCommand(bondId: bondId));
    });
  }

  void _handleUndo() {
    setState(() {
      _commandHistory.undo();
    });
  }

  void _handleRedo() {
    setState(() {
      _commandHistory.redo();
    });
  }

  Future<void> _handleSave() async {
    try {
      await _storageService.save(_commandHistory.current);
      _showMessage('Molecule saved.');
    } catch (error) {
      _showMessage('Failed to save molecule: $error');
    }
  }

  Future<void> _handleLoad() async {
    try {
      final loaded = await _storageService.load();
      if (loaded == null) {
        _showMessage('No saved molecule found.');
        return;
      }

      setState(() {
        _commandHistory.reset(loaded);
        _resyncIdCountersWith(loaded);
      });
      _showMessage('Molecule loaded.');
    } catch (error) {
      _showMessage('Failed to load molecule: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Advances [_nextAtomId]/[_nextBondId] past any numeric suffix found in
  /// [molecule]'s atom/bond ids, so newly created ids after a load never
  /// collide with ids restored from a file.
  void _resyncIdCountersWith(Molecule molecule) {
    _nextAtomId = _nextIdSuffix(
      molecule.atoms.map((atom) => atom.id),
      _nextAtomId,
    );
    _nextBondId = _nextIdSuffix(
      molecule.bonds.map((bond) => bond.id),
      _nextBondId,
    );
  }

  int _nextIdSuffix(Iterable<String> ids, int current) {
    var next = current;
    for (final id in ids) {
      final match = RegExp(r'_(\d+)$').firstMatch(id);
      if (match == null) {
        continue;
      }
      final suffix = int.tryParse(match.group(1)!);
      if (suffix != null && suffix + 1 > next) {
        next = suffix + 1;
      }
    }
    return next;
  }

  Widget _buildMoleculeInfoBar(BuildContext context, Molecule molecule) {
    final formula = molecule.molecularFormula();
    final formulaLabel = formula.isEmpty ? '—' : formula;
    final weightLabel = molecule.atoms.isEmpty
        ? '—'
        : molecule.molecularWeight().toStringAsFixed(2);

    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Formula: $formulaLabel    Molecular weight: $weightLabel',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final molecule = _commandHistory.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Structo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save molecule',
            onPressed: _handleSave,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load molecule',
            onPressed: _handleLoad,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _commandHistory.canUndo ? _handleUndo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _commandHistory.canRedo ? _handleRedo : null,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMoleculeInfoBar(context, molecule),
          Expanded(
            child: MoleculeCanvas(
              molecule: molecule,
              onAtomMoved: _handleAtomMoved,
              onEmptySpaceTapped: _handleEmptySpaceTapped,
              onAtomsSelectedForBond: _handleAtomsSelectedForBond,
              onAtomLongPressed: _handleAtomLongPressed,
              onBondLongPressed: _handleBondLongPressed,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 136,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final element in ChemicalElement.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(element.symbol),
                        selected: element == _selectedElement,
                        onSelected: (_) => _handleElementSelected(element),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final order in BondOrder.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_bondOrderSymbol(order)),
                        selected: order == _selectedBondOrder,
                        onSelected: (_) => _handleBondOrderSelected(order),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
