import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/models/receipt.dart';
import 'package:crazytrout_admin/models/client.dart';
import 'package:crazytrout_admin/services/escpos_builder.dart';

Receipt _makeReceipt({
  bool fiscal = true,
  PaymentMethod payment = PaymentMethod.card,
  bool isGuest = false,
}) {
  return Receipt(
    number: 1248,
    date: DateTime(2026, 7, 11, 15, 30),
    client: isGuest
        ? null
        : const Client(id: 1, name: 'Иван Иванов', phone: '+7 925 123-45-67', tariffLabel: 'Стандарт'),
    isGuest: isGuest,
    tariffLabel: isGuest ? 'Гостевой' : 'Стандарт',
    tariffPrice: isGuest ? 500 : 750,
    rows: const [
      ReceiptRow(name: 'Осётр', weight: 2.500, price: 1890, sum: 4725),
      ReceiptRow(name: 'Карп', weight: 1.000, price: 590, sum: 590),
    ],
    total: 6065,
    payment: payment,
    fiscal: fiscal,
    fiscalDoc: fiscal ? '№ФД-11248' : null,
  );
}

void main() {
  group('ESC/POS builder — байты для Bluetooth-принтера', () {
    group('Фискальный чек', () {
      late Uint8List data;
      late String text;

      setUp(() {
        data = buildEscPos(_makeReceipt(fiscal: true));
        text = utf8.decode(data.sublist(2));
      });

      test('начинается с ESC @ (0x1B, 0x40) — сброс принтера', () {
        expect(data[0], 0x1B);
        expect(data[1], 0x40);
      });

      test('заканчивается 3x LF (0x0A) — отвод бумаги', () {
        expect(data[data.length - 1], 0x0A);
        expect(data[data.length - 2], 0x0A);
        expect(data[data.length - 3], 0x0A);
      });

      test('содержит заголовок "CRAZY TROUT ARENA"', () {
        expect(text, contains('CRAZY TROUT ARENA'));
      });

      test('содержит номер чека', () {
        expect(text, contains('Chek No 1248'));
      });

      test('содержит разделитель "---"', () {
        expect(text, contains('--------------------------------'));
      });

      test('содержит строку "Осётр" с весом 2.50kg и ценой 1890', () {
        expect(text, contains('Осётр'));
        expect(text, contains('2.50kg'));
        expect(text, contains('1890'));
      });

      test('содержит строку "Карп" с весом 1.00kg и ценой 590', () {
        expect(text, contains('Карп'));
        expect(text, contains('1.00kg'));
        expect(text, contains('590'));
      });

      test('содержит ИТОГО: 6065 RUB', () {
        expect(text, contains('ITOGO: 6065 RUB'));
      });

      test('содержит способ оплаты "Картой"', () {
        expect(text, contains('OPLATA: Картой'));
      });

      test('размер данных 50–2000 байт', () {
        expect(data.length, greaterThan(50));
        expect(data.length, lessThan(2000));
      });
    });

    group('Чек без ФН', () {
      test('содержит "OPLATA: Наличными"', () {
        final data = buildEscPos(_makeReceipt(fiscal: false, payment: PaymentMethod.cash));
        final text = utf8.decode(data.sublist(2));
        expect(text, contains('OPLATA: Наличными'));
      });

      test('содержит ИТОГО: 6065 RUB', () {
        final data = buildEscPos(_makeReceipt(fiscal: false));
        final text = utf8.decode(data.sublist(2));
        expect(text, contains('ITOGO: 6065 RUB'));
      });
    });

    group('Чек гостя', () {
      test('содержит "ITOGO: 1940 RUB"', () {
        final receipt = Receipt(
          number: 1250,
          date: DateTime(2026, 7, 11),
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
        final data = buildEscPos(receipt);
        final text = utf8.decode(data.sublist(2));
        expect(text, contains('ITOGO: 1940 RUB'));
        expect(text, contains('1.20kg'));
      });
    });

    group('Чек с пустым уловом', () {
      test('не падает, содержит ИТОГО = тариф', () {
        final receipt = Receipt(
          number: 9999,
          date: DateTime(2026, 1, 1),
          client: null,
          isGuest: true,
          tariffLabel: 'Гостевой',
          tariffPrice: 500,
          rows: [],
          total: 500,
          payment: PaymentMethod.cash,
          fiscal: false,
        );
        final data = buildEscPos(receipt);
        final text = utf8.decode(data.sublist(2));
        expect(text, contains('ITOGO: 500 RUB'));
        expect(data[0], 0x1B);
        expect(data[1], 0x40);
      });
    });
  });
}
