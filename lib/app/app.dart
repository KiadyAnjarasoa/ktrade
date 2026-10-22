import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

class KTradeApp extends StatelessWidget {
  const KTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTrade',
      debugShowCheckedModeBanner: false,
      theme: KTradeTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}