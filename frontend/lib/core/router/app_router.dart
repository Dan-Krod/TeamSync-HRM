import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Дашборд'))),
    ),
    GoRoute(
      path: '/employees',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Співробітники'))),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Звіти'))),
    ),
  ],
);