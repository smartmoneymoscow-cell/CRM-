import 'package:flutter/material.dart';

import 'receipt_screen.dart';
import 'stub_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // "Чек" — активная вкладка по умолчанию, как в веб-версии.
  int _index = 1;

  static const _screens = [
    StubScreen(title: 'Карта', icon: Icons.map_outlined, note: 'Карта прудов и точек лова — раздел в разработке.'),
    ReceiptScreen(),
    StubScreen(title: 'Чеки', icon: Icons.receipt_long_outlined, note: 'История выставленных чеков — раздел в разработке.'),
    StubScreen(title: 'P&L', icon: Icons.show_chart, note: 'Отчёт по прибыли и убыткам — раздел в разработке.'),
    StubScreen(title: 'Профиль', icon: Icons.person_outline, note: 'Профиль администратора — раздел в разработке.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EC),
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 72,
          // Убираем лишние отступы над иконкой и под текстом
          iconTheme: WidgetStateProperty.all(const IconThemeData(size: 22)),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          // Уменьшаем отступ между иконкой и текстом
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFF6E3C4),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Карта'),
            NavigationDestination(icon: Icon(Icons.receipt_outlined), label: 'Чек'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Чеки'),
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'P&L'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}
