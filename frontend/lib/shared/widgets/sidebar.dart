import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'StaffFlow HRM',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
          _NavItem(
            title: 'Дашборд',
            icon: Icons.dashboard,
            route: '/',
            currentRoute: currentRoute,
          ),
          _NavItem(
            title: 'Співробітники',
            icon: Icons.people,
            route: '/employees',
            currentRoute: currentRoute,
          ),
          _NavItem(
            title: 'Рекрутинг',
            icon: Icons.work,
            route: '/recruiting',
            currentRoute: currentRoute,
          ),
          _NavItem(
            title: 'Звіти',
            icon: Icons.bar_chart,
            route: '/reports',
            currentRoute: currentRoute,
          ),
        ],
      ),
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
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade700;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: () => context.go(route),
    );
  }
}
