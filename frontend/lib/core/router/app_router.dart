import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Text('Вміст: Дашборд', style: TextStyle(fontSize: 24)),
        ),
        GoRoute(
          path: '/employees',
          builder: (context, state) => const Text('Вміст: Список співробітників', style: TextStyle(fontSize: 24)),
        ),
        GoRoute(
          path: '/recruiting',
          builder: (context, state) => const Text('Вміст: Кандидати', style: TextStyle(fontSize: 24)),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const Text('Вміст: Аналітика', style: TextStyle(fontSize: 24)),
        ),
      ],
    ),
  ],
);