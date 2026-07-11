class CatchRow {
  final int id;
  String species;
  double kg;
  int grams;
  double pricePerKg;

  CatchRow({
    required this.id,
    required this.species,
    this.kg = 1,
    this.grams = 0,
    required this.pricePerKg,
  });

  /// Суммарный вес в кг (кг + граммы/1000) — аналог rowWeight() из веб-версии.
  double get weight => kg + (grams / 1000.0);

  double get sum => weight * pricePerKg;
}
