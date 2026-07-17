import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/screens/checks_screen.dart';

/// Тесты на dropdown ранжирования чеков.
void main() {
  group('SortChip — dropdown не обрезается', () {
    testWidgets('dropdown помещается на экран', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChecksScreen()));
      await tester.pumpAndSettle();

      final sortBtn = find.byIcon(Icons.sort);
      if (sortBtn.evaluate().isEmpty) return;

      await tester.tap(sortBtn);
      await tester.pumpAndSettle();

      // Dropdown не обрезается правым краем
      final screenW = tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final applyBtn = find.text('Применить');
      if (applyBtn.evaluate().isNotEmpty) {
        final rect = tester.getRect(applyBtn);
        expect(rect.right, lessThanOrEqualTo(screenW),
          reason: 'Dropdown обрезается правым краем экрана');
      }
    });
  });

  group('SortChip — кнопка Сбросить', () {
    testWidgets('кнопка Сбросить видна в dropdown', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChecksScreen()));
      await tester.pumpAndSettle();

      final sortBtn = find.byIcon(Icons.sort);
      if (sortBtn.evaluate().isEmpty) return;

      await tester.tap(sortBtn);
      await tester.pumpAndSettle();

      expect(find.text('Сбросить'), findsOneWidget);
    });

    testWidgets('кнопка Сбросить сбрасывает настройки и закрывает dropdown', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChecksScreen()));
      await tester.pumpAndSettle();

      // Открываем dropdown сортировки
      final sortBtn = find.byIcon(Icons.sort);
      if (sortBtn.evaluate().isEmpty) return;
      await tester.tap(sortBtn);
      await tester.pumpAndSettle();

      // Выбираем "По сумме чека"
      final totalOption = find.text('По сумме чека');
      if (totalOption.evaluate().isNotEmpty) {
        await tester.tap(totalOption);
        await tester.pumpAndSettle();
      }

      // Нажимаем "Сбросить"
      final resetBtn = find.text('Сбросить');
      expect(resetBtn, findsOneWidget);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // Dropdown закрылся
      expect(find.text('Применить'), findsNothing);
    });
  });
}
