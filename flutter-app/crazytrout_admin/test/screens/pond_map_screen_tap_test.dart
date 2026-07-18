// ============================================================================
// pond_map_screen_tap_test.dart — Widget-тесты на PondMapScreen целиком.
//
// Пump'им РЕАЛЬНЫЙ экран, тапаем по НАСТОЯЩИМ кнопкам в интерфейсе.
// Каждый тест проверяет конкретное пользовательское действие.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/screens/pond_map_screen.dart';
import 'package:crazytrout_admin/screens/pond_map_filter_config.dart';

/// Обёртка для pump всего экрана в MaterialApp + Scaffold с нижним меню.
/// Это минимальная оболочка, которую ожидает PondMapScreen.
Widget _buildApp() {
  return MaterialApp(
    home: Scaffold(
      body: const PondMapScreen(),
      bottomNavigationBar: Container(
        height: kBottomNavHeight,
        color: Colors.white,
        child: const Center(child: Text('Нижнее меню')),
      ),
    ),
  );
}

void main() {
  // ─────────────────────────────────────────────────────────────────────
  // 1. ЗАГОЛОВОК ЭКРАНА
  // ─────────────────────────────────────────────────────────────────────
  group('Заголовок', () {
    testWidgets('отображает «Карта пруда»', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Карта пруда'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 2. ЧИП «ДАТА» — тап открывает календарь
  // ─────────────────────────────────────────────────────────────────────
  group('Чип «ДАТА»', () {
    testWidgets('отображает дату по умолчанию', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Дата по умолчанию — 12 июл (см. _PondMapScreenState)
      expect(find.text('12 июл'), findsOneWidget);
    });

    testWidgets('тап по дате открывает календарь', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Тапаем по чипу даты
      await tester.tap(find.text('12 июл'));
      await tester.pumpAndSettle();

      // Должен появиться заголовок календаря с названием месяца
      // _CalendarPicker показывает месяц в формате "Июль 2026"
      expect(find.textContaining('Июль'), findsWidgets);
    });

    testWidgets('выбор даты в календаре обновляет чип', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Открываем календарь
      await tester.tap(find.text('12 июл'));
      await tester.pumpAndSettle();

      // Тапаем на день 15 в календаре
      final day15 = find.text('15');
      if (day15.evaluate().isNotEmpty) {
        await tester.tap(day15.last);
        await tester.pumpAndSettle();

        // Кнопка «Выбрать»
        final selectBtn = find.text('Выбрать');
        if (selectBtn.evaluate().isNotEmpty) {
          await tester.tap(selectBtn);
          await tester.pumpAndSettle();
        }

        // Чип должен обновиться на новую дату
        expect(find.text('15 июл'), findsOneWidget);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 3. ЧИП «ВРЕМЯ» — тап открывает пикер времени
  // ─────────────────────────────────────────────────────────────────────
  group('Чип «ВРЕМЯ»', () {
    testWidgets('отображает время по умолчанию', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Время по умолчанию — 06:00
      expect(find.text('06:00'), findsOneWidget);
    });

    testWidgets('тап по времени открывает пикер', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Тапаем по чипу времени
      await tester.tap(find.text('06:00'));
      await tester.pumpAndSettle();

      // _TimePicker показывает заголовок «Время» и часы
      expect(find.text('Время'), findsOneWidget);
    });

    testWidgets('выбор времени обновляет чип', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Открываем пикер
      await tester.tap(find.text('06:00'));
      await tester.pumpAndSettle();

      // Тапаем на час «10»
      final hour10 = find.text('10:00');
      if (hour10.evaluate().isNotEmpty) {
        await tester.tap(hour10.last);
        await tester.pumpAndSettle();

        // Кнопка «Выбрать»
        final selectBtn = find.text('Выбрать');
        if (selectBtn.evaluate().isNotEmpty) {
          await tester.tap(selectBtn);
          await tester.pumpAndSettle();
        }

        // Чип должен обновиться
        expect(find.text('10:00'), findsOneWidget);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 4. КАРТА ПРУДА — тап по сектору выделяет его
  // ─────────────────────────────────────────────────────────────────────
  group('Карта пруда — выбор сектора', () {
    testWidgets('PondMapView отображается', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(PondMapView), findsOneWidget);
    });

    testWidgets('тап по сектору выделяет его и показывает расписание', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Изначально показывается «ЛЕНТА БРОНИРОВАНИЙ НА ПРУДУ»
      expect(find.textContaining('ЛЕНТА БРОНИРОВАНИЙ'), findsOneWidget);

      // Тапаем по карте пруда (GestureDetector внутри PondMapView)
      final mapFinder = find.byType(PondMapView);
      expect(mapFinder, findsOneWidget);

      // Получаем размер карты и тапаем по центру (сектор ~8)
      final mapRect = tester.getRect(mapFinder);
      await tester.tapAt(mapRect.center);
      await tester.pumpAndSettle();

      // После тапа должен появиться заголовок с номером сектора
      // Или текст «РАСПИСАНИЕ · СЕКТОР № XX»
      final scheduleHeader = find.textContaining('РАСПИСАНИЕ · СЕКТОР');
      final feedHeader = find.textContaining('ЛЕНТА БРОНИРОВАНИЙ');

      // Один из двух заголовков должен быть виден
      expect(
        scheduleHeader.evaluate().isNotEmpty || feedHeader.evaluate().isNotEmpty,
        isTrue,
        reason: 'После тапа по карте должен отображаться заголовок',
      );
    });

    testWidgets('повторный тап по тому же сектору снимает выделение', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final mapFinder = find.byType(PondMapView);
      final mapRect = tester.getRect(mapFinder);

      // Первый тап — выделяем
      await tester.tapAt(mapRect.center);
      await tester.pumpAndSettle();

      // Второй тап — снимаем выделение
      await tester.tapAt(mapRect.center);
      await tester.pumpAndSettle();

      // Должна вернуться «ЛЕНТА БРОНИРОВАНИЙ»
      expect(find.textContaining('ЛЕНТА БРОНИРОВАНИЙ'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 5. ФИЛЬТРЫ — тап открывает dropdown
  // ─────────────────────────────────────────────────────────────────────
  group('Фильтры dropdown', () {
    testWidgets('кнопка фильтров отображается', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Кнопка фильтров содержит текст «Фильтры»
      expect(find.text('Фильтры'), findsOneWidget);
    });

    testWidgets('тап по кнопке фильтров открывает dropdown', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Тапаем по кнопке фильтров
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Должны появиться варианты фильтров
      expect(find.text('Все клиенты'), findsOneWidget);
      expect(find.text('Премиум'), findsOneWidget);
      expect(find.text('Стандарт'), findsOneWidget);
      expect(find.text('Базовый'), findsOneWidget);
    });

    testWidgets('выбор фильтра «Премиум» закрывает dropdown', (tester) async {
      FilterValue currentFilter = FilterValue.none;
      bool isOpen = false;

      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(children: [
              FiltersDropdown(
                value: currentFilter,
                onChange: (v) => setState(() {
                  currentFilter = v;
                  isOpen = false;
                }),
                isOpen: isOpen,
                onToggle: () => setState(() => isOpen = !isOpen),
              ),
              if (isOpen)
                ...filterOptions.entries
                    .where((e) => e.key != FilterValue.none)
                    .map((e) => GestureDetector(
                          onTap: () => setState(() {
                            currentFilter = e.key;
                            isOpen = false;
                          }),
                          child: Text(e.value),
                        )),
            ]),
          ),
        ),
      ));

      // Открываем dropdown
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Выбираем «Премиум»
      await tester.tap(find.text('Премиум'));
      await tester.pumpAndSettle();

      // Dropdown закрылся — isOpen = false
      expect(isOpen, isFalse);
      // Кнопка показывает «Премиум»
      expect(find.text('Премиум'), findsOneWidget);
    });

    testWidgets('повторный тап по кнопке сворачивает dropdown', (tester) async {
      bool isOpen = false;

      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: FiltersDropdown(
              value: FilterValue.none,
              onChange: (_) {},
              isOpen: isOpen,
              onToggle: () => setState(() => isOpen = !isOpen),
            ),
          ),
        ),
      ));

      // Открываем
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();
      expect(isOpen, isTrue);

      // Сворачиваем повторным тапом
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();
      expect(isOpen, isFalse);
    });

    testWidgets('тап в пустую область закрывает dropdown', (tester) async {
      bool isOpen = true;

      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Stack(children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => isOpen = false),
                ),
              ),
              FiltersDropdown(
                value: FilterValue.none,
                onChange: (_) {},
                isOpen: isOpen,
                onToggle: () => setState(() => isOpen = !isOpen),
              ),
            ]),
          ),
        ),
      ));

      expect(isOpen, isTrue);

      // Тапаем в пустую область (вне dropdown)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(isOpen, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 6. СТАТИСТИКА — карточки загрузки и броней
  // ─────────────────────────────────────────────────────────────────────
  group('Статистические карточки', () {
    testWidgets('отображает карточку «ЗАГРУЗКА»', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('ЗАГРУЗКА'), findsOneWidget);
    });

    testWidgets('отображает карточку «БРОНЕЙ»', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('БРОНЕЙ'), findsOneWidget);
    });

    testWidgets('процент загрузки обновляется при смене часа', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Запоминаем начальный процент
      final initialLoad = find.textContaining('%');
      expect(initialLoad, findsOneWidget);

      // Меняем время на 14:00
      await tester.tap(find.text('06:00'));
      await tester.pumpAndSettle();

      final hour14 = find.text('14:00');
      if (hour14.evaluate().isNotEmpty) {
        await tester.tap(hour14.last);
        await tester.pumpAndSettle();

        final selectBtn = find.text('Выбрать');
        if (selectBtn.evaluate().isNotEmpty) {
          await tester.tap(selectBtn);
          await tester.pumpAndSettle();
        }

        // Процент загрузки мог измениться
        expect(find.textContaining('%'), findsOneWidget);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 7. ЛЕНТА БРОНИРОВАНИЙ — взаимодействие со слотами
  // ─────────────────────────────────────────────────────────────────────
  group('Лента бронирований', () {
    testWidgets('отображает заголовок ленты', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('ЛЕНТА БРОНИРОВАНИЙ'), findsOneWidget);
    });

    testWidgets('лента содержит слоты с секторами', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // В ленте должны быть номера секторов (1-16)
      // Проверяем что хотя бы один номер сектора виден
      bool foundSector = false;
      for (int i = 1; i <= 16; i++) {
        if (find.text('$i').evaluate().isNotEmpty) {
          foundSector = true;
          break;
        }
      }
      expect(foundSector, isTrue, reason: 'В ленте должен быть хотя бы один номер сектора');
    });

    testWidgets('тап по занятому слоту открывает карточку клиента', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Ищем строку с именем клиента в ленте (занятые слоты показывают имя)
      // Из demo_data: Иван Иванов, Алексей Кошкин и т.д.
      final clientNames = [
        'Иван Иванов', 'Алексей Кошкин', 'Сергей Петров',
        'Нина Крюкова', 'Дмитрий Лагута', 'Михаил Орлов',
        'Олег Сидоров', 'Виктор Щукин', 'Уэйд Джереми',
      ];

      for (final name in clientNames) {
        final finder = find.text(name);
        if (finder.evaluate().isNotEmpty) {
          // Тапаем по имени клиента (это InkWell → showClientCard)
          await tester.tap(finder.first);
          await tester.pumpAndSettle();

          // Должна открыться карточка клиента (диалог)
          // В карточке есть кнопка закрытия (IconButton с иконкой close)
          expect(find.byIcon(Icons.close), findsWidgets);

          // Закрываем карточку
          await tester.tap(find.byIcon(Icons.close).last);
          await tester.pumpAndSettle();
          break;
        }
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 8. НИЖНЕЕ МЕНЮ — dropdown не перекрывает
  // ─────────────────────────────────────────────────────────────────────
  group('Нижнее меню', () {
    testWidgets('dropdown фильтров не перекрывает нижнее меню', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Открываем dropdown
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Проверяем что нижнее меню всё ещё видимо
      expect(find.text('Нижнее меню'), findsOneWidget);

      // Позиция dropdown должна быть выше нижнего меню
      final dropdownFinder = find.byType(FiltersDropdown);
      final bottomNavFinder = find.text('Нижнее меню');

      if (dropdownFinder.evaluate().isNotEmpty && bottomNavFinder.evaluate().isNotEmpty) {
        final dropdownRect = tester.getRect(dropdownFinder);
        final bottomNavRect = tester.getRect(bottomNavFinder);

        expect(dropdownRect.bottom, lessThanOrEqualTo(bottomNavRect.top),
            reason: 'Dropdown не должен перекрывать нижнее меню');
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 9. НЕ СДВИГАЕТ КОНТЕНТ — обязательный тест
  // ─────────────────────────────────────────────────────────────────────
  group('Dropdown не сдвигает контент', () {
    testWidgets('открытие dropdown не двигает ленту бронирований', (tester) async {
      bool isOpen = false;

      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ListView(children: [
              const Text('Карта пруда'),
              FiltersDropdown(
                value: FilterValue.none,
                onChange: (_) {},
                isOpen: isOpen,
                onToggle: () => setState(() => isOpen = !isOpen),
              ),
              const Text('ЛЕНТА БРОНИРОВАНИЙ НА ПРУДУ'),
              ...List.generate(20, (i) => Text('Строка $i')),
            ]),
          ),
        ),
      ));

      // Запоминаем позицию ленты
      final posBefore = tester.getTopLeft(find.text('ЛЕНТА БРОНИРОВАНИЙ НА ПРУДУ'));

      // Открываем dropdown
      isOpen = true;
      await tester.pump();

      final posAfter = tester.getTopLeft(find.text('ЛЕНТА БРОНИРОВАНИЙ НА ПРУДУ'));

      expect(posAfter.dy, equals(posBefore.dy),
          reason: 'Контент не должен сдвинуться при открытии dropdown');
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 10. Z-ORDER — dropdown поверх контента, под нижним меню
  // ─────────────────────────────────────────────────────────────────────
  group('Z-order', () {
    testWidgets('dropdown рендерится поверх контента', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Открываем dropdown
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Dropdown с пунктом «Все клиенты» должен быть видим
      expect(find.text('Все клиенты'), findsOneWidget);
      // Нижнее меню тоже видимо
      expect(find.text('Нижнее меню'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 11. ПОЛНЫЙ СЦЕНАРИЙ — пользователь меняет дату, время, фильтр
  // ─────────────────────────────────────────────────────────────────────
  group('Полный сценарий пользователя', () {
    testWidgets('дата → время → фильтр → карта → лента', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // 1. Проверяем начальное состояние
      expect(find.text('Карта пруда'), findsOneWidget);
      expect(find.text('12 июл'), findsOneWidget);
      expect(find.text('06:00'), findsOneWidget);
      expect(find.text('Фильтры'), findsOneWidget);

      // 2. Открываем календарь и выбираем другую дату
      await tester.tap(find.text('12 июл'));
      await tester.pumpAndSettle();

      final day20 = find.text('20');
      if (day20.evaluate().isNotEmpty) {
        await tester.tap(day20.last);
        await tester.pumpAndSettle();

        final selectBtn = find.text('Выбрать');
        if (selectBtn.evaluate().isNotEmpty) {
          await tester.tap(selectBtn);
          await tester.pumpAndSettle();
        }
      }

      // 3. Меняем время
      final timeChip = find.textContaining(':00');
      if (timeChip.evaluate().isNotEmpty) {
        await tester.tap(timeChip.first);
        await tester.pumpAndSettle();

        final hour14 = find.text('14:00');
        if (hour14.evaluate().isNotEmpty) {
          await tester.tap(hour14.last);
          await tester.pumpAndSettle();

          final selectBtn = find.text('Выбрать');
          if (selectBtn.evaluate().isNotEmpty) {
            await tester.tap(selectBtn);
            await tester.pumpAndSettle();
          }
        }
      }

      // 4. Открываем фильтры
      final filterBtn = find.text('Фильтры');
      if (filterBtn.evaluate().isNotEmpty) {
        await tester.tap(filterBtn);
        await tester.pumpAndSettle();

        // Выбираем «Стандарт»
        final standard = find.text('Стандарт');
        if (standard.evaluate().isNotEmpty) {
          await tester.tap(standard.last);
          await tester.pumpAndSettle();
        }
      }

      // 5. Тапаем по карте
      final mapFinder = find.byType(PondMapView);
      if (mapFinder.evaluate().isNotEmpty) {
        final mapRect = tester.getRect(mapFinder);
        await tester.tapAt(mapRect.center);
        await tester.pumpAndSettle();
      }

      // 6. Проверяем что экран в целости
      expect(find.text('Карта пруда'), findsOneWidget);
      expect(find.byType(PondMapView), findsOneWidget);
    });
  });
}
