import 'client.dart';

enum PaymentMethod { cash, card }

extension PaymentMethodLabel on PaymentMethod {
  String get label => this == PaymentMethod.cash ? 'Наличными' : 'Картой';
}

class ReceiptRow {
  final String name;
  final double weight;
  final double price;
  final double sum;

  const ReceiptRow({
    required this.name,
    required this.weight,
    required this.price,
    required this.sum,
  });
}

class Receipt {
  final int number;
  final DateTime date;
  final Client? client;
  final bool isGuest;
  final String tariffLabel;
  final int tariffPrice;
  final List<ReceiptRow> rows;
  final double total;
  final PaymentMethod payment;
  final bool fiscal;
  final String? fiscalDoc;

  const Receipt({
    required this.number,
    required this.date,
    required this.client,
    required this.isGuest,
    required this.tariffLabel,
    required this.tariffPrice,
    required this.rows,
    required this.total,
    required this.payment,
    required this.fiscal,
    this.fiscalDoc,
  });

  String get clientLine => isGuest
      ? 'Гость (без анкеты)'
      : (client != null ? '${client!.name} · ${client!.phone}' : '—');
}
