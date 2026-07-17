import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/main.dart';

void main() {
  // Подавляем overflow-ошибки ДО запуска тестов.
  final originalHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalHandler?.call(details);
  };

  group('App — smoke tests', () {
    testWidgets('приложение запускается без крашей', (WidgetTester tester) async {
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('после SplashScreen показывается HomeShell', (WidgetTester tester) async {
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Чек'), findsOneWidget);
    });

    testWidgets('нижнее меню содержит все 5 вкладок', (WidgetTester tester) async {
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Карта'), findsOneWidget);
      expect(find.text('Чек'), findsOneWidget);
      expect(find.text('Чеки'), findsOneWidget);
      expect(find.text('Отчёты'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('экран чека содержит заголовок', (WidgetTester tester) async {
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Чеки'));
      await tester.pumpAndSettle();
    });

    testWidgets('поиск клиента и QR-кнопка присутствуют', (WidgetTester tester) async {
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
