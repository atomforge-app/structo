import 'package:flutter/material.dart';
import 'package:structo/domain/models/atom.dart';
import 'package:structo/domain/models/bond.dart';
import 'package:structo/domain/models/element.dart';
import 'package:structo/domain/models/molecule.dart';
import 'package:structo/features/editor/widgets/molecule_canvas.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  static final Molecule _previewMolecule = Molecule(
    atoms: [
      Atom(
        id: 'c1',
        element: ChemicalElement.carbon,
        position: Point2D(x: 120, y: 200),
      ),
      Atom(
        id: 'c2',
        element: ChemicalElement.carbon,
        position: Point2D(x: 220, y: 200),
      ),
      Atom(
        id: 'o1',
        element: ChemicalElement.oxygen,
        position: Point2D(x: 320, y: 200),
      ),
      Atom(
        id: 'h1',
        element: ChemicalElement.hydrogen,
        position: Point2D(x: 70, y: 150),
      ),
      Atom(
        id: 'h2',
        element: ChemicalElement.hydrogen,
        position: Point2D(x: 370, y: 150),
      ),
    ],
    bonds: [
      Bond(
        id: 'b1',
        atom1Id: 'c1',
        atom2Id: 'c2',
        order: BondOrder.single,
      ),
      Bond(
        id: 'b2',
        atom1Id: 'c2',
        atom2Id: 'o1',
        order: BondOrder.single,
      ),
      Bond(
        id: 'b3',
        atom1Id: 'c1',
        atom2Id: 'h1',
        order: BondOrder.single,
      ),
      Bond(
        id: 'b4',
        atom1Id: 'o1',
        atom2Id: 'h2',
        order: BondOrder.single,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Structo'),
      ),
      body: MoleculeCanvas(molecule: _previewMolecule),
    );
  }
}
