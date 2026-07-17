/// Константы и логика фильтров карты пруда.
/// Вынесены из pond_map_screen.dart для unit-тестирования.
/// ─────────────────────────────────────────────────────────
/// ⚠️ НЕ ИЗМЕНЯТЬ без обновления тестов в test/screens/pond_map_filter_test.dart.
///
/// Требования к dropdown фильтров:
///   1. gap = 0 → dropdown вплотную к кнопке (без зазора)
///   2. OverlayEntry (НЕ inline Stack) → контент НЕ двигается
///   3. Dropdown прикреплён к низу кнопки (CompositedTransformFollower)
///   4. Dropdown скроллится вместе с кнопкой (НЕ закрывается при скролле)
///   5. Dropdown ЗАКРЫВАЕТСЯ когда кнопка приближается к нижнему меню
///      и места не хватает даже на 2 пункта — НЕ сжимается, НЕ залезает
///   6. Нижнее меню всегда поверх dropdown
///   7. Tap-to-close: выбор варианта или tap на пустое место

enum FilterValue { none, all, premium, standard, basic }

const Map<FilterValue, String> filterOptions = {
  FilterValue.none: 'Нет',
  FilterValue.all: 'Все клиенты',
  FilterValue.premium: 'Премиум',
  FilterValue.standard: 'Стандарт',
  FilterValue.basic: 'Базовый',
};

const Map<FilterValue, String> filterButtonLabels = {
  FilterValue.none: 'Фильтры',
  FilterValue.all: 'Все',
  FilterValue.premium: 'Премиум',
  FilterValue.standard: 'Стандарт',
  FilterValue.basic: 'Базовый',
};

/// Зазор между кнопкой и дропдауном. Должен быть 0 (вплотную).
const double kDropdownGap = 0.0;

/// Высота одного пункта меню дропдауна.
const double kDropdownItemHeight = 44.0;

/// Вертикальный padding внутри дропдауна.
const double kDropdownVPadding = 8.0;

/// Высота нижней навигации (BottomNavigationBar + SafeArea).
const double kBottomNavHeight = 60.0;

/// Высота строки фильтров (кнопка + padding).
const double kFilterRowHeight = 36.0;

/// Минимальное количество пунктов, при котором dropdown ещё имеет смысл открываться.
const int kDropdownMinItems = 2;

/// Рассчитывает доступную высоту для dropdown.
/// Возвращает отрицательное значение если места нет (кнопка у нижнего меню).
///
/// [btnBottomY] — глобальная Y-координата нижнего края кнопки.
/// [screenH] — высота экрана.
/// [bottomPadding] — нижний safe area (MediaQuery.padding.bottom).
double calcMaxDropdownHeight({
  required double btnBottomY,
  required double screenH,
  required double bottomPadding,
}) {
  return screenH - btnBottomY - bottomPadding - kBottomNavHeight;
}

/// Проверяет хватает ли места для открытия dropdown.
bool hasEnoughSpaceForDropdown(double availableHeight) {
  return availableHeight >= kDropdownItemHeight * kDropdownMinItems + kDropdownVPadding * 2;
}
