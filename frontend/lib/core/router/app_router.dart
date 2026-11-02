import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_layout.dart';
import '../../features/employees/views/employees_screen.dart';
import '../../features/recruiting/views/recruiting_screen.dart';
import '../../features/reports/views/reports_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';

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
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/employees',
          builder: (context, state) => const EmployeesScreen(),
        ),
        GoRoute(
          path: '/recruiting',
          builder: (context, state) => const RecruitingScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
      ],
    ),
  ],
);