import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/client_home.dart';
import '../screens/hairdresser_home.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const Placeholder(), // Replace with SignUpScreen when implemented
    ),
    GoRoute(
      path: '/clientHome/:token',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        return ClientHomeScreen(token: token);
      },
    ),
    GoRoute(
      path: '/hairdresserHome/:token',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        return HairdresserHomeScreen(token: token);
      },
    ),
  ],
);