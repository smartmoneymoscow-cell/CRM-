import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/models/receipt.dart';
import 'package:crazytrout_admin/models/client.dart';

void main() {
  group('Receipt — генерация чеков', () {
    final client = Client(id: 1, name: 'Иван Иванов', phone: '+7 925 123-45-67', tariffLabel: 'Стандарт');
    final now = DateTime(2026, 7, 11, 15, 30);

    final rows = [
      const ReceiptRow(name: 'Осётр', weight: 2.500, price: 1890, sum: 4725),
      const ReceiptRow(name: 'Карп', weight: 1.000, price: 590, sum: 590),
    ];

    group('Фискальный чек', () {
      late Receipt receipt;

      setUp(() {
        receipt = Receipt(
          number: 1248,
          date: now,
          client: client,
          isGuest: false,
          tariffLabel: 'Стандарт',
          tariffPrice: 750,
          rows: rows,
          total: 6065,
          payment: PaymentMethod.card,
          fiscal: true,
          fiscalDoc: '№ФД-11248',
        );
      });

      test('fiscal = true', () {
        expect(receipt.fiscal, isTrue);
      });

      test('fiscalDoc не null и содержит номер', () {
        expect(receipt.fiscalDoc, isNotNull);
        expect(receipt.fiscalDoc, '№ФД-11248');
      });

      test('clientLine включает имя и телефон клиента', () {
        expect(receipt.clientLine, 'Иван Иванов · +7 925 123-45-67');
      });

      test('total = тариф + сумма строк улова', () {
        expect(receipt.total, 750 + 4725 + 590);
      });

      test('rows.length = 2', () {
        expect(receipt.rows.length, 2);
      });

      test('payment = card, label = "Картой"', () {
        expect(receipt.payment, PaymentMethod.card);
        expect(receipt.payment.label, 'Картой');
      });
    });

    group('Чек без ФН', () {
      late Receipt receipt;

      setUp(() {
        receipt = Receipt(
          number: 1249,
          date: now,
          client: client,
          isGuest: false,
          tariffLabel: 'Стандарт',
          tariffPrice: 750,
          rows: rows,
          total: 6065,
          payment: PaymentMethod.cash,
          fiscal: false,
        );
      });

      test('fiscal = false', () {
        expect(receipt.fiscal, isFalse);
      });

      test('fiscalDoc = null', () {
        expect(receipt.fiscalDoc, isNull);
      });

      test('payment = cash, label = "Наличными"', () {
        expect(receipt.payment, PaymentMethod.cash);
        expect(receipt.payment.label, 'Наличными');
      });
    });

    group('Чек гостя', () {
      late Receipt receipt;

      setUp(() {
        receipt = Receipt(
          number: 1250,
          date: now,
          client: null,
          isGuest: true,
          tariffLabel: 'Гостевой',
          tariffPrice: 500,
          rows: [const ReceiptRow(name: 'Форель', weight: 1.200, price: 1200, sum: 1440)],
          total: 1940,
          payment: PaymentMethod.card,
          fiscal: true,
          fiscalDoc: '№ФД-11250',
        );
      });

      test('clientLine = "Гость (без анкеты)"', () {
        expect(receipt.clientLine, 'Гость (без анкеты)');
      });

      test('client = null', () {
        expect(receipt.client, isNull);
      });

      test('isGuest = true', () {
        expect(receipt.isGuest, isTrue);
      });

      test('total = 500₽ тариф + 1440₽ форель = 1940₽', () {
        expect(receipt.total, 1940);
      });
    });

    group('Чек с пустым уловом', () {
      test('total = только тариф, rows пустые', () {
        final receipt = Receipt(
          number: 1251,
          date: now,
          client: client,
          isGuest: false,
          tariffLabel: 'Стандарт',
          tariffPrice: 750,
          rows: [],
          total: 750,
          payment: PaymentMethod.card,
          fiscal: false,
        );
        expect(receipt.rows, isEmpty);
        expect(receipt.total, 750);
      });
    });

    group('Чек пенсионера', () {
      test('tariffPrice = 0, total = только улов', () {
        final receipt = Receipt(
          number: 1252,
          date: now,
          client: Client(id: 6, name: 'Михаил Орлов', phone: '+7 962 888-99-00', tariffLabel: 'Пенсионер'),
          isGuest: false,
          tariffLabel: 'Пенсионер',
          tariffPrice: 0,
          rows: [const ReceiptRow(name: 'Карп', weight: 3.000, price: 590, sum: 1770)],
          total: 1770,
          payment: PaymentMethod.cash,
          fiscal: true,
          fiscalDoc: '№ФД-11252',
        );
        expect(receipt.tariffPrice, 0);
        expect(receipt.total, 1770);
      });
    });
  });
}
