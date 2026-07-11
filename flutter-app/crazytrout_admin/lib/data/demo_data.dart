import '../models/client.dart';
import '../models/tariff.dart';

/// Тарифы. Значения синхронизированы с веб-версией:
/// Стандарт 750 ₽, Гостевой 500 ₽, Пенсионер 0 ₽.
const List<Tariff> kTariffs = [
  Tariff(id: 'standard', label: 'Стандарт', price: 750),
  Tariff(id: 'guest', label: 'Гостевой', price: 500),
  Tariff(id: 'pensioner', label: 'Пенсионер', price: 0),
];

/// Породы рыбы, доступные для добавления в улов (без варианта «Другое» —
/// цена всегда фиксированная и берётся автоматически).
const List<String> kSpecies = ['Осётр', 'Карп', 'Амур', 'Линь', 'Форель'];

/// Фиксированная цена за кг для каждой породы.
const Map<String, double> kSpeciesPrice = {
  'Осётр': 1890,
  'Карп': 590,
  'Амур': 750,
  'Линь': 690,
  'Форель': 1200,
};

/// Демо-клиенты для поиска (в реальном приложении — из backend).
const List<Client> kDemoClients = [
  Client(id: 1, name: 'Иван Иванов', phone: '+7 925 123-45-67', tariffLabel: 'Стандарт'),
  Client(id: 2, name: 'Алексей Кошкин', phone: '+7 916 555-22-11', tariffLabel: 'Стандарт'),
  Client(id: 3, name: 'Сергей Петров', phone: '+7 903 777-44-33', tariffLabel: 'Стандарт'),
  Client(id: 4, name: 'Анна Морозова', phone: '+7 925 333-00-99', tariffLabel: 'Стандарт'),
  Client(id: 5, name: 'Дмитрий Лагута', phone: '+7 985 111-22-33', tariffLabel: 'Стандарт'),
  Client(id: 6, name: 'Михаил Орлов', phone: '+7 962 888-99-00', tariffLabel: 'Пенсионер'),
  Client(id: 7, name: 'Олег Сидоров', phone: '+7 905 222-77-66', tariffLabel: 'Стандарт'),
];
