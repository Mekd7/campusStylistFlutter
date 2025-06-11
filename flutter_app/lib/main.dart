import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'package:campusstylistflutter/providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ThemeData _customTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF4081),
      background: const Color(0xFF1C2526),
    ),
    scaffoldBackgroundColor: const Color(0xFF1C2526),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4081),
        foregroundColor: Colors.white,
      ),
    ),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Campus Stylist',
        theme: _customTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}