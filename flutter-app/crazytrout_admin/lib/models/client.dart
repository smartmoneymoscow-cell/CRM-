class Client {
  final int id;
  final String name;
  final String phone;
  final String tariffLabel;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.tariffLabel,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b';
  }
}
