/// Supported chemical elements for the molecule editor.
enum ChemicalElement {
  carbon('C', 6, 4),
  hydrogen('H', 1, 1),
  oxygen('O', 8, 2),
  nitrogen('N', 7, 3),
  fluorine('F', 9, 1),
  chlorine('Cl', 17, 1),
  bromine('Br', 35, 1),
  iodine('I', 53, 1),
  phosphorus('P', 15, 3),
  sulfur('S', 16, 2);

  const ChemicalElement(
    this.symbol,
    this.atomicNumber,
    this.defaultValence,
  );

  /// Standard element symbol used for display and serialization.
  final String symbol;

  /// Number of protons in the nucleus.
  final int atomicNumber;

  /// Typical bonding capacity used for valence validation.
  final int defaultValence;
}
