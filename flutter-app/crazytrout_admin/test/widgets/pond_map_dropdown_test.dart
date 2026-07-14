import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/screens/pond_map_filter_config.dart';
import 'package:crazytrout_admin/screens/pond_map_screen.dart';

/// Widget-тесты на FiltersDropdown.
///
/// Проверяют визуальное поведение: открытие, закрытие, позиционирование.
void main() {
  group('FiltersDropdown', () {
    Widget buildApp({
      FilterValue value = FilterValue.none,
      ValueChanged<FilterValue>? onChange,
      double screenHeight = 800,
    }) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Чеки'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'P&L'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
          ),
          body: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FiltersDropdown(
                  value: value,
                  onChange: onChange ?? (_) {},
                ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('кнопка отображает "Фильтры" по умолчанию', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Фильтры'), findsOneWidget);
    });

    testWidgets('кнопка отображает "Все" при FilterValue.all', (tester) async {
      await tester.pumpWidget(buildApp(value: FilterValue.all));
      expect(find.text('Все'), findsOneWidget);
    });

    testWidgets('тап по кнопке открывает dropdown', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Должны появиться все варианты
      expect(find.text('Нет'), findsOneWidget);
      expect(find.text('Все клиенты'), findsOneWidget);
      expect(find.text('Премиум'), findsOneWidget);
      expect(find.text('Стандарт'), findsOneWidget);
      expect(find.text('Базовый'), findsOneWidget);
    });

    testWidgets('выбор варианта вызывает onChange', (tester) async {
      FilterValue? selected;
      await tester.pumpWidget(buildApp(onChange: (v) => selected = v));
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Премиум'));
      await tester.pumpAndSettle();

      expect(selected, FilterValue.premium);
    });

    testWidgets('dropdown закрывается после выбора', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Стандарт'));
      await tester.pumpAndSettle();

      // Dropdown закрылся — варианты не видны
      expect(find.text('Нет'), findsNothing);
      expect(find.text('Все клиенты'), findsNothing);
    });

    testWidgets('тап вне dropdown закрывает его', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Тапаем в пустую область
      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      expect(find.text('Нет'), findsNothing);
    });
  });
}
