import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LaptopHarborApp());
}

class LaptopHarborApp extends StatelessWidget {
  const LaptopHarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaptopHarbor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
