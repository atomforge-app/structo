import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:structo/domain/models/molecule.dart';

/// Persists a [Molecule] to and from a JSON file in local app storage.
///
/// This is a minimal, single-slot implementation: every [save] overwrites
/// the same file, and [load] always reads that same file. Multi-document
/// support, file pickers, and cloud storage are out of scope for now.
final class MoleculeStorageService {
  static const String _fileName = 'structo_molecule.json';

  /// Serializes [molecule] to JSON and writes it to local app storage.
  Future<void> save(Molecule molecule) async {
    final file = await _resolveFile();
    final json = jsonEncode(molecule.toJson());
    await file.writeAsString(json);
  }

  /// Reads the previously saved molecule from local app storage.
  ///
  /// Returns null if no saved file exists yet.
  Future<Molecule?> load() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      return null;
    }

    final contents = await file.readAsString();
    final json = jsonDecode(contents) as Map<String, dynamic>;
    return Molecule.fromJson(json);
  }

  Future<File> _resolveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
