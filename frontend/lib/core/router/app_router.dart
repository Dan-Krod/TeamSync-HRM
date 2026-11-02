import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/widgets/app_layout.dart';
import '../../features/employees/views/employees_screen.dart';
import '../../features/recruiting/views/recruiting_screen.dart';
import '../../features/reports/views/reports_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/cabinet/views/cabinet_screen.dart';
import '../../features/leaves/views/leaves_screen.dart';
import '../../features/attendance/views/attendance_screen.dart';

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
          pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/cabinet',
          pageBuilder: (context, state) => const NoTransitionPage(child: CabinetScreen()),
        ),
        GoRoute(
          path: '/employees',
          pageBuilder: (context, state) => const NoTransitionPage(child: EmployeesScreen()),
        ),
        GoRoute(
          path: '/recruiting',
          pageBuilder: (context, state) => const NoTransitionPage(child: RecruitingScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
        ),
        GoRoute(
          path: '/leaves',
          pageBuilder: (context, state) => const NoTransitionPage(child: LeavesScreen()),
        ),
        GoRoute(
          path: '/attendance',
          pageBuilder: (context, state) => const NoTransitionPage(child: AttendanceScreen()),
        ),
      ],
    ),
  ],
);