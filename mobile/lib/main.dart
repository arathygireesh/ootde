import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: OOTDeeApp()));
}

class OOTDeeApp extends StatelessWidget {
  const OOTDeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOTDee - Smart Digital Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
