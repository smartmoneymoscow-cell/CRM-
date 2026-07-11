import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

void main() {
  runApp(const CrazyTroutAdminApp());
}

class CrazyTroutAdminApp extends StatelessWidget {
  const CrazyTroutAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crazy Trout Arena · Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFBF6EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8912B),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeShell(),
    );
  }
}
