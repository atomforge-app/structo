/// Supported chemical elements for the molecule editor.
enum ChemicalElement {
  carbon('C', 6, 4, 12.011),
  hydrogen('H', 1, 1, 1.008),
  oxygen('O', 8, 2, 15.999),
  nitrogen('N', 7, 3, 14.007),
  fluorine('F', 9, 1, 18.998),
  chlorine('Cl', 17, 1, 35.45),
  bromine('Br', 35, 1, 79.904),
  iodine('I', 53, 1, 126.904),
  phosphorus('P', 15, 3, 30.974),
  sulfur('S', 16, 2, 32.06);

  const ChemicalElement(
    this.symbol,
    this.atomicNumber,
    this.defaultValence,
    this.atomicMass,
  );

  /// Standard element symbol used for display and serialization.
  final String symbol;

  /// Number of protons in the nucleus.
  final int atomicNumber;

  /// Typical bonding capacity used for valence validation.
  final int defaultValence;

  /// Standard atomic mass, in daltons (g/mol), used for molecular weight
  /// calculation.
  final double atomicMass;
}
