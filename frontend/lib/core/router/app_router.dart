import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/widgets/app_layout.dart';
import '../../features/employees/views/employees_screen.dart';
import '../../features/recruiting/views/recruiting_screen.dart';
import '../../features/reports/views/reports_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/auth/views/login_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getString('token') != null;
    final bool loggingIn = state.uri.toString() == '/login';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
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