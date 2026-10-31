import 'package:flutter/material.dart';
import 'sidebar.dart';

class AppLayout extends StatelessWidget {
  final Widget child; // Сюди go_router підставлятиме наші екрани

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                // Простий AppBar для веб-версії
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                      const SizedBox(width: 16),
                      const CircleAvatar(child: Icon(Icons.person)),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                // Основний контент сторінки
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}