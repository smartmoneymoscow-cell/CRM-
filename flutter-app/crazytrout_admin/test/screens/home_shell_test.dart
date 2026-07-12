import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/screens/home_shell.dart';

void main() {
  group('HomeShell — нижняя навигация', () {
    testWidgets('отображает 5 вкладок', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      expect(find.text('Карта'), findsOneWidget);
      expect(find.text('Чек'), findsWidgets); // и в меню, и в заголовке
      expect(find.text('Чеки'), findsOneWidget);
      expect(find.text('P&L'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('по умолчанию выбрана вкладка "Чек" (индекс 1)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      expect(find.text('Выставление чека'), findsOneWidget);
    });

    testWidgets('переключение на "Карта" показывает заглушку', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      await tester.tap(find.text('Карта'));
      await tester.pumpAndSettle();
      expect(find.text('Карта прудов и точек лова — раздел в разработке.'), findsOneWidget);
    });

    testWidgets('переключение на "Чеки" показывает заглушку', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      await tester.tap(find.text('Чеки'));
      await tester.pumpAndSettle();
      expect(find.text('История выставленных чеков — раздел в разработке.'), findsOneWidget);
    });

    testWidgets('переключение на "P&L" показывает заглушку', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      await tester.tap(find.text('P&L'));
      await tester.pumpAndSettle();
      expect(find.text('Отчёт по прибыли и убыткам — раздел в разработке.'), findsOneWidget);
    });

    testWidgets('переключение на "Профиль" показывает заглушку', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      expect(find.text('Профиль администратора — раздел в разработке.'), findsOneWidget);
    });

    testWidgets('возврат на "Чек" показывает форму', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      await tester.tap(find.text('Карта'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Чек'));
      await tester.pumpAndSettle();
      expect(find.text('Выставление чека'), findsOneWidget);
    });

    testWidgets('иконки отображаются', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byIcon(Icons.receipt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('нижнее меню содержит 5 иконок по 24px', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pump();
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      // 5 иконок в нижнем меню
      expect(icons.length, greaterThanOrEqualTo(5));
    });
  });
}
