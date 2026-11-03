import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_state.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String role = 'user';
        if (state is AuthAuthenticated) {
          role = state.role;
        }

        final bool isAdminOrHR = role == 'admin' || role == 'hr';

        return Container(
          width: 260,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Text(
                  'StaffFlow.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (isAdminOrHR)
                _NavItem(
                  title: 'Дашборд',
                  icon: Icons.space_dashboard_rounded,
                  route: '/',
                  currentRoute: currentRoute,
                ),
              if (!isAdminOrHR)
                _NavItem(
                  title: 'Мій кабінет',
                  icon: Icons.person_outline_rounded,
                  route: '/cabinet',
                  currentRoute: currentRoute,
                ),
              if (isAdminOrHR)
                _NavItem(
                  title: 'Співробітники',
                  icon: Icons.people_alt_outlined,
                  route: '/employees',
                  currentRoute: currentRoute,
                ),
              if (isAdminOrHR)
                _NavItem(
                  title: 'Рекрутинг',
                  icon: Icons.work_outline_rounded,
                  route: '/recruiting',
                  currentRoute: currentRoute,
                ),
              if (isAdminOrHR)
                _NavItem(
                  title: 'Звіти',
                  icon: Icons.insert_chart_outlined_rounded,
                  route: '/reports',
                  currentRoute: currentRoute,
                ),
              if (isAdminOrHR)
                _NavItem(
                  title: 'Відпустки',
                  icon: Icons.event_note_rounded,
                  route: '/leaves',
                  currentRoute: currentRoute,
                ),
              if (isAdminOrHR)
                _NavItem(
                  title: 'Облік часу',
                  icon: Icons.access_time_rounded,
                  route: '/attendance',
                  currentRoute: currentRoute,
                ),

              const Spacer(),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  title: const Text(
                    'Вийти',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  hoverColor: Colors.red.shade50,
                  onTap: () {
                    context.read<AuthCubit>().logout();
                    context.go('/login');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final String currentRoute;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentRoute == route;
    final Color contentColor = isActive ? Colors.black : Colors.grey.shade600;
    final Color bgColor = isActive ? Colors.grey.shade100 : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, color: contentColor, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: contentColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        selected: isActive,
        selectedTileColor: bgColor,
        hoverColor: Colors.grey.shade50,
        onTap: () => context.go(route),
      ),
    );
  }
}
