# Crazy Trout Arena · Admin (Flutter)

Нативная кроссплатформенная админка на Flutter/Dart для чек-кассы пруда для платной рыбалки.

## Статус

| Раздел | Статус |
|---|---|
| Чек (выставление) | ✅ Полностью функционален |
| Печать Bluetooth (ESC/POS) | ✅ Функциональна |
| Печать AirPrint (PDF) | ✅ Функциональна |
| Карта | 🔲 Заглушка |
| Чеки (история) | 🔲 Заглушка |
| P&L (финансы) | 🔲 Заглушка |
| Профиль | 🔲 Заглушка |

## Что умеет

- **Выставление чеков** — выбор клиента (поиск) или гость
- **Три тарифа** — Стандарт 750₽, Гостевой 500₽, Пенсионер 0₽
- **Улов** — 5 пород (Осётр, Карп, Амур, Линь, Форель), раздельные кг/граммы, авторасчёт
- **Два типа чека** — фискальный (с ФН) и без ФН
- **Два способа печати** — Bluetooth-принтер (ESC/POS) и системный диалог (AirPrint/PDF)
- **Оплата** — наличные или карта

## Структура

```
lib/
├── main.dart                    — точка входа (без экрана входа)
├── models/
│   ├── client.dart              — модель клиента
│   ├── tariff.dart              — модель тарифа
│   ├── catch_row.dart           — строка улова (порода/кг/г/сумма)
│   └── receipt.dart             — чек (фискальный/без ФН, оплата)
├── data/
│   └── demo_data.dart           — тарифы, породы с ценами, демо-клиенты
├── services/
│   ├── escpos_builder.dart      — сборка ESC/POS байт для термопринтера
│   └── print_service.dart       — печать: Bluetooth и AirPrint/PDF
├── screens/
│   ├── home_shell.dart          — нижняя навигация (5 вкладок)
│   ├── receipt_screen.dart      — экран выставления чека
│   └── stub_screen.dart         — заглушка для нереализованных разделов
└── widgets/
    ├── catch_row_tile.dart      — виджет строки улова
    ├── segmented_control.dart   — переключатель (оплата, тип чека)
    └── receipt_result_sheet.dart — шторка с готовым чеком и печатью

test/
├── models/
│   ├── receipt_test.dart        — тесты генерации чеков (5 сценариев)
│   └── catch_row_test.dart      — тесты расчёта веса и суммы
└── services/
    ├── escpos_builder_test.dart  — тесты ESC/POS байтов (Bluetooth)
    └── print_service_test.dart   — тесты PDF + ESC/POS + данные чека
```

## Установка

### Скачать APK

Скачайте готовый APK по ссылке из GitHub Releases.

### Собрать локально

```bash
flutter create crazytrout_admin --platforms=android
# скопировать lib/, test/, pubspec.yaml, assets/
flutter pub get
flutter pub run flutter_launcher_icons
flutter test
flutter build apk --release
```

### Через GitHub Actions

1. Push в `main` → workflow «Build Android APK» собирает автоматически
2. Actions → последний запуск → Artifacts → скачать `app-release-apk`

## Иконка

Логотип Crazy Trout Arena на кремовом фоне `#FBF6EC`.
Генерируется автоматически: `flutter pub run flutter_launcher_icons`

## Тесты

```bash
flutter test
```

Покрытие:
- Генерация чеков (фискальный, без ФН, гость, пустой улов, пенсионер)
- Расчёт веса и суммы (кг + граммы → weight → sum)
- ESC/POS байты (Bluetooth) — структура, заголовок, содержимое
- PDF генерация (AirPrint) — все типы чеков
- Корректность данных перед отправкой на принтер
