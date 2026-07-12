class Client {
  final int id;
  final String name;
  final String phone;
  final String tariffLabel;

  /// Путь к аватару в assets (null = показывать инициалы).
  final String? avatarAsset;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.tariffLabel,
    this.avatarAsset,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b';
  }
}
