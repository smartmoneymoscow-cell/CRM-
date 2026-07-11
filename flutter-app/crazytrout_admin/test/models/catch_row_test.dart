import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/models/catch_row.dart';

void main() {
  group('CatchRow — расчёт веса и суммы', () {
    group('weight (кг + граммы)', () {
      test('1 кг 0 г = 1.000 кг', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 1, grams: 0, pricePerKg: 590);
        expect(row.weight, 1.000);
      });

      test('0 кг 500 г = 0.500 кг', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 0, grams: 500, pricePerKg: 590);
        expect(row.weight, 0.500);
      });

      test('2 кг 750 г = 2.750 кг', () {
        final row = CatchRow(id: 1, species: 'Осётр', kg: 2, grams: 750, pricePerKg: 1890);
        expect(row.weight, closeTo(2.750, 0.001));
      });

      test('0 кг 0 г = 0.000 кг', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 0, grams: 0, pricePerKg: 590);
        expect(row.weight, 0.0);
      });

      test('999 г = 0.999 кг', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 0, grams: 999, pricePerKg: 590);
        expect(row.weight, closeTo(0.999, 0.001));
      });
    });

    group('sum (weight × pricePerKg)', () {
      test('1 кг × 590₽/кг = 590₽', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 1, grams: 0, pricePerKg: 590);
        expect(row.sum, 590);
      });

      test('2.5 кг × 1890₽/кг = 4725₽', () {
        final row = CatchRow(id: 1, species: 'Осётр', kg: 2, grams: 500, pricePerKg: 1890);
        expect(row.sum, closeTo(4725, 0.01));
      });

      test('0.5 кг × 1200₽/кг = 600₽', () {
        final row = CatchRow(id: 1, species: 'Форель', kg: 0, grams: 500, pricePerKg: 1200);
        expect(row.sum, closeTo(600, 0.01));
      });

      test('0 кг 0 г × любая цена = 0₽', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 0, grams: 0, pricePerKg: 1000);
        expect(row.sum, 0);
      });
    });

    group('мутация полей', () {
      test('смена породы обновляет pricePerKg → sum пересчитывается', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 1, grams: 0, pricePerKg: 590);
        row.species = 'Осётр';
        row.pricePerKg = 1890;
        expect(row.sum, 1890);
      });

      test('смена граммов пересчитывает weight и sum', () {
        final row = CatchRow(id: 1, species: 'Карп', kg: 1, grams: 0, pricePerKg: 590);
        row.grams = 500;
        expect(row.weight, closeTo(1.5, 0.001));
        expect(row.sum, closeTo(885, 0.01));
      });
    });
  });
}
